#!/bin/bash
# date >> /home/hyoklee/tmp/hello.txt
date
# Check if nodes are allocated.
if [[ -z "${SLURM_NODELIST}" ]]; then
  echo "Allocating nodes."
  salloc -N 2 --partition compute -w ares-comp-[31,32] --exclusive
  salloc -N 2 --partition storage -w ares-stor-[31,32] --exclusive --no-shell
else
  echo "${SLURM_NODELIST}"
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

# Generate server and client list files.
NND=ares_ofs/node_names
ls $NND
[ ! -f "$NND/server_nodes-" ] && cp $NND/server_nodes $NND/server_nodes-
[ ! -f "$NND/client_nodes-" ] && cp $NND/client_nodes $NND/client_nodes-
mpirun -n 2 -ppn 1 hostname > $NND/server_nodes
sed -e 's/$/-g40/' -i $NND/server_nodes
cat $NND/server_nodes

START=`squeue | grep storage | cut -d ']' -f 1 | cut -d '[' -f 2 | cut -d '-' -f 1`
STOP=`squeue | grep storage | cut -d ']' -f 1 | cut -d '[' -f 2 | cut -d '-' -f 2`
for nn in $(seq $START $STOP) ; do
    (echo $nn)
done
