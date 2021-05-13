#!/bin/bash

set -x

SCRIPT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
ORANGEFS_PATH=${ORANGEFS_PATH:?}

# Can comment out servers with # in server_nodes file
SERVER_NODES_FILE=${SERVER_NODES_FILE:-pfs_server_nodes}
NODES=$(grep ^ares ${SCRIPT_DIR}/${SERVER_NODES_FILE})
CONF_FILENAME=${CONF_FILENAME:-pfs.conf}
CONF_FILE=${SCRIPT_DIR}/${CONF_FILENAME}
PFS_PATH_BASE=${PFS_PATH_BASE:-/mnt/hdd}
PFS_DIR=${PFS_DIR:-storage}
PFS_PATH=${PFS_PATH_BASE}/${USER}/${PFS_DIR}
PVFS2_SERVER=${ORANGEFS_PATH}/sbin/pvfs2-server

if [[ ! -f ${CONF_FILE} ]]; then
    echo "${CONF_FILE} does not exist"
    exit 1
fi

for node in $NODES
do
    ssh ${node} /bin/bash << EOF
rm -rf ${PFS_PATH}/*
# killall pvfs2-server
mkdir -p ${PFS_PATH}
${PVFS2_SERVER} -f -a ${node} ${CONF_FILE}
${PVFS2_SERVER} -a ${node} ${CONF_FILE}
ps -aef | grep pvfs2
EOF
done


