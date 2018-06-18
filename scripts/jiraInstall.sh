#!/bin/bash
###################################################################
# Script Name	:  jiraMaster.sh                                                                                            
# Description	:  Install and configure a Jira                                                                               
# Args         :  None                                                                                          
# Author       :  Cory R. Stein                                                  
###################################################################

echo "Executing [$0]..."
PROGNAME=$(basename $0)

set -e


####################################################################
# Execute updates
####################################################################
#yum update -y
####################################################################

####################################################################
# Base install
####################################################################
yum install -y wget curl git jenkins-ha-monitor
####################################################################

####################################################################
# Disable SELINUX
####################################################################
echo "Disable SELINUX..."
setsebool -P httpd_can_network_connect 1
sed -i 's/enforcing/disabled/g' /etc/selinux/config /etc/selinux/config
setenforce 0
sestatus
echo "Successfully disabled SELINUX"
####################################################################

####################################################################
# Install Java
####################################################################
echo "Installing Java..."
# https://www.digitalocean.com/community/tutorials/how-to-install-java-on-centos-and-fedora
yum install -y java-1.8.0-openjdk
java -version
echo "Successfully installed Java"
####################################################################

####################################################################
# Install Java
####################################################################
cd /opt
#For 64 Bit:
wget https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-6.4.7-x64.bin
chmod +x atlassian-jira-6.4.7-x64.bin
# ./atlassian-jira-6.4.7-x64.bin
####################################################################

echo "Executing [$0] complete"
exit 0