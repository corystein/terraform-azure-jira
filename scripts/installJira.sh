#!/bin/bash
###################################################################
# Script Name	:  installJira.sh                                                                                            
# Description	:  Install and configure Jira                                                                               
# Args          :  None                                                                                          
# Author        :  Cory R. Stein                                                  
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
yum install -y wget git openssl
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
# Create Jira Response File
####################################################################
echo "Creating unattended response file..."
# https://jira.atlassian.com/browse/JRASERVER-36002
cat > /tmp/response.varfile << EOL
#rmiPort$Long=8005
#app.jiraHome=/opt/atlassian/jira-home
#app.install.service$Boolean=true
#existingInstallationDir=/opt/JIRA
#sys.confirmedUpdateInstallationString=false
#sys.languageId=en
#sys.installationDir=/opt/atlassian/jira
#executeLauncherAction$Boolean=true
#httpPort$Long=8080
#portChoice=default

executeLauncherAction$Boolean=true
app.install.service$Boolean=true
sys.languageId=en
sys.installationDir=/opt/atlassian/jira
EOL
echo "Completed creating unattended response file"
####################################################################

####################################################################
# Install Jira
####################################################################
echo "Installing Jira..."
JIRA_VERSION=7.1.8
# https://confluence.atlassian.com/adminjiraserver071/unattended-installation-855475683.html
pushd /tmp

# Create application directory
echo "Creating [/opt/atlassian]..."
mkdir -p /opt/atlassian

# Download installer
echo "Downloadng installer..."
wget -q -O atlassian-jira-x64.bin https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-software-${JIRA_VERSION}-jira-${JIRA_VERSION}-x64.bin
#wget -O atlassian-jira-x64.bin https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-${JIRA_VERSION}-x64.bin
echo "Completed downloading installer"

# Set installer permissions
echo "Setting permissions for installer..."
chmod +x atlassian-jira-x64.bin

# Execute install
echo "Executing installer..."
./atlassian-jira-x64.bin -q -varfile response.varfile

popd
echo "Completed installing Jira"
####################################################################



echo "Executing [$0] complete"
exit 0