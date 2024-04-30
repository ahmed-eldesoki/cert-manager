
	- monitoring the change in directory once change happens it will trigger an action
---------------------------------------

oldcksum=`cksum /opt/zabbix/server.crt`
inotifywait -e modify,move,create,delete -mr --timefmt '%d/%m/%y %H:%M' --format '%T' \
/opt/zabbix/ | while read date time; do
    newcksum=`cksum /opt/zabbix/server.crt`
    if [ "$newcksum" != "$oldcksum" ]; then
        echo "At ${time} on ${date}, config file update detected."
        oldcksum=$newcksum
        sudo systemctl restart zabbix-server zabbix-agent nginx php8.1-fpm
    fi
done



--------------------------
	- Backup script
------------------------------------------
#!/bin/bash

# identifying userpass auth method parameters
user="vault_backup_status"
password="Vault1234"

# identifying the snapshot name and the server url
snapshot_name="snap_every_6h"
base_url="https://secrets.vault.vodafone.com"

# checking vault status if sealed will exit with an error 
# otherwise will continue check the backup status
checking_server=$(curl -s --request POST --data "{\"password\": \"${password}\"}" $base_url/v1/auth/userpass/login/$user)
error=$((echo "$checking_server") | jq -e '.errors' )

if [ $? -ne 0 ]; then 
    echo "vault is unsealed"

    # Identifying the leader node
    VAULT_TOKEN=$((echo "$checking_server") | jq -r '.auth.client_token' )
    leader_url=$(curl -s -H "X-Vault-Token: $VAULT_TOKEN" $base_url/v1/sys/leader | jq -r '.leader_address')

    # Checking the snapshot if it works fine will exit with 0 
    # otherwise will exit with 1
    
    status_path="/v1/sys/storage/raft/snapshot-auto/status/$snapshot_name"
    URL="$leader_url$status_path"
    status=$(curl -s --header "X-Vault-Token: $VAULT_TOKEN" "$URL" | jq -r '.data.last_snapshot_error')
  
    if [[ -z "$status" ]]; then
     echo "backup is working fine"
     exit 0
     
    else
   
      echo "there is an error"
      exit 1
    fi
else 
    echo "vault is sealed"
fi

-----------------------
	Check url    /opt/SP/apps/vault/cron-scripts
-----------------------

url="https://secrets.vault.vodafone.com"
curl --output /dev/null --silent --head --fail $url
if [ $? -eq 0 ]; then
    echo "$url is reachable"
    exit 0
else
    echo "$url is not reachable"
    exit 1
fi

-----------------
Check cert validity
------------------

#!/bin/bash
# certificates paths
certificates=(
 "/home/ec2-user/certificates/cert-2.crt"
#  "/home/ec2-user/certificates/cert.crt"
)
for cert in "${certificates[@]}"; 
do
    # Check the validation
    openssl x509 -checkend 1000000 -noout -in "$cert"
    if [ $? -eq 0 ]; then
        echo "Certificate $cert is valid."
    else
        echo "Certificate $cert is not valid."
        exit 1
    fi
done

