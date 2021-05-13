#!/bin/bash

set -x

SCRIPT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

SERVER_NODES_FILE=${SERVER_NODES_FILE:-pfs_server_nodes}
SERVER_LIST=$(grep ^ares ${SCRIPT_DIR}/${SERVER_NODES_FILE} | tr '\n' ',')
SERVER_LIST="${SERVER_LIST:?}"

CONF_FILENAME=${CONF_FILENAME:-pfs.conf}
CONF_FILE=${SCRIPT_DIR}/${CONF_FILENAME}
PFS_PATH_BASE=${PFS_PATH_BASE:-/mnt/hdd}
PFS_DIR=${PFS_DIR:-storage}
PFS_PATH=${PFS_PATH_BASE}/${USER}/${PFS_DIR}
FILE_SYSTEM_NAME=${FILE_SYSTEM_NAME:-orangefs}
PORT=${PORT:-3334}

pvfs2-genconfig                   \
  --quiet                         \
  --protocol tcp                  \
  --ioservers ${SERVER_LIST}      \
  --metaservers ${SERVER_LIST}    \
  --tcpport ${PORT}               \
  --dist-name simple_stripe       \
  --dist-params strip_size:65536  \
  --storage ${PFS_PATH}/data      \
  --metadata ${PFS_PATH}/metadata \
  --logfile ${PFS_PATH}/log       \
  --fsname ${FILE_SYSTEM_NAME}    \
  ${CONF_FILE}

if [[ "${1}" = "sync" ]]; then
    sed -i 's/TroveSyncData no/TroveSyncData yes/' ${CONF_FILE}
fi
