#!/bin/bash

source rook.sh
source create-osd-purge-job.sh

delete_osd() {

    markosddown

    create_osd_purge_job
    read -p "Ready to run purge job...Press Enter to continue..."

    runpurgejob

    deletepurgejob
}

markosddown() {
    kubectl -n $NAMESPACE scale deployment rook-ceph-osd-$OSD_ID --replicas=0
    kubectl exec -it -n $NAMESPACE $ROOK_TOOLBOX -- ceph osd down $OSD_NAME
}

wait_for_job_completion() {
    kubectl wait --for=condition=complete job/rook-ceph-purge-osd-$OSD_ID -n $NAMESPACE
}

runpurgejob() {
    deletepurgejob # delete job if it already exists
    kubectl apply -f out/osd-purge-job-osd-$OSD_ID.yaml
    echo "waiting for purge job to complete"
    wait_for_job_completion
    echo "purge job completed"
}

deletepurgejob() {
    kubectl delete -f out/osd-purge-job-osd-$OSD_ID.yaml
}

clean_host() {
    save_dir=$(pwd)
    cd $ANSIBLE_REPO_PATH

    ansible-playbook -i $ANSIBLE_REPO_PATH/inventory/$CLUSTER/hosts.yml $ANSIBLE_REPO_PATH/playbooks/rook-ceph.yml -t rook-clean -l $NODE_NAME 

    cd $save_dir
}