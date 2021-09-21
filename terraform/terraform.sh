#!/bin/bash
# Preparar script para poder parametrizar os ambientes

#$1 Environment (DEV, hml, PRD)
#$2 Terraform command (init, plan, apply)

echo "Executing command: " $2 "in environment: " $1  

# Preparar script para poder parametrizar os ambientes
if [ $# -eq 0 ]
then
	echo
	echo "Favor informar um ambiente como argumento."
	echo $1" <dev | hml | prd>"
	echo 
    echo "Favor informar o comando terraform a ser executado."
	echo $2" <init | plan | apply>"
	exit 1
fi

#### PASSAR PARAMETRO PARA TRATAR VERSÃO DO TERRAFORM ???
TERRAFORM14=/usr/local/bin/
TERRAFORM=$TERRAFORM14/terraform-0.14


echo 'AWS Account ID: ' ${AWS_ACCOUNT_ID}

$TERRAFORM14/terraform-0.14 --version
echo "inicio Executing command: " $2 "in environment: " $1  

if [ "$2" == "init" ]; then
    echo "Initializing ...."
    #$TERRAFORM $@  -var account=${AWS_ACCOUNT_ID} || exit 1

    #$TERRAFORM $2  -var-file="../environments/$1.tfvars" || exit 1
    echo $TERRAFORM $2 -reconfigure -backend-config="environments/$1.tfbackend" -var-file="environments/$1.tfvars"
    $TERRAFORM $2 -reconfigure -backend-config="environments/$1.tfbackend" -var-file="environments/$1.tfvars" || exit 1
else
    #echo "else Executing command: " $2 "in environment: " $1  
    # $TERRAFORM validate  -var account=${AWS_ACCOUNT_ID} || exit 1
    # $TERRAFORM $@ -var account=${AWS_ACCOUNT_ID} || exit 2

    #$TERRAFORM validate  -var-file="../environments/$1.tfvars" || exit 1
    echo $TERRAFORM $2 -reconfigure -backend-config="environments/$1.tfbackend" -var-file="environments/$1.tfvars" $3
    $TERRAFORM validate || exit 1
    #$TERRAFORM $2 -reconfigure -backend-config="environments/$1.tfbackend" -var-file="environments/$1.tfvars" $3 || exit 2
    $TERRAFORM $2 -var-file="environments/$1.tfvars" $3 || exit 2
fi

