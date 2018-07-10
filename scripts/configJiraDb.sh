#!/bin/bash
###################################################################
# Script Name	:  configJiraDb.sh
# Description	:  Configure Jira database
# Args          :  None
# Author        :  Cory R. Stein
# Reference     :  http://tuxtweaks.com/2014/05/bash-getopts/
###################################################################

echo "Executing [$0]..."
PROGNAME=$(basename $0)

set -e

#Help function
function usage() {
	echo -e \\n"Help documentation for ${BOLD}${SCRIPT}.${NORM}"\\n
	echo -e "${REV}Basic usage:${NORM} ${BOLD}$SCRIPT"\\n
	echo "Command line switches are optional. The following switches are recognized."
	echo "${REV}-s${NORM}  --Sets the value for option ${BOLD}s${NORM}."
	echo "${REV}-u${NORM}  --Sets the value for option ${BOLD}u${NORM}."
	echo "${REV}-p${NORM}  --Sets the value for option ${BOLD}p${NORM}."
	echo -e "${REV}-h${NORM}  --Displays this help message. No further functions are performed."\\n
	echo -e "Example: ${BOLD}$SCRIPT -s server -u username -p password "\\n
	exit 1
}

#Check the number of arguments. If none are passed, print help and exit.
NUMARGS=$#
echo -e \\n"Number of arguments: $NUMARGS"
if [ $NUMARGS -eq 0 ]; then
	usage
fi

#function process_args() {
### Start getopts code ###

#Parse command line flags
#If an option should be followed by an argument, it should be followed by a ":".
#Notice there is no ":" after "h". The leading ":" suppresses error messages from
#getopts. This is required to get my unrecognized option code to work.

while getopts :s:u:p:h FLAG; do
	case $FLAG in
	s) #set option "a"
		SERVER=$OPTARG
		echo "-s used: $OPTARG"
		echo "SERVER = $SERVER"
		;;
	u) #set option "a"
		USER=$OPTARG
		echo "-u used: $OPTARG"
		echo "USER = $USER"
		;;
	p) #set option "a"
		PASSWORD=$OPTARG
		echo "-p used: $OPTARG"
		echo "PASSWORD = $PASSWORD"
		;;
	h) #show help
		usage
		;;
	\?) #unrecognized option - show help
		echo -e \\n"Option -${BOLD}$OPTARG${NORM} not allowed."
		usage
		#If you just want to display a simple error message instead of the full
		#help, remove the 2 lines above and uncomment the 2 lines below.
		#echo -e "Use ${BOLD}$SCRIPT -h${NORM} to see the help documentation."\\n
		#exit 2
		;;
	esac
done

shift $((OPTIND - 1)) #This tells getopts to move on to the next argument.

### End getopts code ###
#}
#process_args

####################################################################
# Install packages
####################################################################
yum install -y curl
curl https://packages.microsoft.com/config/rhel/7/prod.repo >/etc/yum.repos.d/msprod.repo
yum install -y mssql-tools unixODBC-devel

echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >>~/.bash_profile
####################################################################

####################################################################
# Update database config file
####################################################################

####################################################################

####################################################################
# Create empty database
####################################################################

####################################################################

echo "Executing [$0] complete"
exit 0
