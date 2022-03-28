#!/bin/bash
# date >> /home/hyoklee/tmp/hello.txt
date
# Check if nodes are allocated.
if [[ -z "${SLURM_NODELIST}" ]]; then
  echo "Allocating nodes."
  salloc -N 2 --partition compute -w ares-comp-[05,06] --exclusive
else
  echo "${SLURM_NODELIST}"
fi

STOR=`squeue | grep storage`
if [ "$STOR" == "" ]; then
  salloc -N 2 --partition storage -w ares-stor-[31,32] --exclusive --no-shell
fi

STR=`which mpirun`
SUB='mpich'
if [[ "$STR" == *"$SUB"* ]]; then
  echo $STR
else
  module swap openmpi3 mpich
fi
mpirun -n 2 -ppn 1 hostname
[ ! -d "ares_ofs" ] && git clone https://github.com/ChristopherHogan/ares_ofs


# Generate client and server list files.
NND=ares_ofs/node_names
ls $NND
[ ! -f "$NND/server_nodes-" ] && cp $NND/server_nodes $NND/server_nodes-
[ ! -f "$NND/client_nodes-" ] && cp $NND/client_nodes $NND/client_nodes-
mpirun -n 2 -ppn 1 hostname > $NND/client_nodes
sed -e 's/$/-40g/' -i $NND/client_nodes
cat $NND/client_nodes

START=`squeue | grep storage | cut -d ']' -f 1 | cut -d '[' -f 2 | cut -d '-' -f 1`
STOP=`squeue | grep storage | cut -d ']' -f 1 | cut -d '[' -f 2 | cut -d '-' -f 2`
rm $NND/server_nodes
for n in $(seq $START $STOP) ; do
    i=$(printf "%02d" $n)
    echo 'ares-stor-'$i >> $NND/server_nodes
done
cat $NND/server_nodes

export PFS_SCRIPTS_DIR=$HOME/ares_ofs
echo $PFS_SCRIPTS_DIR
cp $NND/client_nodes $PFS_SCRIPTS_DIR/client_nodes
cp $NND/server_nodes $PFS_SCRIPTS_DIR/pfs_server_nodes
export ORANGEFS_PATH=/opt/ohpc/pub/orangefs
export ORANGEFS_KO=${ORANGEFS_PATH}/lib/modules/3.10.0-862.el7.x86_64/kernel/fs/pvfs2/pvfs2.ko
. ${PFS_SCRIPTS_DIR}/pfs_funcs.sh
hierarchy_up
mpirun -n 4 -ppn 2 $HOME/install/bin/end_to_end_test $HOME/hermes/test/data/ares.conf 
