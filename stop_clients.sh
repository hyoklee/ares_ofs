#!/bin/bash

set -x

SCRIPT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

# Can comment out clients with # in client_nodes file
NODES=$(grep ^ares ${SCRIPT_DIR}/client_nodes)
KILL_PVFS2_CLIENT=/usr/sbin/kill-pvfs2-client
PATH=${PATH}:/usr/sbin

for node in $NODES
do
    echo "Stopping client on $node"
    ssh $node /bin/bash << EOF
sudo ${KILL_PVFS2_CLIENT}
mount | grep pvfs2
EOF
done
