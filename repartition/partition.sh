#!/bin/bash

# Function to shrink partition
shrink_partition() {
    # Get IP address of NODE_NAME
    NODE_IP=$(kubectl get node $NODE_NAME -o jsonpath='{.status.addresses[?(@.type=="InternalIP")].address}')

    START=$(ssh root@$NODE_IP "parted $DEVICE print | awk '/^ 4/ {print \$2}'")
    END=$(ssh root@$NODE_IP "parted $DEVICE print | awk '/^ 4/ {print \$3}'")
    START=${START//[!0-9]/}
    END=${END//[!0-9]/}
    MIDPOINT=$((($START + $END) / 2))
    ssh root@$NODE_IP "echo yes | parted $DEVICE ---pretend-input-tty resizepart 4 ${MIDPOINT}GB"
    ssh root@$NODE_IP "parted $DEVICE mkpart primary ext4 ${MIDPOINT}GB 100%"
   }
