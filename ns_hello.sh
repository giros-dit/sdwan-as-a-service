#!/bin/bash

USAGE="
Usage:
    
ns_corporate <vim_num> <ns_name> 
    where:
        <vim_num>: number of the vim instance (1 or 2) 
        <ns_name>: name of the network service instance in OSM 
"

if [[ $# -ne 2 ]]; then
        echo ""       
    echo "ERROR: incorrect number of parameters"
    echo "$USAGE"
    exit 1
fi

DOCKPREFIX="mn.dc$1_$2"

VNFAXS="$DOCKPREFIX-1-access-1"
VNFCPE="$DOCKPREFIX-2-cpe-1"

## 0. Probar acceso a VNFs
sudo docker exec -it $VNFAXS echo "Hello from $VNFAXS"
sudo docker exec -it $VNFCPE echo "Hello from $VNFCPE"

