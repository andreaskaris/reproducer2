#!/bin/bash

# Start both pods at the same time and wait for 30 seconds for the other side.
sleep 30
LOCAL_IP=$(kubectl get pods -l app=red -o jsonpath='{.items[0].status.podIPs[0].ip}')
REMOTE_IP=$(kubectl get pods -l app=blue -o jsonpath='{.items[0].status.podIPs[0].ip}')

ip link add gen0 type geneve id 1 remote "${REMOTE_IP}"
ip link set dev gen0 up
ip a a dev gen0 2001::2/64

ip link add tap0 type gretap local "${LOCAL_IP}" remote "${REMOTE_IP}" ikey 0.0.0.1 okey 0.0.0.1
ip link set dev tap0 up
ip a a dev tap0 2000::2/64

sleep infinity
