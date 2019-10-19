### Execution sequence
##### Build mgmt zone (call from an "outside" terraform instance, e.g. on private machine:
'''
> cd terraform_otc/tsys_mgmt
> terraform apply -var-file=mgmtXXXX.tfvars .
'''
Creates ssh key 'doaas_mgmt.pem" for access of the jumpserver,
and and external IP address with open SSH port 22.

##### Build pod from management Jumpserver:
'''
> cd terraform_otc/tsys_pod
> terraform apply -var-file=podXXXX.tfvars .
'''
Creates ssh key 'doaas_pod.pem' for access of deployed servers in pod.

##### Image:
'''
> cd terraform_otc/tsys_image
> terraform apply -var-file=imageXXXX.tfvars .
'''
Note that openstack client calls are made to create image.

##### Infrastructure deployment
Init:
'''
>  terraform init -var-file=./pods/poc1/vpc.json -var-file=./pods/poc1/pod.json -var topo_file=./podc/poc1/topo.json -var otc_cacert_file=terraform_otc/otc_certs.pem terraform_otc
'''

Execution - apply:
'''
> terraform apply -state=./pods/poc1/terraform.tfstate -var-file=./pods/poc1/vpc.json -var-file=./pods/poc1/pod.json -var topo_file=./pods/poc1/topo.json -var otc_cacert_file=terraform_otc/otc_certs.pem terraform_otc
'''


Execution - destroy:
'''
> terraform destroy -state=./pods/poc1/terraform.tfstate -var-file=./pods/poc1/vpc.json -var-file=./pods/poc1/pod.json -var topo_file=./pods/poc1/topo.json -var otc_cacert_file=terraform_otc/otc_certs.pem terraform_otc
'''

##### Refresh certificates only (including root
Make sure that JAVA_HOME is set in your environment!

Back up old root and intermediate CA certs and remove keys and certs from
the topo/cert and topo/keys directories

Execution - refresh certs only:
'''
> cd terraform_otc 
> terraform taint -state=../pods/poc1/terraform.tfstate -module=refresh-certs null_resource.refresh-ca
> cd ..
> terraform apply -state=./pods/poc1/terraform.tfstate -var-file=./pods/poc1/vpc.json -var-file=./pods/poc1/pod.json -var topo_file=./pods/poc1/topo.json -var otc_cacert_file=terraform_otc/otc_certs.pem -target=module.refresh-certs terraform_otc
'''

### Appendix:  Services and dependencies
'''
components = [
    "identity-service",
    "ma-service",
    "content-repository-service",
    "v3api",
    "saas",
    "saas-mac",
    "saas-ac",
    "saas-da",
    "saas-channel",
    "session-service",
    "frs",
    "license-service",
    "callback-service",
    "migration-service",
    "bundle-service",
    "ca-service",
    "preference-service",
    "cloudshell",
    "cloudUI",
    "hierarchyservice",
    "jls-di",
    "kms-service",
    "scheduler-service",
    "auditlog-service",
    "notification-service",
    "pkgr",
    "pc2cloud-service",
    "pc2cloudUI",
    "autoscaler-service",
    "kafka",
    "zookeeper",
    "internal-haproxy",
    "external-haproxy",
    "ma-haproxy"
]

SERVICES = [
    "identity-service",
    "ma-service",
    "content-repository-service",
    "v3api",
    "session-service",
    "frs",
    "license-service",
    "callback-service",
    "migration-service",
    "bundle-service",
    "ca-service",
    "preference-service",
    "cloudshell",
    "cloudUI",
    "jls-di",
    "kms-service",
    "scheduler-service",
    "auditlog-service",
    "notification-service",
    "pkgr",
    "pc2cloud-service",
    "pc2cloudUI",
    "autoscaler-service",
    "hierarchyservice",
    "mass-ingestion",
    "mftsaas"
]

TERRA_APPS = [
    "saas",
    "saas-mac",
    "saas-ac",
    "saas-da",
    "saas-channel",
    "saas-validator"
]

HAPROXY = [
    "internal-haproxy",
    "external-haproxy",
    "ma-haproxy"
]

KAFKA = [
    "kafka",
    "zookeeper"
]

dependencies = [
    {"identity-service":
         ["ma-service",
          "session-service"]},
    {"ma-service":
         ["session-service"]},
    {"session-service":
         []},
    {"zookeeper":
         []},
    {"frs":
         []},
    {"license-service":
         []},
    {"migration-service":
         ["bundle-service"]},
    {"saas":
         ["autoscaler-service"]}
]
''

##### Deployed services with python:
. HAProxy
'''
Generate haproxy.cfg
        Three modes are supported:
        1.  Reload (default): Running a background consul-template command which will update haproxy.cfg and
            reload HAProxy;
        2.  Once: Running a one-time consul-template command to generate haproxy.cfg;
        3.  Dummy: Running a background consul-template command which will update haproxy.dummy file.
        """

        command_reload = "sudo nohup /usr/local/bin/consul-template -template \"/etc/haproxy/haproxy_consul_config.ctmpl:/etc/haproxy/haproxy.cfg:chown haproxy.haproxy /etc/haproxy/haproxy.cfg && systemctl reload haproxy\" &>/dev/null &"
        command_once   = "sudo /usr/local/bin/consul-template -template \"/etc/haproxy/haproxy_consul_config.ctmpl:/etc/haproxy/haproxy.cfg:chown haproxy.haproxy /etc/haproxy/haproxy.cfg\" -once"
        command_dummy  = "sudo nohup /usr/local/bin/consul-template -template \"/etc/haproxy/haproxy_consul_config.ctmpl:/etc/haproxy/haproxy.dummy:chown haproxy.haproxy /etc/haproxy/haproxy.dummy\" &>/dev/null &"


. ITERRA  apps
       if app_name == "saas-mac":
            self.app_abbr = "mac"
            self.port_number = "16005"
        elif app_name == "saas":
            self.app_abbr = "saas"
            self.port_number = "16006"
        elif app_name == "saas-ac":
            self.app_abbr = "ac"
            self.port_number = "16011"
        elif app_name == "saas-channel":
            self.app_abbr = "channel"
            self.port_number = "16010"
        elif app_name == "saas-da":
            self.app_abbr = "da"
            self.port_number = "16009"
        elif app_name == "saas-validator":
            self.logger.warn( "not implemented")
        else:
            self.logger.error("???")
            sys.exit(-1)

cd /{1}/shared_dir/downloads; ./install_terra.sh -l \\\"{2}\\\" -t\""\
---
        shared_dir = "/%s/shared_dir/downloads" % ("opt" if self.name == "saas-mac" else "data")
        command = """if [ ! -f {0}/{1} ];
