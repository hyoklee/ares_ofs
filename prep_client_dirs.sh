#!/bin/bash

set -x

BASEDIR=/mnt/nvme/${USER}
LOCAL_NVME=${BASEDIR}/local
PFS_MOUNT_DIR=${PFS_MOUNT_DIR:-pfs}
PFS_MOUNT_PATH=${BASEDIR}/${PFS_MOUNT_DIR}
BB_MOUNT_DIR=${BB_MOUNT_DIR:-bb}
BB_MOUNT_PATH=${BASEDIR}/${BB_MOUNT_DIR}
SWAP=${PFS_MOUNT_PATH}/swap
ALL_DIRS=("${LOCAL_NVME}" "${SWAP}" "${BB_MOUNT_PATH}")

NODES=$(grep ^ares ./client_nodes)

for NODE in ${NODES}; do

    if [[ "${1}" = "1" ]]; then
        ssh ${NODE} "rm ${BB_MOUNT_PATH}/*.out; rm ${BB_MOUNT_PATH}/*.hermes; rm ${LOCAL_NVME}/*.out; rm ${LOCAL_NVME}/*.hermes"
    else
        for d in "${ALL_DIRS[@]}"; do
            echo "Removing ${d} on ${NODE}"
            ssh ${NODE} "rm -rf ${d}"
            echo "Creating ${d} on ${NODE}"
            ssh ${NODE} "mkdir -p ${d}"
        done
    fi
done

