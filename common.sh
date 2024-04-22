#!/bin/bash

get_ips() {
  export GREEN_IP
  export GREEN_IP=$(kubectl get pods -l app=green -o jsonpath='{.items[0].status.podIPs[0].ip}')
  export BLUE_IP
  export BLUE_IP=$(kubectl get pods -l app=blue -o jsonpath='{.items[0].status.podIPs[0].ip}')
  export RED_IP
  export RED_IP=$(kubectl get pods -l app=red -o jsonpath='{.items[0].status.podIPs[0].ip}')
}

disable_offloading() {
  FEATURES="tcp-segmentation-offload generic-segmentation-offload generic-receive-offload large-receive-offload tx-checksumming scatter-gather rx-vlan-offload highdma rx-vlan-filter tx-gre-segmentation tx-gre-csum-segmentation tx-ipxip4-segmentation tx-ipxip6-segmentation tx-udp_tnl-segmentation tx-udp_tnl-csum-segmentation tx-esp-segmentation tx-udp-segmentation esp-hw-offload esp-tx-csum-hw-offload tx-sctp-segmentation tx-gso-list rx-checksumming receive-hashing tx-gso-partial rx-all rx-checksumming receive-hashing tx-gso-partial rx-all tx-vlan-stag-hw-insert tx rx rx-udp-gro-forwarding rx-vlan-stag-hw-parse rx-gro-hw scatter-gather"
  INTERFACES=$(ip --json link | jq -r '.[].ifname')
  SWITCH_ON_OFF="off"
  for interface in ${INTERFACES}; do
    for feature in ${FEATURES}; do
      ethtool -K "${interface}" "${feature}" ${SWITCH_ON_OFF}
    done
  done
}
