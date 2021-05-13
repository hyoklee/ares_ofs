# Bring up a storage hierarchy on Ares

1. Set an environment variable to point to this repo

```bash
export PFS_SCRIPTS_DIR=<path_to>/ares_ofs
```

2. Copy `node_names/client_nodes` and `node_names/server_nodes` to the top
   level, creating two copies of `server_nodes` (1 for burst buffers and one for
   PFS).

```bash
pushd ${PFS_SCRIPTS_DIR}
cp node_names/client_nodes .
cp node_names/server_nodes ./bb_server_nodes
cp node_names/server_nodes ./pfs_server_nodes
popd
```

3. You will need to modify these files each time you `salloc` new nodes from
   Slurm. The copies you created will not be included in source control. Modify
   the copies of `client_nodes` and `server_nodes` by commenting out all names
   you are NOT using. Anything should work as a comment, but I stick with `# `.
   I usually put the PFS and the burst buffer on the same storage servers. For
   example, if I want to start a parallel file system on `ares-stor-01` and
   `ares-stor-02` (assuming I've allocated those nodes with slurm), then
   `bb_server_nodes` and `pfs_server_nodes` should look like this:

```
ares-stor-01
ares-stor-02
# ares-stor-03
# ares-stor-04
# ares-stor-05
etc.
```

   and `client_nodes` should look like this (assuming I've allocated `ares-comp-[29-30]`):

```
...
# ares-comp-28
ares-comp-29
ares-comp-30
# ares-comp-31
...
```

4. Source the `pfs_funcs.sh` script to bring the functions into your shell.

```bash
. ${PFS_SCRIPTS_DIR}/pfs_funcs.sh
```

5. Start a hierarchy with a single command

```bash
hierarchy_up
```

   This will create the following hierarchy, accessible from each client node:

```
/mnt/nvme/<user>/pfs
/mnt/nvme/<user>/bb
/mnt/nvme/<user>/local
```

  Writing to the `pfs` directory will ultimately send the data to
  `ares-stor[01-02]:/mnt/hdd/<user>/storage`. Writing to the `bb` directory will
  send the data to `ares-stor[01-02]:/dev/shm/bb`, a tmpfs file system in RAM
  (created by the `make_tmpfs.sh` script). A swap directory is created at
  `pfs/swap`, which is where the `swap_mount` Hermes config option should point.

5. When your finished using the hierarchy just run

```bash
hierarchy_down
```

# Steps to start a parallel file system on Ares

If you don't need a whole hierarchy, you can start a single PFS as follows.

1. Follow steps 1-4 above for preparing a hierarchy.

2. Run the command that will prep directories, create an OrangeFS config, start
   the servers, and start the clients

```bash
single_pfs_up
```

   You can pass `sync` as a parameter to `single_pfs_up` to set
   `TroveSyncData=on`. This will force each write to the device (similar to
   `fsync`) instead of buffering it. It is off by default.

5. To properly shut everything down, run

```bash
single_pfs_down
```
