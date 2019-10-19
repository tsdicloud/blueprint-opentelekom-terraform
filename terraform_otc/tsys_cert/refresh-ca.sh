if [[ -z $JAVA_HOME+notempty ]]; then
   echo "JAVA_HOME must be set" >&2
   exit 44
fi

hostname="Some cert auth dummy name"
cn_suffix="Intermediate label"
root_type="rsa:4096"
root_days="3650"
inter_type="rsa:4096"
inter_days="2000"
key_dir="keys"
cert_dir="certs"
while (( "$#" )); do
    case $1 in
        -n | --name  ) shift
                        cn_name="$1"
                        ;;
        -s | --suffix ) shift
                        cn_suffix="$1"
                        ;;
        -t | --trust-password ) shift
                        trust_password="$1"
                        ;;
        -rt | --root-type ) shift
                        root_type="$1"
                        ;;
        -rd | --root-days ) shift
                        root_days="$1"
                        ;;
        -it | --inter-type ) shift
                        inter_type="$1"
                        ;;
        -id | --inter-days ) shift
                        inter_days="$1"
                        ;;
        -kd | --key-dir ) shift
                        key_dir="$1"
                        ;;
        -td | --trust-dir ) shift
                        cert_dir="$1"
                        ;;
        * )             shift
    esac
    shift
done

#set -x

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# TODO: make directories readable only for user
# TODO: find a save place for the .state files and keys
mkdir -p $cert_dir
mkdir -p $key_dir

if ! [[ -e ${cert_dir}/ca-iterra.crt ]]; then
    echo === New root CA: ${cn_name} Root
    # Root CA: create certificate if trusted root certificate is not already
    # available
    CN="${cn_name} Root" openssl req -config ${SCRIPT_DIR}/ca.cnf -x509 -nodes \
        -keyout ${key_dir}/ca-iterra.key -out ${cert_dir}/ca-iterra.crt \
        -newkey ${root_type} -days ${root_days}
    echo 01 > ${key_dir}/ca-iterra.srl # do NOT use CAcreateserial !
else
    echo === Keeping root CA: ${cn_name} Root
fi

# always recreate intermediate files if root ca is newer than intermediate
# or intermediate does not exist
if [ ${cert_dir}/ca-${cn_suffix}.crt -ot ${cert_dir}/ca-iterra.crt ]; then

    echo === New intermediate CA: ${cn_name} ${cn_suffix}
    # Intermediate CA: request first, then sign; no need to keep csr file
    CN="${cn_name} ${cn_suffix}" openssl req -config ${SCRIPT_DIR}/ca.cnf \
      -nodes -keyout ${key_dir}/ca-${cn_suffix}.key -newkey ${inter_type} | \
      openssl x509 -req -CA ${cert_dir}/ca-iterra.crt \
      -CAkey ${key_dir}/ca-iterra.key -CAserial ${key_dir}/ca-iterra.srl \
      -days ${inter_days} -extfile ${SCRIPT_DIR}/ca.cnf -extensions v3_ca \
      -out ${cert_dir}/ca-${cn_suffix}.crt
    echo 01 > ${key_dir}/ca-${cn_suffix}.srl

    echo === Re-Packing CA Trust Bundle .pem
    rm -f ${cert_dir}/ca-truststore.pem
    touch ${cert_dir}/ca-truststore.pem

    echo === Re-packing CA Trust Bundle .jks, including java standard trust
    if [[ -e "${JAVA_HOME}/jre/lib/security/cacerts" ]]; then
       cp -f "${JAVA_HOME}/jre/lib/security/cacerts" ${cert_dir}/ca-truststore.jks
    else
       cp -f "${JAVA_HOME}/lib/security/cacerts" ${cert_dir}/ca-truststore.jks
    fi
    chmod 644 ${cert_dir}/ca-truststore.jks
    keytool -noprompt -storepasswd -storepass changeit -new ${trust_password} -keystore ${cert_dir}/ca-truststore.jks

    for c in ${cert_dir}/ca-*.crt*; do
        file=${c##*/}
        base=${file%%.*}
        cat ${c} >> ${cert_dir}/ca-truststore.pem
        keytool -import -noprompt -storepass ${trust_password} -alias "${base}" -file "${c}" -keystore ${cert_dir}/ca-truststore.jks
    done

    for c in ${SCRIPT_DIR}/trusted/* ; do
        file=${c##*/}
        base=${file%%.*}
        cat ${c} >> ${cert_dir}/ca-truststore.pem
        keytool -import -noprompt -storepass ${trust_password} -alias "${base}" -file "${c}" -keystore ${cert_dir}/ca-truststore.jks
    done

else
    echo === Keeping intermediate CA: ${cn_name} ${cn_suffix}
fi
