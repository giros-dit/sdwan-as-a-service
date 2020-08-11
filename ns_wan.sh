#!/bin/bash

USAGE="
Usage:
    
ns_wan <vim_num> <ns_name> <wan_net>
    where:
        <vim_num>: number of the vim instance (1 or 2) 
        <ns_name>: name of the network service instance in OSM 
        <wan_net>: name of the bridge representing the wan network
"

if [[ $# -ne 3 ]]; then
        echo ""       
    echo "ERROR: incorrect number of parameters"
    echo "$USAGE"
    exit 1
fi

DOCKPREFIX="mn.dc$1_$2"

#VNFAXS="$DOCKPREFIX-1-access-1"
VNFCPE="$DOCKPREFIX-2-cpe-1"
VNFWAN="$DOCKPREFIX-3-wan-1"

WANNET="$3"

## 1. Engancha el contenedor a la red externa
sudo ovs-docker add-port $WANNET veth0 $VNFWAN
## 2. Engancha la red externa al switch
sudo docker exec -it $VNFWAN ovs-vsctl add-port brwan veth0
