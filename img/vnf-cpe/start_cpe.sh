#! /bin/bash

# Function to calculate the previous IP address
previp(){
    IP=$1
    IP_HEX=$(printf '%.2X%.2X%.2X%.2X\n' `echo $IP | sed -e 's/\./ /g'`)
    PREV_IP_HEX=$(printf %.8X `echo $(( 0x$IP_HEX - 1 ))`)
    PREV_IP=$(printf '%d.%d.%d.%d\n' `echo $PREV_IP_HEX | sed -r 's/(..)/0x\1 /g'`)
    echo "$PREV_IP"
}

# Function to calculate the next IP address
nextip(){
    IP=$1
    IP_HEX=$(printf '%.2X%.2X%.2X%.2X\n' `echo $IP | sed -e 's/\./ /g'`)
    NEXT_IP_HEX=$(printf %.8X `echo $(( 0x$IP_HEX + 1 ))`)
    NEXT_IP=$(printf '%d.%d.%d.%d\n' `echo $NEXT_IP_HEX | sed -r 's/(..)/0x\1 /g'`)
    echo "$NEXT_IP"
}

echo "CPE container started"
PORT="cpe0"
# actual port to find out X in port name cpe0-X
ACTUAL_PORT=`ifconfig | grep $PORT | awk '{print $1}'`

IP=`hostname -I | awk '{printf "%s\n", $1}{print $2}' | grep 192.168.100`

# assume access VNF is assigned previous IP address
IPACCESS=$(previp $IP)
IPWAN=$(nextip $IP)

echo "Start ovs"
service openvswitch-switch start

echo "Create bridges"
ovs-vsctl add-br brint
ovs-vsctl add-br brwan

echo "Create vxlan tunnel to access vnf"
ovs-vsctl add-port brint axscpe -- set interface axscpe type=vxlan options:remote_ip=$IPACCESS options:key=inet options:dst_port=8742

echo "Create vxlan tunnel to wan vnf"
ovs-vsctl add-port brwan cpewan -- set interface cpewan type=vxlan options:remote_ip=$IPWAN options:key=sdwn options:dst_port=8741

ifconfig brint mtu 1400
ip route del 0.0.0.0/0 via 172.17.0.1

echo "Configure downlink bandwidth limit for VXLAN (UDP) traffic"
tc qdisc add dev $ACTUAL_PORT root  handle 1: htb default 1
tc class add dev $ACTUAL_PORT parent 1: classid 1:10 htb rate 50Mbit ceil 50Mbit
tc filter add dev $ACTUAL_PORT protocol ip u32 match ip protocol 0x11 0xff match ip dport 8742 0xffff flowid 1:10
