# Criando o banco:
create database cortex;

# Criando o usuário:
create user cortex with password 'cortex@2018';
alter user cortex with LOGIN;
alter database cortex owner to cortex;



/* $ cat /etc/fstab
#
LABEL=/opt     /opt           ext4    defaults,noatime  1   1 */