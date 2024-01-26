#!/bin/bash
# enable debug mode and exit on error
set -ex

source delete-osd.sh

NAMESPACE="gitops-platform-storage"
ROOK_TOOLBOX="rook-ceph-tools-unknown"

# Define NODE_NAME variable with default value
if [ -z "$NODE_NAME" ]; then
    NODE_NAME="no-node-specified"
fi

# Check if NODE_NAME has been overridden by the user
if [ "$NODE_NAME" = "no-node-specified" ]; then
    echo "Error: NODE_NAME not specified. Please provide a value for NODE_NAME."
    exit 1
fi

# Check if CLUSTER is specified
if [ -z "$CLUSTER" ]; then
    echo "Error: CLUSTER not specified. Please provide a value for CLUSTER."
    exit 1
fi

# Check if ANSIBLE_REPO_PATH is specified
if [ -z "$ANSIBLE_REPO_PATH" ]; then
    echo "Error: ANSIBLE_REPO_PATH not specified. Please provide a value for ANSIBLE_REPO_PATH."
    exit 1
fi

# Check if DEVICE is specified
if [ -z "$DEVICE" ]; then
    echo "Error: DEVICE not specified. Please provide a value for DEVICE."
    exit 1
fi

# Check if CEPH_PARTITION_NUMBER is specified and equal to 4
if [[ "$CEPH_PARTITION_NUMBER" != "4" ]]; then
    echo "Error: PARTITION number of 4 not specified. Current script only supports nvme0n1p4"
    exit 1
fi

# 1. delete osd(s)
# 2. clean host (ansible)
# 3. repartition
# 4. start_rookoperator

findrooktoolbox

stop_rookoperator

# NB: this is meant to support mulitple OSDs on the same node but the other parts of this script are only meant for nvme0n1p4 partitions. Additional work is required to support disks instead of just a singl partition.
while true; do
    findosd $NODE_NAME
    if [ -z "$OSD_POD" ]; then
        break
    fi
    delete_osd $NODE_NAME
done

read -p "Ready to clean host...Press Enter to continue..."
clean_host $NODE_NAME

shrink_partition $NODE_NAME

read -p "Ready to restart rook-operator...Press Enter to continue..."
start_rookoperator