then
  sudo su {2} -c "cd {0}; ./fetchFromS3.sh -a {3} -b {1} -t dev; ./install_terra.sh -l \"{4}\" -e -b {1}; ./install_terra.sh -l \"{4}\" -f -b {1}; ./install_terra.sh -l \"{4}\" -t"
fi""".format(shared_dir, terra_build, self.app_user, self.ma_url, self.app_abbr)
----
ALive checks:
            cmd = "sudo curl -i -s --cacert /etc/ssl/infaca/ca-bundle.pem --cert /etc/ssl/infaca/host-key-bundle.pem https://{0}:{1}/{2}/web.saas.service/html/terraalive.html" \
                .format(self.hostname, self.port_number, self.app_abbr)
        else:
            cmd = "sudo curl -i -s --cacert /etc/ssl/infaca/ca-bundle.pem --cert /etc/ssl/infaca/host-key-bundle.pem https://{0}:{1}/{2}/terraalive.html" \


---

##### Kafka


'''
. 
 




###Master-deploy


##### SaaS:
Validator
'''
//shared_dir/downloads/runInstallTERRA.sh -v
'''
Start
'''
/data/shared_dir/downloads/runInstallTERRA.sh -l \"" + super.getShortname() + "\" -i -d -y -b " + this.saas_build + "
'''
Stop
'''
/data/shared_dir/downloads/runInstallTERRA.sh -l \"" + super.getShortname() + "\" -p
'''

##### Ext. HAProxy

'''
        if (super.getInput().equals("kill")) {
            return ssh + "'ps -ef | grep hap | grep -v grep | awk \"{print \\$2}\" | while read pID; do sudo kill -9 $pID; done';";
        } else if (super.getInput().equals("chefCreateConfig")) {
            return ssh + "'sudo chef-client -o recipe[haproxy-consul::createExternalConfig]';";
        } else if (super.getInput().equals("removeConfig")) {
            return ssh + "'sudo rm -rf /etc/haproxy/00-haproxy.cfg';";
        } else if (super.getInput().equals("start")) {
            return ssh + "'sudo systemctl start haproxy';";
        } else if (super.getInput().equals("createReload")) {
            return ssh + "\"echo 'sudo /usr/local/bin/consul-template -template \\\"/etc/haproxy/haproxy_consul_config.ctmpl:/etc/haproxy/haproxy.cfg:chown haproxy.haproxy /etc/haproxy/haproxy.cfg && systemctl reload haproxy\\\" &' > /tmp/haproxy_reload.sh\"";
        } else if (super.getInput().equals("chmodReload")) {
            return ssh + "chmod +x /tmp/haproxy_reload.sh;";
        } else if (super.getInput().equals("execReload")) {
            return ssh + "\"nohup /tmp/haproxy_reload.sh > /dev/null 2>&1 &\"";
        } else if (super.getInput().equals("checkStatus")) {
            return ssh + "'ps -ef | grep hap';";
        }
'''


