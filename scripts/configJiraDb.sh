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

echo "Display all arguments"
echo $@

#################################################################
# Check if run as root
#################################################################
#if [ ! $(id -u) -eq 0 ]; then
#    echo "ERROR: Script [$0] must be run as root, Script terminating"
#    exit 7
#fi
#################################################################

################################################################################
# BEGIN : Functions
################################################################################
#Help function
function usage() {
	echo -e \\n"Help documentation for $PROGNAME"\\n
	echo -e "Usage: $PROGNAME -s <servername> -u <username> -p <password>"\\n
	echo -e "Example: $PROGNAME -s server -u username -p password "\\n
	exit 1
}
################################################################################
# END : Functions
################################################################################

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

while getopts ":s:u:p:h" OPT; do
	case ${OPT} in
	s) #set option "s"
		SERVER=$(echo "${OPTARG}")
		#echo "-s used: $OPTARG"
		echo "SERVER = [$SERVER]"
		;;
	u) #set option "u"
		USER=$(echo "${OPTARG}")
		#echo "-u used: $OPTARG"
		echo "USER = [$USER]"
		;;
	p) #set option "p"
		PASSWORD=$(echo "${OPTARG}")
		#echo "-p used: $OPTARG"
		echo "PASSWORD = [$PASSWORD]"
		;;
	t)
		TESTING='TRUE'
		;;
	h) #show help
		usage
		;;
	#\?) #unrecognized option - show help
	#	echo -e \\n"Option -${BOLD}$OPTARG${NORM} not allowed."
	#	usage
	#	#If you just want to display a simple error message instead of the full
	#	#help, remove the 2 lines above and uncomment the 2 lines below.
	#	#echo -e "Use ${BOLD}$SCRIPT -h${NORM} to see the help documentation."\\n
	#	#exit 2
	#	;;
	esac
done

shift $((OPTIND - 1)) #This tells getopts to move on to the next argument.

### End getopts code ###
#}
#process_args


################################################################################
# Verify we were passed required parameters
################################################################################
if [ "${SERVER}" == '' ]; then
	echo "Missing required parameter for Server (-s option)" 1>&2
	exit 1
fi
if [ "${USER}" == '' ]; then
	echo "Missing required parameter for User (-u option)" 1>&2
	exit 1
fi
if [ "${PASSWORD}" == '' ]; then
	echo "Missing required parameter for Password(-p option)" 1>&2
	exit 1
fi
################################################################################

################################################################################
# Display passed variabled when using -t switch
################################################################################
if [ "${TESTING}" == 'TRUE' ] ; then
    echo "Server: [${SERVER}]"
fi
if [ "${TESTING}" == 'TRUE' ] ; then
    echo "User: [${USER}]"
fi
if [ "${TESTING}" == 'TRUE' ] ; then
    echo "Password: [${PASSWORD}]"
fi
################################################################################

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
