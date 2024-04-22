#!/bin/bash

set -x

DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "${DIR}/common.sh"

# Start all 3 pods at the same time and wait for 30 seconds for the other side.
sleep 30

get_ips
IP_AF="${IP_AF:IPv6}"

ip link add tap1 type gretap local "${RED_IP}" remote "${BLUE_IP}" ikey 0.0.0.1 okey 0.0.0.1
ip link set dev tap1 up
if [ "${IP_AF}" == "IPv4" ]; then
  ip a a dev tap1 192.168.124.1/24
  ip r a 192.168.123.0/24 via 192.168.124.2
else
  ip a a dev tap1 2001::1/64
  ip r a 2000::/64 via 2001::2
fi

disable_offloading

nc -k -l 5060

sleep infinity
