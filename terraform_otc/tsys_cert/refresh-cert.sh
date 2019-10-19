cn_suffix="Intermediate"
host="xxx.yyy.de"
hostip="xxx.yyy.de"
key_type="rsa:4096"
key_days="1000"
key_password="changeit"
trust_password="changeit"
key_dir="keys"
cert_dir="certs"
ssh_user=""
ssh_key=""
root_cert_dir="/etc/ssl/infaca"
services=""

while (( "$#" )); do
    case $1 in
        -h | --host ) shift
                        host="$1"
                        ;;
        -ip | --host-ip ) shift
                        hostip="$1"
                        ;;
        -sv | --services ) shift
                        services="$1"
                        ;;
        -s | --suffix ) shift
                        cn_suffix="$1"
                        ;;
        -t | --trust-password ) shift
                        trust_password="$1"
                        ;;
        -td | --trust-dir ) shift
                        cert_dir="$1"
                        ;;
        -kt | --key-type ) shift
                        key_type="$1"
                        ;;
        -d | --keys-days ) shift
                        key_days="$1"
                        ;;
        -k | --key-password ) shift
                        key_password="$1"
                        ;;
        -kd | --key-dir ) shift
                        key_dir="$1"
                        ;;
        -cu | --cert-user ) shift
                        cert_user="$1"
                        ;;
        -su | --ssh-user ) shift
                        ssh_user="$1"
                        ;;
        -sc | --ssh-key ) shift
                        ssh_key="$1"
                        ;;
        -rd | --root-cert-dir ) shift
                        root_cert_dir="$1"
                        ;;
        * )             shift
    esac
    shift
done

#set -x

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function generate_bundles {
  keybasename=$1
  
  # generate a trust file containing all certificates in trust chain
  openssl pkcs12 -export -chain -name "${keybasename}" \
      -inkey "${key_dir}/${keybasename}.key" \
      -in  "${cert_dir}/${keybasename}.crt" \
      -CAfile "${cert_dir}/ca-truststore.pem" \
      -password "pass:${key_password}"| \
      openssl pkcs12 -nokeys -password "pass:${key_password}" \
        -out "${cert_dir}/${keybasename}-bundle.pem" 
  
  # generate a key file with full trust chain included
  #openssl pkcs12 -export -chain -name "${keybasename}" \
  #    -inkey "${key_dir}/${keybasename}.key" \
  #    -in  "${cert_dir}/${keybasename}.crt" \
  #    -CAfile "${cert_dir}/ca-truststore.pem" \
  #    -password "pass:${key_password}"| \
  #    openssl pkcs12 -password "pass:${key_password}" \
  #      -out "${key_dir}/${keybasename}-key-bundle.pem" 
  # This is the non-save Informatia version of an key file without password
 cat "${key_dir}/${keybasename}.key" "${cert_dir}/${keybasename}-bundle.pem" \
    > "${key_dir}/${keybasename}-key-bundle.pem"

  # generate a java keystore / truststore is always the central one
  rm -f "${key_dir}/${keybasename}-keystore.jks" 2>/dev/null || true
  openssl pkcs12 -export -name "${keybasename}" \
      -inkey "${key_dir}/${keybasename}.key" \
      -in  "${cert_dir}/${keybasename}.crt" \
      -password "pass:${key_password}" -out "${key_dir}/${keybasename}.p12"

  keytool -importkeystore -destkeystore "${key_dir}/${keybasename}-keystore.jks" -deststorepass "${key_password}" -srckeystore "${key_dir}/${keybasename}.p12" -srcstoretype pkcs12 -srcstorepass "${key_password}" -alias "${keybasename}"
  rm -f "${key_dir}/${keybasename}.p12" 2>/dev/null || true
}

mkdir -p $cert_dir
mkdir -p $key_dir

# always recreate cert files if intermediate ca is newer than cert
if [ ${cert_dir}/${host}.crt -ot ${cert_dir}/ca-${cn_suffix}.crt ]; then
    echo === New  host key: ${host}
    CN="${host}" openssl req -config ${SCRIPT_DIR}/ca.cnf -nodes \
        -keyout ${key_dir}/${host}.key -newkey ${key_type} | \
        openssl x509 -req -CA ${cert_dir}/ca-${cn_suffix}.crt \
        -CAkey ${key_dir}/ca-${cn_suffix}.key \
        -CAserial ${key_dir}/ca-${cn_suffix}.srl \
        -days ${key_days} -extfile ${SCRIPT_DIR}/ca.cnf \
        -extensions server_cert -out ${cert_dir}/${host}.crt
    
    generate_bundles "${host}"
else
    echo === Keep host key: "${host}"
fi

scp -o StrictHostKeyChecking=no -i "${ssh_key}" -C -q  \
     "${cert_dir}/ca-truststore.pem" \
     "${key_dir}/${host}.key" \
     "${cert_dir}/${host}-bundle.pem" \
     "${key_dir}/${host}-key-bundle.pem" \
     "${ssh_user}@${hostip}:."
  ssh -o StrictHostKeyChecking=no -i "${ssh_key}" -q ${ssh_user}@${hostip} \
