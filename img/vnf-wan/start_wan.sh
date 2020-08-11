#! /bin/bash

# Function to calculate the previous IP address
previp(){
    IP=$1
    IP_HEX=$(printf '%.2X%.2X%.2X%.2X\n' `echo $IP | sed -e 's/\./ /g'`)
    PREV_IP_HEX=$(printf %.8X `echo $(( 0x$IP_HEX - 1 ))`)
    PREV_IP=$(printf '%d.%d.%d.%d\n' `echo $PREV_IP_HEX | sed -r 's/(..)/0x\1 /g'`)
    echo "$PREV_IP"
}

echo "WAN container started"
PORT="wan0"
# actual port to find out X in port name cpe0-X
ACTUAL_PORT=`ifconfig | grep $PORT | awk '{print $1}'`

IP=`hostname -I | awk '{printf "%s\n", $1}{print $2}' | grep 192.168.100`

# assume cpe VNF is assigned previous IP address
IPCPE=$(previp $IP)
IPACCESS=$(previp $IPCPE)
OVS_DPID="0000000000000001"

echo "start ryu ad-hoc switch"
ryu-manager --verbose flowmanager/flowmanager.py ryu.app.ofctl_rest 2>&1 | tee ryu.log &

echo "Start ovs"
service openvswitch-switch start

echo "Create bridge"
ovs-vsctl add-br brwan
ovs-vsctl set bridge brwan protocols=OpenFlow10,OpenFlow12,OpenFlow13
ovs-vsctl set-fail-mode brwan secure
ovs-vsctl set bridge brwan other-config:datapath-id=$OVS_DPID

echo "Create vxlan tunnel to access vnf"
ovs-vsctl add-port brwan axswan -- set interface axswan type=vxlan options:remote_ip=$IPACCESS

echo "Create vxlan tunnel to cpe vnf"
ovs-vsctl add-port brwan cpewan -- set interface cpewan type=vxlan options:remote_ip=$IPCPE options:key=sdwn options:dst_port=8741

CONTROLLER_IP="127.0.0.1"
CONTROLLER="tcp:$CONTROLLER_IP:6633"
ovs-vsctl set-controller brwan $CONTROLLER
sleep 2

echo "Create default rules to switch traffic through MLPS"
ovs-ofctl add-flow brwan in_port=1,actions=output:3
ovs-ofctl add-flow brwan in_port=3,actions=output:1

ifconfig brwan mtu 1400
ip route del 0.0.0.0/0 via 172.17.0.1

