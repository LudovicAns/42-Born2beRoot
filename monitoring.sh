#!/bin/bash

TAB="	"
IPv4=$(hostname -I | cut -d' ' -f1)
ARCHITECTURE=$(uname -a)
HOSTNAME=$(hostnamectl --static)
USERNAME=$(whoami)
TTY=$(ps hotty $$)
EXEC_TIME=$(date "+%a %b %d %T %Y")
CPU=$(grep -c processor /proc/cpuinfo | cut -d' ' -f2)
vCPU=$(grep 'cpu cores' /proc/cpuinfo | uniq | cut -d' ' -f3)
USED_RAM=$(free -m | grep Mem | awk '{printf("%d", $3)}')
TOTAL_RAM=$(free -m | grep Mem | awk '{printf("%d", $2)}')
USED_RAMP=$(free -m | grep Mem | awk '{printf("%.2f", ($3/$2)*100)}')
ROOT_TOTAL_SPACE=$(df /dev/mapper/crypt-root | grep /dev/mapper/crypt-root | awk '{print $2}')
HOME_TOTAL_SPACE=$(df /dev/mapper/crypt-home | grep /dev/mapper/crypt-home| awk '{print $2}')
BOOT_TOTAL_SPACE=$(df /dev/sda1 | grep /dev/sda1 | awk '{print $2}')
TOTAL_SPACE=$(echo $((${ROOT_TOTAL_SPACE}+${HOME_TOTAL_SPACE}+${BOOT_TOTAL_SPACE})) | awk '{printf "%.f", $1}')
ROOT_USED_SPACE=$(df /dev/mapper/crypt-root | grep /dev/mapper/crypt-root | awk '{print $3}')
HOME_USED_SPACE=$(df /dev/mapper/crypt-home | grep /dev/mapper/crypt-home| awk '{print $3}')
BOOT_USED_SPACE=$(df /dev/sda1 | grep /dev/sda1 | awk '{print $3}')
USED_SPACE=$(echo $((${ROOT_USED_SPACE}+${HOME_USED_SPACE}+${BOOT_USED_SPACE})) | awk '{printf "%d", $1}')
USED_SPACEP=$(echo ${TOTAL_SPACE} ${USED_SPACE} | awk '{printf "%.2f", ($2*100)/$1}')
CPU_LOAD_INT=$(top -n 1 | grep "%Cpu(s):" | awk '{printf "%d", $4}' | cut -d',' -f1)
CPU_LOAD_FLOAT=$(top -n 1 | grep "%Cpu(s):" | awk '{printf "%d", $4}' | cut -d',' -f2)
LAST_BOOT=$(who -b | grep "démarrage" | awk '{printf "%s %s", $3, $4}')
LVM="no"
TCP_COUNT=$(ss -s | grep TCP: | awk '{printf "%d", $4}')
LOGGED_USERS=$(who | grep -c "")
MAC=$(ip a | grep "link/ether" | awk '{print $2}')
SUDO_CMD=$(cat /var/log/sudo | grep -c COMMAND)

if [ $(cat /etc/rpc | grep -c /dev/mapper/) ]
then
	LVM="yes"
fi

TMP="monitoring.tmp"
rm -rf ${TMP}
touch ${TMP}
chmod 777 ${TMP}

echo "Broadcast message from ${USERNAME}@${HOSTNAME} (${TTY}) (${EXEC_TIME}):" >> ${TMP}
echo "" >> ${TMP}
echo "${TAB}#Architecture: ${ARCHITECTURE}" >> ${TMP}
echo "${TAB}#CPU physical: ${CPU}" >> ${TMP}
echo "${TAB}#vCPU: ${vCPU}" >> ${TMP}
echo "${TAB}#Memory Usage: ${USED_RAM}/${TOTAL_RAM}MB (${USED_RAMP}%)" >> ${TMP}
echo "${TAB}#Disk Usage: ${USED_SPACE}/${TOTAL_SPACE}b (${USED_SPACEP}%)" >> ${TMP}
echo "${TAB}#CPU Load: ${CPU_LOAD_INT}.${CPU_LOAD_FLOAT}%" >> ${TMP}
echo "${TAB}#Last boot: ${LAST_BOOT}" >> ${TMP}
echo "${TAB}#LVM use: ${LVM}" >> ${TMP}
echo "${TAB}#Connexions TCP: ${TCP_COUNT} ETABLISHED" >> ${TMP}
echo "${TAB}#User log: ${LOGGED_USERS}" >> ${TMP}
echo "${TAB}#Network: IP ${IPv4} (${MAC})" >> ${TMP}
echo "${TAB}#Sudo: ${SUDO_CMD} cmd" >> ${TMP}

sudo wall -n ${TMP}
