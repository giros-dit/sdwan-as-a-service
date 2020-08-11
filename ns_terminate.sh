#!/bin/bash

USAGE="
Usage:
    
ns_terminate <ns_name>

    where:
        <ns_name>: the name of the network service instance in OSM 
"

if [[ $# -ne 1 ]]; then
        echo ""       
    echo "ERROR: incorrect number of parameters"
    echo "$USAGE"
    exit 1
fi

NSNAME=$1
NETNUM="${NSNAME: -1}"
VIMNUM=$NETNUM
./ns_detach_delete.sh $VIMNUM $NSNAME $NETNUM



