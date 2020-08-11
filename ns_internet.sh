#!/bin/bash

USAGE="
Usage:
    
ns_internet <vim_num> <ns_name> <access_net> <ext_net> <vnf_tunnel_ip> <cus_tunnel_ip> <vcpe_public_ip> <vcpe_default_gw>
    where:
        <vim_num>: number of the vim instance (1 or 2) 
        <ns_name>: name of the network service instance in OSM 
        <access_net>: name of the bridge representing an access network
        <ext_net>: name of the bridge representing an access network
        <vnf_tunnel_ip>: private ip address for the vnf side of the tunnel
        <cus_tunnel_ip>: private ip address for the customer side of the tunnel
        <vcpe_public_ip>: public ip address for the cpe service (e.g. 10.2.3.2)
        <vcpe_default_gw>: ip address for the gateway to Internet (e.g. 10.2.3.254)
"

if [[ $# -ne 8 ]]; then
        echo ""       
    echo "ERROR: incorrect number of parameters"
    echo "$USAGE"
    exit 1
fi

DOCKPREFIX="mn.dc$1_$2"

VNFAXS="$DOCKPREFIX-1-access-1"
VNFCPE="$DOCKPREFIX-2-cpe-1"

ACCESSNET="$3"
EXTNET="$4"
VNFTUNIP="$5"
CUSTUNIP="$6"
VCPEPUBIP="$7"
VCPEGW="$8"

VCPEPRIVIP="192.168.255.254"

##################### VNFs Settings #####################
echo "--"
echo "--Connecting network service with AccessNet and ExtNet..."

## 1. Engancha los contenedores a las redes externas
sudo ovs-docker add-port $ACCESSNET veth0 $VNFAXS
sudo ovs-docker add-port $EXTNET veth0 $VNFCPE

echo "--"
echo "--Setting VNF:cpe..."

## 2. En VNF:cpe configurar la IP privada y la pública
sudo docker exec -it $VNFCPE /sbin/ifconfig brint $VCPEPRIVIP/24
sudo docker exec -it $VNFCPE /sbin/ifconfig veth0 $VCPEPUBIP/24
sudo docker exec -it $VNFCPE /sbin/ip route add default via $VCPEGW

## 3. En VNF:cpe activar NAT para dar salida a Internet 
sudo docker exec -it $VNFCPE /vnx_config_nat brint veth0

echo "--"
echo "--Setting VNF:access..."

## 4. En VNF:access configurar la IP externa y crear los túneles VXLAN con brg 
sudo docker exec -it $VNFAXS ifconfig veth0 $VNFTUNIP/24
sudo docker exec -it $VNFAXS ovs-vsctl add-port brint vxlan2 -- set interface vxlan2 type=vxlan options:remote_ip=$CUSTUNIP options:key=inet options:dst_port=8742
sudo docker exec -it $VNFAXS ovs-vsctl add-port brwan vxlan1 -- set interface vxlan1 type=vxlan options:remote_ip=$CUSTUNIP

