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
# Install/Configure Jira
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
cp -R /tmp/jira/* ${TARGET_DIR}
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
mkdir -p ${HOME_DIR} >/dev/null
chown -R jira ${HOME_DIR}
chmod -R u=rwx,go-rwx ${HOME_DIR}
echo "Completed creating home directory"

# Set user home for application
echo "Set user home for application..."
echo "export JIRA_HOME=${HOME_DIR}" >>/home/jira/.bash_profile
echo "export JIRA_OPTS=-Datlassian.darkfeature.jira.onboarding.feature.disabled=true" >>/home/jira/.bash_profile
echo "Completed setting user home for application"

# Configure application ports
#echo "Configure application ports..."
#SEARCH=
#REPLACE=
#sed -i -e "s|$SEARCH|$REPLACE|g" ${TARGET_DIR}/conf/server.xml
#echo "Completed configuring application ports"

# Configure memory
# Ref: https://confluence.atlassian.com/adminjiraserver073/increasing-jira-application-memory-861253796.html
echo "Configure JIRA JVM memory..."
sed -i -e "s|JVM_MAXIMUM_MEMORY=/"768m/"|JVM_MAXIMUM_MEMORY=/"2048m/"|g" ${TARGET_DIR}/bin/setenv.sh
echo "Completed configuring JIRA JVM memory"

# Create systemd file
# Ref: https://community.atlassian.com/t5/Jira-questions/CentOS-7-systemd-startup-scripts-for-Jira-Fisheye/qaq-p/157575
echo "Create systemd file..."
cat >/usr/lib/systemd/system/jira.service <<EOL
[Unit]
Description=JIRA Service
After=network.target

[Service]
Type=forking
User=jira
Environment=JIRA_HOME=${HOME_DIR}
Environment=JIRA_OPTS=-Datlassian.darkfeature.jira.onboarding.feature.disabled=true
PIDFile=${TARGET_DIR}/work/catalina.pid
ExecStart=${TARGET_DIR}/bin/start-jira.sh
ExecStop=${TARGET_DIR}/bin/stop-jira.sh
ExecReload=${TARGET_DIR}/bin/stop-jira.sh | sleep 60 | /${TARGET_DIR}/bin/start-jira.sh

[Install]
WantedBy=multi-user.target
EOL

echo "Enable Jira service..."
systemctl enable jira.service
echo "Completed enabling Jira service"
echo "Starting Jira service..."
systemctl start jira.service
echo "Completed starting Jira service"
echo "Jira service status..."
systemctl status jira.service
echo "Completed Jira status"
echo "Completed creating systemd file"

popd >/dev/null
echo "Completed installing Jira"
####################################################################

####################################################################
# Install/Configure Nginx
####################################################################
# https://confluence.atlassian.com/jirakb/integrating-jira-with-nginx-426115340.html
# https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-centos-7
echo Adding Nginx repository...
yum -y install epel-release

echo Installing Nginx...
yum -y install nginx

# Configure Nginx Sites For
echo "Creating directories..."
mkdir -p /etc/nginx/sites-available
mkdir -p /etc/nginx/sites-enabled
mkdir -p /var/cache/nginx/client_temp
chmod 0777 /var/cache/nginx/client_temp
echo "Completed creating directories"

# Update config file
echo "Editing [/etc/nginx/nginx.conf]..."
SEARCH="include \/etc\/nginx\/conf.d\/\*.conf;"
REPLACE="include \/etc\/nginx\/sites-enabled\/\*.conf;"
sed -i -e "s|$SEARCH|$REPLACE|g" /etc/nginx/nginx.conf
sed -i -e "s|        listen       80 default_server;|#        listen       80 default_server;|g" /etc/nginx/nginx.conf
sed -i -e "s|        listen       \[::\]:80 default_server;|#        listen       \[::\]:80 default_server;|g" /etc/nginx/nginx.conf
sed -i -e "s|        server_name  _;|#        server_name  _;|g" /etc/nginx/nginx.conf
sed -i -e "s|        root         /usr/share/nginx/html;|#        root         /usr/share/nginx/html;|g" /etc/nginx/nginx.conf
echo Return Code: $?
echo "Completed editing [/etc/nginx/nginx.conf]"

# Remove contents of /etc/nginx/conf.d
echo "Removing [/etc/nginx/conf.d/*]..."
rm -f /etc/nginx/conf.d/*
echo "Completed [/etc/nginx/conf.d/*]"

# HTTP/S Configuration
SERVER_NAME="localhost"
DNS="gatt-nexus-oss.pwcinternal.com"
SERVER_PORT="80"
cat >/etc/nginx/sites-available/jira.conf <<EOL
server {
        listen 80 default_server;
        listen [::]:80 default_server;
        server_name _;
        return 301 https://\$host\$request_uri;
}


server {
        #listen 80 default_server;
        #listen [::]:80 default_server;
        #server_name localhost;

        # SSL listener
        #listen 443 ssl;
        #listen [::]:443 default_server;
        #server_name ${SERVER_NAME} ${DNS} ;

        # SSL Certificates / Configuration
        #ssl on;
        #ssl_certificate     /etc/ssl/${DNS}.cer;
        #ssl_certificate_key /etc/ssl/${DNS}.key;

        # allow large uploads of files - refer to nginx documentation
        client_max_body_size 1G;
        # optimize downloading files larger than 1G - refer to nginx doc before adjusting
        #proxy_max_temp_file_size 2G;

        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto "https";
        location / {
                proxy_pass http://localhost:8080;
        }
}

EOL

# Enable the configuration by creating symbolic link (Incomplete)
ln -sf /etc/nginx/sites-available/jira.conf /etc/nginx/sites-enabled/jira.conf

# Validate nginx configuration file
echo "Validating Nginx confiugration file..."
nginx -t
echo "Completed validating Nginx confiugration file"

# Allow http and https ports through firewall
if [ $(systemctl -q is-active firewalld) ]; then
	firewall-cmd --permanent --zone=public --add-service=http
	firewall-cmd --permanent --zone=public --add-service=https
	firewall-cmd --reload
fi

# Restart Nginx
echo "Starting Nginx service..."
systemctl start nginx
systemctl enable nginx
# Configure selinux
setsebool -P httpd_can_network_connect 1
echo "Completed restarting Nginx service"

####################################################################

echo "Executing [$0] complete"
exit 0
