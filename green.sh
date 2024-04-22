#!/bin/bash

set -x

DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "${DIR}/common.sh"

# Start all 3 pods at the same time and wait for 30 seconds for the other side.
sleep 30

get_ips
IP_AF="${IP_AF:IPv6}"

ip link add tap0 type gretap local "${GREEN_IP}" remote "${BLUE_IP}" ikey 0.0.0.1 okey 0.0.0.1
ip link set dev tap0 up
ip link set dev tap0 mtu ${SENDER_MTU:-1280}
if [ "${IP_AF}" == "IPv4" ]; then
  ip a a dev tap0 192.168.123.1/24
  ip r a 192.168.124.0/24 via 192.168.123.2
else
  ip a a dev tap0 2000::1/64
  ip r a 2001::/64 via 2000::2
fi

disable_offloading

while true; do
  if [ "${IP_AF}" == "IPv4" ]; then
    bash /entrypoint/send-sip.sh 192.168.124.1 5060 long
  else
    bash /entrypoint/send-sip.sh 2001::1 5060 long
  fi
  sleep 5
done

sleep infinity
