#!/bin/bash

stop_rookoperator() {
    kubectl -n $NAMESPACE scale deployment rook-ceph-operator --replicas=0
}
    
start_rookoperator() {
    kubectl -n $NAMESPACE scale deployment rook-ceph-operator --replicas=1
}

findosd() {
    OSD_POD=$(kubectl get pods -n $NAMESPACE -l app=rook-ceph-osd -o jsonpath="{.items[?(@.spec.nodeName=='$NODE_NAME')].metadata.name}")

    OSD_ID=$(kubectl get pod -n $NAMESPACE $OSD_POD -o jsonpath="{.metadata.labels['ceph-osd-id']}")
    OSD_NAME="osd.$OSD_ID"
    echo "OSD pod running on $NODE_NAME: $OSD_POD: $OSD_NAME"
}

findrooktoolbox() {
    ROOK_TOOLBOX=$(kubectl get pods -n $NAMESPACE | grep "^rook-ceph-tools" | awk '{print $1}')
    if [ -z "$ROOK_TOOLBOX" ]; then
        echo "ROOK_TOOLBOX is empty. Exiting script."
        exit 1
    fi
}


