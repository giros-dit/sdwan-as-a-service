FROM      osrg/ryu

RUN apt-get clean
RUN	apt-get update && apt-get install -y \
	net-tools \
	iproute \
	inetutils-ping \
    openvswitch-switch \
    openvswitch-common \
    iperf \
    tcpdump \
    python-pip \
    git

#RUN pip install -r ryu/tools/optional-requires
RUN git clone https://github.com/martimy/flowmanager

ADD start_wan.sh start.sh
RUN chmod +x start.sh

# set entry point for emulator gatekeeper
ENV SON_EMU_CMD "./start.sh"

CMD /bin/bash

