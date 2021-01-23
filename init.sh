#!/bin/sh

#make mymaster image
docker build --no-cache -t mymaster ./mymaster/

#sleep 10s

#make myslave image
docker build --no-cache -t myslave ./myslave/
docker-compose -f ./docker-compose.yml up -d --remove-orphans

sleep 15s

myaddress=`ipconfig getifaddr en0`
myaddress=${myaddress}

master_log_file=`mysql -h127.0.0.1 --port 3333 -uroot -e "show master status\G" | grep mysql-bin`
master_log_file="${master_log_file}"

re="[a-z]*-bin.[0-9]*"

if [[ ${master_log_file} =~ $re ]];then
    master_log_file=${BASH_REMATCH[0]}
fi

master_log_pos=`mysql -h127.0.0.1 --port 3333 -uroot -e "show master status\G" | grep Position`
master_log_pos="${master_log_pos}"

re="[0-9]+"

if [[ ${master_log_pos} =~ $re ]];then
    master_log_pos=${BASH_REMATCH[0]}
fi

query="change master to master_host='${myaddress}', master_user='slaveuser', master_password='slavepassword', master_log_file='${master_log_file}', master_log_pos=${master_log_pos}, master_port=3333"

mysql -h127.0.0.1 --port 2222 -uroot -e "${query}"
mysql -h127.0.0.1 --port 2222 -uroot -e "start slave"