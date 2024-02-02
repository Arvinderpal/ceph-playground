# Overview

Scripts to repartition an existing partition that has a ceph osd on it. 

# Steps

export ANSIBLE_REPO_PATH="/no/path/specified"
export CLUSTER="cluster-1"
export NODE_NAME="my-node-1"
export DEVICE="nvme0n1
export CEPH_PARTITION_NUMBER=4
./main.sh

# Bulk

export node_names=("node1" "node2" "node3")
for node_name in "${node_names[@]}"
do
    export ANSIBLE_REPO_PATH="/no/path/specified"
    export CLUSTER="cluster-1"
    export DEVICE="nvme0n1"
    export CEPH_PARTITION_NUMBER=4
    export NODE_NAME="$node_name"
    ./main.sh
    sleep 600
done