<< EOF
    sudo mkdir -p ${root_cert_dir}
    sudo install -C -m 444 -o ${cert_user} -g ${cert_user} -v \
         -D /home/${ssh_user}/ca-truststore.pem \
         ${root_cert_dir}/ca-bundle.pem;\
    rm /home/${ssh_user}/ca-truststore.pem
    sudo install -C -m 400 -o ${cert_user} -g ${cert_user} -v \
         -D /home/${ssh_user}/${host}.key ${root_cert_dir}/host-key.pem;\
    rm /home/${ssh_user}/${host}.key
    sudo install -C -m 444 -o ${cert_user} -g ${cert_user} -v \
         -D /home/${ssh_user}/${host}-bundle.pem \
         ${root_cert_dir}/host-bundle.pem;\
    rm /home/${ssh_user}/${host}-bundle.pem
    sudo install -C -m 400 -o ${cert_user} -g ${cert_user} -v \
         -D /home/${ssh_user}/${host}-key-bundle.pem\
         ${root_cert_dir}/host-key-bundle.pem;\
    rm /home/${ssh_user}/${host}-key-bundle.pem
EOF

if [[ -z "$services" ]]; then
  # add java truststores for service nodes
  scp -o StrictHostKeyChecking=no -i "${ssh_key}" -C -q  \
    "${cert_dir}/ca-truststore.jks" \
    "${key_dir}/${host}-keystore.jks" \
    "${SCRIPT_DIR}/empty.jks"
    "${ssh_user}@${hostip}:."
    ssh -o StrictHostKeyChecking=no -i "${ssh_key}" -q ${ssh_user}@${hostip} \
<< EOF
      sudo install -C -m 444 -o ${cert_user} -g ${cert_user} -v \
         -D /home/${ssh_user}/ca-truststore.jks \
         ${root_cert_dir}/truststure.jks;\
      rm /home/${ssh_user}/ca-truststore.jks
      sudo install -C -m 400 -o ${cert_user} -g ${cert_user} -v \
        -D /home/${ssh_user}/${host}-keystore.jks \
        ${root_cert_dir}/host-keystore.jks;\
      rm /home/${ssh_user}/${host}-keystore.jks
      sudo install -C -m 444 -o ${cert_user} -g ${cert_user} -v \
        -D /home/${ssh_user}/empty.jks ${root_cert_dir}/empty.jks;\
      rm /home/${ssh_user}/empty.jks
EOF
fi

# create certificates for all services
for svc in $services ; do
  if [ ${cert_dir}/${host}-${svc}.crt -ot ${cert_dir}/ca-${cn_suffix}.crt ]; then
     echo === New  svc key: "${host}-${svc}"
     CN="${svc}" ALTCN="${host}" openssl req -config ${SCRIPT_DIR}/ca.cnf \
       -nodes -keyout ${key_dir}/${host}-${svc}.key -newkey ${key_type} | \
       openssl x509 -req -CA ${cert_dir}/ca-${cn_suffix}.crt \
       -CAkey ${key_dir}/ca-${cn_suffix}.key \
       -CAserial ${key_dir}/ca-${cn_suffix}.srl \
       -days ${key_days} -extfile ${SCRIPT_DIR}/ca.cnf \
       -extensions server_altcn_cert \
       -out ${cert_dir}/${host}-${svc}.crt

     generate_bundles "${host}-${svc}"
  else
    echo === Keep svc key: "${host}-${svc}"
  fi
  scp -o StrictHostKeyChecking=no -i "${ssh_key}" -C -q  \
         "${key_dir}/${host}-${svc}-keystore.jks" \
         "${key_dir}/${host}-${svc}.key" \
         "${cert_dir}/${host}-${svc}-bundle.pem" \
         "${key_dir}/${host}-${svc}-key-bundle.pem" \
         "${ssh_user}@${hostip}:."
  ssh -o StrictHostKeyChecking=no -i "${ssh_key}" -q ${ssh_user}@${hostip} \
<< EOF
      sudo install -C -m 400 -o ${cert_user} -g ${cert_user} -v \
        -D /home/${ssh_user}/${host}-${svc}-keystore.jks \
        ${root_cert_dir}/${svc}-keystore.jks;\
        rm /home/${ssh_user}/${host}-${svc}-keystore.jks
      sudo install -C -m 400 -o ${cert_user} -g ${cert_user} -v \
        -D /home/${ssh_user}/${host}-${svc}.key \
        ${root_cert_dir}/host-key.pem;\
        rm /home/${ssh_user}/${host}-${svc}.key
      sudo install -C -m 444 -o ${cert_user} -g ${cert_user} -v \
        -D /home/${ssh_user}/${host}-${svc}-bundle.pem \
        ${root_cert_dir}/${svc}-bundle.pem;\
      rm /home/${ssh_user}/${host}-${svc}-bundle.pem
      sudo install -C -m 400 -o ${cert_user} -g ${cert_user} -v \
        -D /home/${ssh_user}/${host}-${svc}-key-bundle.pem\
        ${root_cert_dir}/${svc}-key-bundle.pem;\
      rm /home/${ssh_user}/${host}-${svc}-key-bundle.pem
EOF
done
