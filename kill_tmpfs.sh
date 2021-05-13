#!/bin/bash

set -x

SCRIPT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
SERVER_NODES_FILE=${SERVER_NODES_FILE:-bb_server_nodes}
NODES=$(grep ^ares ${SCRIPT_DIR}/${SERVER_NODES_FILE})
TMPFS_PATH_BASE=${TMPFS_PATH_BASE:-/dev/shm}
TMPFS_DIR=${TMPFS_DIR:-bb}
TMPFS_PATH=${TMPFS_PATH_BASE}/${USER}/${TMPFS_DIR}

for NODE in $NODES
do
    ssh ${NODE} /bin/bash << EOF
sudo umount ${TMPFS_PATH}
rm -rf ${TMPFS_PATH}
EOF
done
