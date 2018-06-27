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
# Install Java (Jira does not work with Open JDK)
####################################################################
echo "Installing Java..."
# https://www.digitalocean.com/community/tutorials/how-to-install-java-on-centos-and-fedora
#yum install -y java-1.8.0-openjdk
#JAVA_DOWNLOAD_URL=http://download.oracle.com/otn-pub/java/jdk/8u162-b12/0da788060d494f5095bf8624735fa2f1/jdk-8u162-linux-x64.rpm
JAVA_DOWNLOAD_URL=http://download.oracle.com/otn-pub/java/jdk/8u171-b11/512cd62ec5174c3487ac17c61aaa89e8/jdk-8u171-linux-x64.rpm
JAVA_BIT_VERSION=x64
JAVA_KEY_VERSION=8u171
JAVA_VERSION=1.8.0_171
cd /tmp

wget -q --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "${JAVA_DOWNLOAD_URL}"

if [ -f jdk-${JAVA_KEY_VERSION}-linux-${JAVA_BIT_VERSION}.rpm ]; then
	echo "Installing Java..."
	rpm -ivh --force jdk-${JAVA_KEY_VERSION}-linux-${JAVA_BIT_VERSION}.rpm
	echo "Update environment variables complete"
fi

java -version
echo "Successfully installed Java"
####################################################################

####################################################################
# Create Jira Response File
####################################################################
# echo "Creating unattended response file..."
# # https://jira.atlassian.com/browse/JRASERVER-36002
# cat > /tmp/response.varfile << EOL
# #rmiPort$Long=8005
# #app.jiraHome=/opt/atlassian/jira-home
# #app.install.service$Boolean=true
# #existingInstallationDir=/opt/JIRA
# #sys.confirmedUpdateInstallationString=false
# #sys.languageId=en
# #sys.installationDir=/opt/atlassian/jira
# #executeLauncherAction$Boolean=true
# #httpPort$Long=8080
# #portChoice=default

# executeLauncherAction$Boolean=true
# app.install.service$Boolean=true
# sys.languageId=en
# sys.installationDir=/opt/atlassian/jira
# EOL
# echo "Completed creating unattended response file"
####################################################################

####################################################################
# Install Jira
####################################################################
echo "Installing Jira..."
JIRA_VERSION=7.10.2
# https://confluence.atlassian.com/adminjiraserver071/unattended-installation-855475683.html
pushd /tmp >/dev/null

# Create application directory
TARGET_DIR=/opt/atlassian/jira
echo "Creating [${TARGET_DIR}]..."
mkdir -p ${TARGET_DIR}

# Download archive
echo "Downloadng archive..."
wget -q -O atlassian-jira-software.tar.gz https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-software-${JIRA_VERSION}.tar.gz
echo "Completed downloading archive"

echo "Untar archive..."
rm -rf /tmp/jira >/dev/null
mkdir /tmp/jira >/dev/null
tar -xzf atlassian-jira-software.tar.gz -C /tmp/jira --strip 1
#ls /tmp/jira
cp -R /tmp/jira/* ${TARGET_DIR}
#cd ${TARGET_DIR}
#tar -xf atlassian-jira-software-*.tar
echo "Completed untaring archive"

# Create user
if ! id -u "jira" >/dev/null 2>&1; then
	echo "Create Jira user..."
	/usr/sbin/useradd --create-home --comment "Account for running JIRA Software" --shell /bin/bash jira
	echo "Completed creating Jira user"
else
	echo "Jira user already exists"
fi

# Set installer permissions
echo "Setting permissions..."
chown -R jira ${TARGET_DIR}
chmod -R u=rwx,go-rwx ${TARGET_DIR}
echo "Completed setting permissions"
#chmod +x atlassian-jira-x64.bin

# Create home directory
echo "Create home directory..."
HOME_DIR=/var/jirasoftware-home
mkdir -p ${HOME_DIR} > /dev/null
chown -R jira ${HOME_DIR}
chmod -R u=rwx,go-rwx ${HOME_DIR}
echo "Completed creating home directory"

# Set user home for application
echo "Set user home for application..."
echo "export JIRA_HOME=${HOME_DIR}" >>/home/jira/.bash_profile
echo "Completed setting user home for application"

# Configure application ports
#echo "Configure application ports..."
#sed -i -e "s|$SEARCH|$REPLACE|g" ${TARGET_DIR}/conf/server.xml
#echo "Completed configuring application ports"

# Start server
#echo "Starting Jira server..."
#su - jira
#cd ${TARGET_DIR}/bin
#./start-jira.sh


# Create systemd file
echo "Create systemd file..."
cat > /etc/systemd/system/jira.service << EOL
[Unit]
Description=Jira service
After=network-online.target

[Service]
User=jira
PrivateDevices=yes
PrivateTmp=yes
ProtectSystem=full
ProtectHome=read-only
SecureBits=keep-caps
Capabilities=CAP_IPC_LOCK+ep
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK
NoNewPrivileges=yes
Environment=JIRA_HOME=${HOME_DIR}
ExecStart=${TARGET_DIR}/bin/start-jira.sh -fg
ExecStartPost=/bin/sleep 3
ExecStartPost=/bin/vault operator unseal $UNSEAL_KEY
KillSignal=SIGINT
TimeoutStopSec=30s
Restart=on-failure
StartLimitInterval=60s
StartLimitBurst=3

[Install]
WantedBy=multi-user.target
EOL

echo "Enable Jira service..."
systemctl enable jira.service
echo "Starting Jira service..."
systemctl start jira.service
echo "Jira service status..."
systemctl status jira.service
echo "Completed creating systemd file"

popd >/dev/null
echo "Completed installing Jira"
####################################################################

echo "Executing [$0] complete"
exit 0
