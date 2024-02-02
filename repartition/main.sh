#!/bin/bash
# enable debug mode and exit on error
set -ex

source delete-osd.sh
source partition.sh

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
# 5. wait for osd(s) to come back up

findrooktoolbox

stop_rookoperator

skip_choice="n"
clean_host_choice="n"
shrink_choice="n"
start_choice="n"

for arg in "$@"
do
    case $arg in
        --skip-delete-osd)
            skip_choice="y"
            ;;
        --skip-host-cleanup)
            clean_host_choice="y"
            ;;
        --skip-repartition)
            shrink_choice="y"
            ;;
        --skip-start-rook)
            start_choice="y"
            ;;
        *)
            # Unknown flag, do nothing
            ;;
    esac
done

if [ "$skip_choice" != "y" ]; then
    findosd $NODE_NAME
    delete_osd $NODE_NAME
fi

if [ "$clean_host_choice" != "y" ]; then
    clean_host $NODE_NAME
fi

if [ "$shrink_choice" != "y" ]; then
    shrink_partition $NODE_NAME
fi

if [ "$start_choice" != "y" ]; then
    start_rookoperator 
fi

# wait for osds to come back up
# ...