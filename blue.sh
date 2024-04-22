#!/bin/bash

set -x

DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "${DIR}/common.sh"

# Start all 3 pods at the same time and wait for 30 seconds for the other side.
sleep 30

get_ips

ip link add tap0 type gretap local "${BLUE_IP}" remote "${GREEN_IP}" ikey 0.0.0.1 okey 0.0.0.1
ip link set dev tap0 up
ip link set dev tap0 mtu ${SENDER_MTU:-1280}
ip a a dev tap0 2000::2/64

ip link add tap1 type gretap local "${BLUE_IP}" remote "${RED_IP}" ikey 0.0.0.1 okey 0.0.0.1
ip link set dev tap1 up
ip a a dev tap1 2001::2/64

echo 1 > /proc/sys/net/ipv6/conf/all/forwarding

disable_offloading

sleep infinity
