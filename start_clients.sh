#!/bin/bash

set -x

if [[ -z ${ORANGEFS_KO} ]] || [[ -z ${ORANGEFS_PATH} ]]; then
    echo "ORANGEFS_KO and ORANGEFS_PATH must both be set."
    exit 1
fi

SCRIPT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

# Can comment out clients with # in client_nodes file
NODES=$(grep ^ares ${SCRIPT_DIR}/client_nodes)
SERVER_NODES_FILE=${SERVER_NODES_FILE:-pfs_server_nodes}
PFS_SERVERS=$(grep ^ares ${SCRIPT_DIR}/${SERVER_NODES_FILE})
IFS=$'\n' PFS_SERVERS=(${PFS_SERVERS})
FIRST_SERVER="${PFS_SERVERS[0]}"
PVFS2_CLIENT=${ORANGEFS_PATH}/sbin/pvfs2-client
PVFS2_CLIENT_CORE=${ORANGEFS_PATH}/sbin/pvfs2-client-core
KILL_PVFS2_CLIENT=/usr/sbin/kill-pvfs2-client
PATH=${PATH}:/usr/sbin

PFS_DIR=${PFS_DIR:-pfs}
FILE_SYSTEM_NAME=${FILE_SYSTEM_NAME:-orangefs}
PORT=${PORT:-3334}
MOUNT_DIR=/mnt/nvme/${USER}/${PFS_DIR}
SWAP_DIR=${MOUNT_DIR}/swap

for NODE in $NODES
do
    echo "Starting pfs client on $NODE"
    ssh ${NODE} /bin/bash << EOF
mkdir -p ${MOUNT_DIR}
sudo insmod ${ORANGEFS_KO}
sudo ${PVFS2_CLIENT} -p ${PVFS2_CLIENT_CORE}
sudo mount -t pvfs2 tcp://${FIRST_SERVER}:${PORT}/${FILE_SYSTEM_NAME} ${MOUNT_DIR}
mount | grep pvfs2
EOF
done

if [[ "${1}" = "1" ]]; then
    for NODE in $NODES; do
        echo "Creating swap directory ${SWAP_DIR}"
        ssh ${NODE} /bin/bash <<EOF
mkdir ${SWAP_DIR}
EOF
        break
    done
fi
