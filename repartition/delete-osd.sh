#!/bin/bash

source rook.sh
source create-osd-purge-job.sh

delete_osd() {

    stop_rookoperator

    findosd $NODE_NAME
    echo $OSD_NAME
    echo $$OSD_ID

    findrooktoolbox
    echo $ROOK_TOOLBOX
    
    markosddown

    create_osd_purge_job

    runpurgejob
}

markosddown() {
    kubectl -n $NAMESPACE scale deployment rook-ceph-osd-$OSD_ID --replicas=0
    kubectl exec -it -n $NAMESPACE $ROOK_TOOLBOX -- ceph osd down $OSD_NAME
}

wait_for_job_completion() {
    kubectl wait --for=condition=complete job/osd-purge-job-osd-$OSD_ID -n $NAMESPACE
}

runpurgejob() {
    kubectl apply -f out/osd-purge-job-osd-$OSD_ID.yaml
    echo "waiting for purge job to complete"
    wait_for_job_completion
    echo "purge job completed"
}