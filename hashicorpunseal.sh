#### Auto Unseal of Vault ####

#### Checking Vault Status ####

sealstatus=$(vault status | grep "Init")
initstatus=$(vault status | grep "Sealed")

echo "The variable value is $sealstatus"
echo "The variable value is $initstatus"

# function unsealjoin { ### Function to just unseal and join ###
# ukey1=$(sed -n '1p' /vault/data/hashicorpinitkeys.txt | awk -F ':' '{print $2}')
# ukey2=$(sed -n '2p' /vault/data/hashicorpinitkeys.txt | awk -F ':' '{print $2}') 
# ukey3=$(sed -n '3p' /vault/data/hashicorpinitkeys.txt | awk -F ':' '{print $2}')
# ukey4=$(sed -n '4p' /vault/data/hashicorpinitkeys.txt | awk -F ':' '{print $2}')
# ukey5=$(sed -n '5p' /vault/data/hashicorpinitkeys.txt | awk -F ':' '{print $2}')
# rootkey=$(sed -n '7p' /vault/data/hashicorpinitkeys.txt | awk -F ':' '{print $2}')
# if [ "$VAULT_K8S_POD_NAME" = "vault-0" ]
# then
# vault operator unseal $ukey1
# vault operator unseal $ukey2
# vault operator unseal $ukey3
# else
# vault operator raft join http://vault-0.vault-internal:8200
# vault operator unseal $ukey1
# vault operator unseal $ukey2
# vault operator unseal $ukey3
# fi
# }
# function unsealinitjoin { ### Function to Init, unseal and join ###
# if [ "$VAULT_K8S_POD_NAME" = "vault-0" ]
# then
# vault operator init >> /vault/data/hashicorpinitkeys.txt
# ukey1=$(sed -n '1p' /vault/data/hashicorpinitkeys.txt | awk -F ':' '{print $2}')
# ukey2=$(sed -n '2p' /vault/data/hashicorpinitkeys.txt | awk -F ':' '{print $2}')
# ukey3=$(sed -n '3p' /vault/data/hashicorpinitkeys.txt | awk -F ':' '{print $2}')
# ukey4=$(sed -n '4p' /vault/data/hashicorpinitkeys.txt | awk -F ':' '{print $2}')
# ukey5=$(sed -n '5p' /vault/data/hashicorpinitkeys.txt | awk -F ':' '{print $2}')
# rootkey=$(sed -n '7p' /vault/data/hashicorpinitkeys.txt | awk -F ':' '{print $2}')
# vault operator unseal $ukey1
# vault operator unseal $ukey2
# vault operator unseal $ukey3
# else
# ukey1=$(sed -n '1p' /vault/data/hashicorpinitkeys.txt | awk -F ':' '{print $2}')
# ukey2=$(sed -n '2p' /vault/data/hashicorpinitkeys.txt | awk -F ':' '{print $2}')
# ukey3=$(sed -n '3p' /vault/data/hashicorpinitkeys.txt | awk -F ':' '{print $2}')
# ukey4=$(sed -n '4p' /vault/data/hashicorpinitkeys.txt | awk -F ':' '{print $2}')
# ukey5=$(sed -n '5p' /vault/data/hashicorpinitkeys.txt | awk -F ':' '{print $2}')
# rootkey=$(sed -n '7p' /vault/data/hashicorpinitkeys.txt | awk -F ':' '{print $2}')
# vault operator raft join http://vault-0.vault-internal:8200
# vault operator unseal $ukey1
# vault operator unseal $ukey2
# vault operator unseal $ukey3 
# fi
# }
# if [[ "$sealstatus" == *"true"* ]] && [[ "$initstatus" == *"true"* ]]
# then
# 	echo "Vault is initialised and sealed, checking for keys in configmap"
#         unsealjoin
# elif [[ "$sealstatus" == *"true"* ]] && [[ "$initstatus" == *"false"* ]]
# 	echo "Vault is not initialised hence initializing and unsealing"
#         unsealinitjoin
# else
#         echo "Vault is unsealed and initialised, please proceed."
# fi