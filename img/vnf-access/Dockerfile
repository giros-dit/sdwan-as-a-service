FROM ubuntu:xenial
# install required packages
RUN apt-get clean
RUN apt-get update \
    && apt-get install -y \
    net-tools \
    traceroute \
    build-essential \
    inetutils-ping \
    bridge-utils \
    tcpdump \
    openvswitch-switch \
    openvswitch-common \
    iperf \
    curl \
    nano \
    vim

ADD start_access.sh start.sh
RUN chmod +x start.sh

# set entry point for emulator gatekeeper
ENV SON_EMU_CMD "./start.sh"

CMD /bin/bash

