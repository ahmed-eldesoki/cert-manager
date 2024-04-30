This Ansible playbook is intended to consume Vault PKI service to manage the TLS certificates and distribute them across multiple nodes. The execution of this playbook should be performed by a cronjob based on your requirements.

Contents

Cert-dis file: 

It is the main file and it includes three tasks:
•	The first task is to login to vault using approle auth method.
•	The second and third task is to apply the role based on the node name. if you have additional node you need to add new task and role similar to the existed ones.

Hosts:
includes the nodes ssh info. 

Roles:
We have a specific role for each node. 

Tasks:
•	Getting certificates info then checking the certificate validity 3 min upfront 
•	Issue a new certificate and key if the certificate is not valid. 
•	place the new certificate and key to the desired path.



