#!/bin/bash

set -x

SCRIPT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

# Can comment out servers with # in server_nodes file
SERVER_NODES_FILE=${SERVER_NODES_FILE:-pfs_server_nodes}
NODES=$(grep ^ares ${SCRIPT_DIR}/${SERVER_NODES_FILE})

PFS_PATH_BASE=${PFS_PATH_BASE:-/mnt/hdd}
PFS_DIR=${PFS_DIR:-storage}
PFS_PATH=${PFS_PATH_BASE}/${USER}/${PFS_DIR}

for NODE in ${NODES}
do
    ssh ${NODE} /bin/bash << EOF
rm -rf ${PFS_PATH}/*
killall pvfs2-server
ps -aef | grep pvfs2
EOF
done
