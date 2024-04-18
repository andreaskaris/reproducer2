#!/bin/bash

# Start both pods at the same time and wait for 30 seconds for the other side.
sleep 30
LOCAL_IP=$(kubectl get pods -l app=blue -o jsonpath='{.items[0].status.podIPs[0].ip}')
REMOTE_IP=$(kubectl get pods -l app=red -o jsonpath='{.items[0].status.podIPs[0].ip}')

ip link add gen0 type geneve id 1 remote "${REMOTE_IP}"
ip link set dev gen0 up
ip a a dev gen0 2001::1/64

ip link add tap0 type gretap local "${LOCAL_IP}" remote "${REMOTE_IP}" ikey 0.0.0.1 okey 0.0.0.1
ip link set dev tap0 up
ip a a dev tap0 2000::1/64

FEATURES="tcp-segmentation-offload generic-segmentation-offload generic-receive-offload large-receive-offload tx-checksumming scatter-gather rx-vlan-offload highdma rx-vlan-filter tx-gre-segmentation tx-gre-csum-segmentation tx-ipxip4-segmentation tx-ipxip6-segmentation tx-udp_tnl-segmentation tx-udp_tnl-csum-segmentation tx-esp-segmentation tx-udp-segmentation esp-hw-offload esp-tx-csum-hw-offload tx-sctp-segmentation tx-gso-list rx-checksumming receive-hashing tx-gso-partial rx-all rx-checksumming receive-hashing tx-gso-partial rx-all tx-vlan-stag-hw-insert tx rx rx-udp-gro-forwarding rx-vlan-stag-hw-parse rx-gro-hw scatter-gather"
INTERFACES=$(ip --json link | jq -r '.[].ifname')
for interface in ${INTERFACES}; do
  for feature in ${FEATURES}; do
    ethtool -K "${interface}" "${feature}" ${SWITCH_ON_OFF}
  done
done

sleep infinity
