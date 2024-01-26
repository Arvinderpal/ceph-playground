#!/bin/bash

source delete-osd.sh

NAMESPACE="gitops-platform-storage"
ROOK_TOOLBOX="rook-ceph-tools-unknown"

# Define NODE_NAME variable with default value
NODE_NAME="no-node-specified"

# Check if NODE_NAME has been overridden by the user
if [ "$NODE_NAME" = "no-node-specified" ]; then
    echo "Error: NODE_NAME not specified. Please provide a value for NODE_NAME."
    exit 1
fi

# 1. delete osd
# 2. clean host (ansible)
# 3. repartition
# 4. start_rookoperator

delete_osd $NODE_NAME

# start_rookoperator
