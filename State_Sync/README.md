# Content

- [Help page](#Help-page)
- [Examples](#Examples)
- [Known bootstraps list](#Known-bootstraps-list)

# Help page

```
$ . <(wget -qO- https://raw.githubusercontent.com/SecorD0/Cosmos/main/State_Sync/state_sync.sh) -h

                      _______________________________________
                     /                                       \

                      _                  _
                     / | _ __  __ _  __ | |__ __ _  __ _  ___
                     | || '_ \/ _` |/ _|| / // _` |/ _` |/ -_)
                     |_|| .__/\__,_|\__||_\_\\__,_|\__, |\___|
                        |_|                        |___/

                     \_______________________________________/

                         Telegram: https://t.me/OnePackage
                      Discord: https://discord.gg/dnDaVqeWZe
                      Twitter: https://twitter.com/1package_

                           The script created by -h
_______________________________________________________________________________________


Functionality: the script launches a node from a State Sync snapshot

Usage: script [OPTIONS]

Options (yellow is mandatory):
  -h,  --help       show the help page
  -mb               an IP or domain name of a main bootstrap node, which RPC will be used.
                     Examples: 123.45.67.8, http://domain.com, https://domain.com
  -rp, --rpc-port   the RPC port of the main bootstrap node (default is 26657)
  -pp, --peer-port  the peer port of the main bootstrap node (default is rpc_port-1)
  -sb               an IP or domain name of a second bootstrap node
                     Examples: 123.45.67.8, 123.45.67.8:26657 (if a non-standard RPC port),
                     http://domain.com, https://domain.com
  -a, --age         the snapshot age (default is 1000)
  -d, --daemon      the node daemon name
  -sfn              the service file name (default is same as daemon)
  -nd, --node-dir   the path to the directory with the node data

Useful URLs:
https://github.com/SecorD0/Cosmos/blob/main/State_Sync/state_sync.sh — script URL
         (you can add a new or delete irrelevant snapshot node via PR)
https://t.me/OnePackage — noderun and tech community
```

# Examples

```sh
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/Cosmos/main/State_Sync/state_sync.sh) \
-mb 94.250.203.6 \
-rp 26697 \
-d umeed \
-nd .umee/

. <(wget -qO- https://raw.githubusercontent.com/SecorD0/Cosmos/main/State_Sync/state_sync.sh) \
-mb 194.163.141.20 \
-sb 51.91.208.59 \
-a 3000 \
-d defundd \
-nd $HOME/.defund
```

# Known bootstraps list

⠀You can add a new or delete irrelevant one via PR

| Project | Chain | IP or domen name | RPC port | Peer port | Age | Who provides |
|---------|---------|----------------|----------|-----------|-----|--------------|
| Umee | umee-1 | 94.250.203.6 | 26697 | 26696 | 1000 | [AM Solutions](https://www.theamsolutions.info/umee-services) |
| - | - | - | - | - | - | - | - |
