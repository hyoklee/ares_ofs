function single_pfs_up() {
    pushd ${PFS_SCRIPTS_DIR}
    ./prep_client_dirs.sh
    ./create_config.sh ${1:+sync}
    ./start_servers.sh
    ./start_clients.sh
    popd
}

function pfs_up() {
    pushd ${PFS_SCRIPTS_DIR}
    ./create_config.sh ${1:+sync}
    ./start_servers.sh
    ./start_clients.sh 1
    popd
}

function single_pfs_down() {
    pushd ${PFS_SCRIPTS_DIR}
    ./stop_clients.sh
    ./stop_servers.sh
    popd
}

function pfs_down() {
    pushd ${PFS_SCRIPTS_DIR}
    ./stop_servers.sh
    popd
}

function bb_up() {
    pushd ${PFS_SCRIPTS_DIR}

    # TMPFS_SIZE=25g ./make_tmpfs.sh

    local server_nodes_file=bb_server_nodes
    local conf_filename=bb.conf
    # local pfs_path_base=/dev/shm
    local pfs_path_base=/mnt/nvme
    local pfs_dir=bb
    local port=3335
    local file_system_name=ofs_bb

    SERVER_NODES_FILE=${server_nodes_file} \
      CONF_FILENAME=${conf_filename}       \
      PFS_PATH_BASE=${pfs_path_base}       \
      PFS_DIR=${pfs_dir}                   \
      FILE_SYSTEM_NAME=${file_system_name} \
      PORT=${port}                         \
      ./create_config.sh ${1:+sync}

    SERVER_NODES_FILE=${server_nodes_file} \
      CONF_FILENAME=${conf_filename}       \
      PFS_PATH_BASE=${pfs_path_base}       \
      PFS_DIR=${pfs_dir}                   \
      ./start_servers.sh

    SERVER_NODES_FILE=${server_nodes_file} \
      PFS_DIR=${pfs_dir}                   \
      FILE_SYSTEM_NAME=${file_system_name} \
      PORT=${port}                         \
      ./start_clients.sh
    popd
}

function bb_down() {
    pushd ${PFS_SCRIPTS_DIR}

    local server_nodes_file=bb_server_nodes
    # local pfs_path_base=/dev/shm
    local pfs_path_base=/mnt/nvme
    local pfs_dir=bb

    SERVER_NODES_FILE=${server_nodes_file} \
      PFS_PATH_BASE=${pfs_path_base}       \
      PFS_DIR=${pfs_dir}                   \
      ./stop_servers.sh

    # ./kill_tmpfs.sh
    popd
}

function hierarchy_up() {
    pushd ${PFS_SCRIPTS_DIR}
    ./prep_client_dirs.sh
    popd

    pfs_up ${1+sync}
    bb_up ${1+sync}
}

function hierarchy_down() {
    pushd ${PFS_SCRIPTS_DIR}
    ./stop_clients.sh
    popd

    pfs_down
    bb_down
}
