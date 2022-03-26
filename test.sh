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
sed -e 's/$/-g40/' -i $NND/client_nodes
cat $NND/client_nodes

START=`squeue | grep storage | cut -d ']' -f 1 | cut -d '[' -f 2 | cut -d '-' -f 1`
STOP=`squeue | grep storage | cut -d ']' -f 1 | cut -d '[' -f 2 | cut -d '-' -f 2`
rm $NND/server_nodes
for n in $(seq $START $STOP) ; do
    i=$(printf "%02d" $n)
    echo 'ares-stor-'$i >> $NND/server_nodes
done
cat $NND/server_nodes
