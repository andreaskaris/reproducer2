#!/bin/bash

set -x

DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "${DIR}/common.sh"

# Start all 3 pods at the same time and wait for 30 seconds for the other side.
sleep 30

get_ips

ip link add tap0 type gretap local "${GREEN_IP}" remote "${BLUE_IP}" ikey 0.0.0.1 okey 0.0.0.1
ip link set dev tap0 up
ip a a dev tap0 2000::1/64
ip link set dev tap0 mtu ${SENDER_MTU:-1280}
ip r a 2001::/64 via 2000::2

disable_offloading

while true; do
    bash /entrypoint/send-sip.sh 2001::1 5060 long
    sleep 5
done

sleep infinity
