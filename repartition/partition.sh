#!/bin/bash

# Function to shrink partition
shrink_partition() {
    # Get IP address of NODE_NAME
    NODE_IP=$(kubectl get node $NODE_NAME -o jsonpath='{.status.addresses[?(@.type=="InternalIP")].address}')

    # SSH into the node and run the parted command
    # NB: we hardcode "4" for nvme0n1p4 here
    ssh root@$NODE_IP << EOF
        START=$(parted $DEVICE print | awk '/^ 4/ {print $2}')
        END=$(parted $DEVICE print | awk '/^ 4/ {print $3}')
        START=${START//[!0-9]/}
        END=${END//[!0-9]/}
        MIDPOINT=$((($START + $END) / 2))  
        yes "yes"| parted $DEVICE resizepart 4 $MIDPOINT
        parted $DEVICE mkpart primary ext4 $MIDPOINT 100%

EOF
    

}

