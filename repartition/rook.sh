#!/bin/bash

stop_rookoperator() {
    kubectl -n rook-ceph scale deployment rook-ceph-operator --replicas=0
}
    
start_rookoperator() {
    kubectl -n rook-ceph scale deployment rook-ceph-operator --replicas=1
}

findosd() {
    NODE_NAME=$1
    # Find OSD on the specified node
    OSD_NAME="osd1" # Replace with the actual OSD name
    OSD_ID="0" # Replace with the actual OSD ID
}

findrooktoolbox() {
    ROOK_TOOLBOX=$(kubectl get pods -n rook-ceph | grep "^rook-ceph-tools" | awk '{print $1}')
}

