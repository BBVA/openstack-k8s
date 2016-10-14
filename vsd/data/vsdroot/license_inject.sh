#!/bin/bash

#set -x

usage ()
{
    echo "Usage: $0 [OPTIONS]"
    echo "This script set a license via VSD REST API"
    echo " "
    echo "  --user USER                     User to access Nuage API"
    echo "  --password PASSWORD             Password to access Nuage API"
    echo " "
    echo "  --help                          Display this help and exit"
    echo "  --version                       Print version information and exit"
    echo " "
}

error ()
{
    echo "Usage: $0 [OPTIONS]"
    echo "Try \`$0 --help' for more information."
        echo ""
}

version ()
{
    echo "$0 (Non Warranty Utils) 1.0"
    echo " "
        echo ""
}

USER="csproot"
PASSWORD="csproot"
SITE="https://127.0.0.1:8443"
LICENSE_FILE="/root/license.lic"

# Check if any of the values is missing or empty
if [ "${USER:-"null"}" == null -o "${PASSWORD:-"null"}" == null -o "${SITE:-"null"}" == null ] ; then error ; exit 1 ; fi

AUTH=$(echo -n $USER:$PASSWORD | base64)

KEY=$(curl -s -k --header "X-Nuage-Organization: csp" --header "Content-Type: application/json" --header "Authorization: Basic $AUTH" $SITE/nuage/api/v4_0/me | sed 's/[',',{,}]/\n&/g' | grep '^,"APIKey"' | awk -F: '{print $2}' | sed -e 's/"//g')

if [ -z "$KEY" ] ; then
        echo "ERROR: Cannot obtain Auth Key on $SITE"
        exit 3
fi

SESSION=$(echo -n $USER:$KEY | base64)

EXITSTATUS=0

echo "INFO: CARGANDO LA LICENCIA"

curl -ks -X POST -H "X-Nuage-Organization: csp" -H "Content-Type: application/json" -H "Authorization: Basic $SESSION" -d  '{"clusteringEnabled":"false","license":"'$(< $LICENSE_FILE)'"}' $SITE/nuage/api/v4_0/licenses | sed 's/[',',{,}]/\n&/g'

if [ $EXITSTATUS -ne 0 ] ; then
        echo "WARNING: PROBLEMA AL CARGAR LA LICENCIA"
        exit 2
else
        echo "INFO: LICENCIA CARGADA CORRECTAMENTE"
        exit 0
fi

