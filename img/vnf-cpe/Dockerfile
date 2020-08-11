FROM vnf-access
# install required packages
RUN apt-get clean
RUN apt-get update \
    && apt-get install -y \
	iproute \
    iptables 

COPY vnx_config_nat vnx_config_nat

ADD start_cpe.sh start.sh
RUN chmod +x start.sh vnx_config_nat

# set entry point for emulator gatekeeper
ENV SON_EMU_CMD "./start.sh"

CMD /bin/bash

