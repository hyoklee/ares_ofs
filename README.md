# Steps to start a parallel file system on Ares

1. Copy `node_names/*` to the top level directory. These will be the node lists
   that are modified each time you start new clients and servers. The copies
   will not belong to source control. Modify the copies of `client_nodes` and
   `server_nodes` by commenting out all names you are NOT using. Anything should
   work as a comment, but I stick with `# `. For example, if I want to start a
   parallel file system on ares-stor-01 and ares-stor-02 (assuming I've
   allocated those nodes with slurm), then `server_nodes` should look like this:
   
```
ares-stor-01
ares-stor-02
# ares-stor-03
# ares-stor-04
# ares-stor-05
etc.
```

2. After the lists of node names are correct, we must generate a config file.
   Run `./create_config.sh`. You can modify many options through environment
   variables, but by default this will generate `pfs.conf` in the current
   directory.

3. Next, start the servers by running `./start_servers.sh`.

4. Start the clients by running `./start_clients.sh`. I do some directory
   cleaning first by running `prep_client_dirs.sh`.

5. To properly shut everything down, run `./stop_clients.sh` and `./stop_servers.sh`.
