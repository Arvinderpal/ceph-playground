#!/bin/bash

source rook.sh
source create-osd-purge-job.sh

delete_osd() {

    markosddown
    read -p "Press Enter to continue..."

    create_osd_purge_job
    read -p "Press Enter to continue..."

    runpurgejob
    read -p "Press Enter to continue..."

    deletepurgejob
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

deletepurgejob() {
    kubectl delete -f out/osd-purge-job-osd-$OSD_ID.yaml
}