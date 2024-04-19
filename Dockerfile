FROM registry.fedoraproject.org/fedora-minimal
RUN microdnf install tcpdump strace iproute \
    iputils net-tools ethtool kubernetes-client \
    iperf3 python3 python3-pip ncat jq -y && microdnf clean all
RUN pip install scapy
