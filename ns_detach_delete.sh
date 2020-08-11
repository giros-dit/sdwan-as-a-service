#!/bin/bash

USAGE="
Usage:
    
ns_detach_delete <vim_num> <ns_name> <net_num>

    being:
        <vim_num> number of the vim instance (1 or 2) 
        <ns_name>: the name of the network service instance in OSM 
        <net_num>: num for AccessNet and ExtNet 
"

if [[ $# -ne 3 ]]; then
        echo ""       
    echo "ERROR: incorrect number of parameters"
    echo "$USAGE"
    exit 1
fi

DOCKPREFIX="mn.dc$1_$2"
NSNAME=$2

VNFAXS="$DOCKPREFIX-1-access-1"
VNFCPE="$DOCKPREFIX-2-cpe-1"
VNFWAN="$DOCKPREFIX-3-wan-1"

ACCESSNET="AccessNet$3"
EXTNET="ExtNet$3"

sudo ovs-docker del-port AccessNet veth0 $VNFAXS
sudo ovs-docker del-port ExtNet veth0 $VNFCPE
sudo ovs-docker del-port MplsWan veth0 $VNFWAN

osm ns-delete $NSNAME

