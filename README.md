# Deploy Terraform to create EC2 and SG

´´´
$ cd terraform
$ ./terraform <env> init
$ ./terraform <env> apply
´´´

# Deploy Ansible to configure Cortex App env

´´´
$ cd ansible
$ ansible-playbook -i hosts cortex.yaml 

´´´
