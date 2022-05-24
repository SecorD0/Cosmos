#!/bin/bash
# Default variables
main_bootstrap=""
rpc_port=26657
peer_post=""
second_bootstrap=""
age=1000
daemon=""
service_file=""
node_dir=""

# Options
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/colors.sh) --
option_value(){ echo "$1" | sed -e 's%^--[^=]*=%%g; s%^-[^=]*=%%g'; }
while test $# -gt 0; do
	case "$1" in
	-h|--help)
		. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/logo.sh)
		echo
		echo -e "${C_LGn}Functionality${RES}: the script launches a node from a State Sync snapshot"
		echo
		echo -e "${C_LGn}Usage${RES}: script ${C_LGn}[OPTIONS]${RES}"
		echo
		echo -e "${C_LGn}Options${RES} (${C_LY}yellow is mandatory${RES}):"
		echo -e "  -h,  --help       show the help page"
		echo -e "  ${C_LY}-mb${RES}               an IP or domain name of a main bootstrap node, which RPC will be used."
		echo -e "                     Examples: 123.45.67.8, http://domain.com, https://domain.com"
		echo -e "  -rp, --rpc-port   the RPC port of the main bootstrap node (default is ${C_LGn}${rpc_port}${RES})"
		echo -e "  -pp, --peer-port  the peer port of the main bootstrap node (default is ${C_LGn}rpc_port-1${RES})"
		echo -e "  -sb               an IP or domain name of a second bootstrap node"
		echo -e "                     Examples: 123.45.67.8, 123.45.67.8:26657 (if a non-standard RPC port),"
		echo -e "                     http://domain.com, https://domain.com"
		echo -e "  -a, --age         the snapshot age (default is ${C_LGn}${age}${RES})"
		echo -e "  ${C_LY}-d, --daemon${RES}      the node daemon name"
		echo -e "  -sfn              the service file name (default is ${C_LGn}same as daemon${RES})"
		echo -e "  ${C_LY}-nd, --node-dir${RES}   the path to the directory with the node data"
		echo
		echo -e "${C_LGn}Useful URLs${RES}:"
		echo -e "https://github.com/SecorD0/Cosmos/blob/main/State%20Sync/state_sync.sh — script URL"
		echo -e "https://t.me/letskynode — node Community"
		echo
		return 0 2>/dev/null; exit 0
		;;
	-mb*)
		if ! grep -q "=" <<< "$1"; then shift; fi
		main_bootstrap=`option_value "$1"`
		shift
		;;
	-rp*|--rpc-port*)
		if ! grep -q "=" <<< "$1"; then shift; fi
		rpc_port=`option_value "$1"`
		shift
		;;
	-pp*|--peer-port*)
		if ! grep -q "=" <<< "$1"; then shift; fi
		peer_post=`option_value "$1"`
		shift
		;;
	-sb*)
		if ! grep -q "=" <<< "$1"; then shift; fi
		second_bootstrap=`option_value "$1"`
		shift
		;;
	-a*|--age*)
		if ! grep -q "=" <<< "$1"; then shift; fi
		age=`option_value "$1"`
		shift
		;;
	-d*|--daemon*)
		if ! grep -q "=" <<< "$1"; then shift; fi
		echo "$1"
		daemon=`option_value "$1"`
		shift
		;;
	-sfn*)
		if ! grep -q "=" <<< "$1"; then shift; fi
		service_file=`option_value "$1"`
		shift
		;;
	-nd*|--node-dir*)
		if ! grep -q "=" <<< "$1"; then shift; fi
		node_dir=`option_value "$1"`
		shift
		;;
	*|--)
		break
		;;
	esac
done

# Functions
printf_n(){ printf "$1\n" "${@:2}"; }
validate_variables() {
	# --- Mandatory
	# main_bootstrap
	if [ ! -n "$main_bootstrap" ]; then
		printf_n "${C_R}You didn't specify an IP or domain name of the main bootstrap node via -mb option!${RES}\n"
		return 1 2>/dev/null; exit 1
	fi
	
	# daemon
	if [ ! -n "$daemon" ]; then
		printf_n "${C_R}You didn't specify the node daemon name via -d option!${RES}\n"
		return 1 2>/dev/null; exit 1
	elif $daemon --help 2>&1 | grep -q "command not found"; then
		printf_n "${C_R}There no such daemon on the system!${RES}\n"
		return 1 2>/dev/null; exit 1
	fi
	
	# node_dir
	if [ ! -n "$node_dir" ]; then
		printf_n "${C_R}You didn't specify the path to the directory with the node data via -nd option!${RES}\n"
		return 1 2>/dev/null; exit 1
	elif [ ! -d "$node_dir" ]; then
		printf_n "${C_R}There no such directory on the system!${RES}\n"
		return 1 2>/dev/null; exit 1
	fi
	
	# --- Transformations
	# peer_post
	if [ ! -n "$peer_post" ]; then
		peer_post=$((rpc_port-1))
	fi
	
	# main_bootstrap
	if grep -q "http" <<< "$main_bootstrap"; then
		peer="`sed -e "s%https://%%; s%http://%%;" <<< "$main_bootstrap"`:${peer_post}"
		main_bootstrap="${main_bootstrap}:${rpc_port}"
	else
		peer="${main_bootstrap}:${peer_post}"
		main_bootstrap="http://${main_bootstrap}:${rpc_port}"
	fi
	
	local response=`wget -t1 -T3 -O- "$main_bootstrap" 2>&1`
	if grep -q "Connection refused" <<< "$response" || grep -q "Connection timed out" <<< "$response"; then
		main_bootstrap=`sed "s%:${rpc_port}%%" <<< "$main_bootstrap"`
		local response=`wget -t1 -T3 -O- "$main_bootstrap" 2>&1`
		if grep -q "Connection refused" <<< "$response" || grep -q "Connection timed out" <<< "$response"; then
			printf_n "${C_R}The main bootstrap node doesn't work! Specify another one via -mb option!${RES}\n"
			return 1 2>/dev/null; exit 1
		fi
		peer=`sed -e "s%:${peer_post}%%;" <<< "$peer"`
	fi
	
	# second_bootstrap
	if [ ! -n "$second_bootstrap" ]; then
		second_bootstrap="$main_bootstrap"
	else
		if grep -q "http" <<< "$second_bootstrap"; then
			second_bootstrap="${second_bootstrap}"
		else
			second_bootstrap="http://${second_bootstrap}"
		fi
		local with_port=`sed -n "/:\/\/.*:/p" <<< "$second_bootstrap"`
		if [ ! -n "$with_port" ]; then
			second_bootstrap="${second_bootstrap}:${rpc_port}"
		fi
	fi
	
	# age
	if printf "%d" "$age" &>/dev/null; then
		age=`printf "%d" $age`
	else
		printf_n "${C_R}The specified snapshot age isn't a number!${RES}\n"
		return 1 2>/dev/null; exit 1
	fi
	
	# service_file
	if [ ! -n "$service_file" ]; then
		service_file="$daemon"
	fi
	
	if systemctl status "$service_file" 2>&1 | grep -q "could not be found"; then
		printf_n "${C_R}There no such service file on the system!${RES}\n"
		return 1 2>/dev/null; exit 1
	fi
}
state_sync() {
	if ! validate_variables; then
		return 1 2>/dev/null; exit 1
	fi
	sudo systemctl stop "$service_file"
	local reset_info=`$daemon unsafe-reset-all --home "$node_dir" 2>&1`
	if grep -q "unknown command" <<< "$reset_info"; then
		$daemon tendermint unsafe-reset-all --home "$node_dir"
	fi
	local node_id=`wget -qO- "${main_bootstrap}/status" | jq -r ".result.node_info.id"`
	local latest_height=`wget -qO- "${main_bootstrap}/block" | jq -r ".result.block.header.height"`
	local block_height=$((latest_height - age))
	local trust_hash=`wget -qO- "${main_bootstrap}/block?height=${block_height}" | jq -r ".result.block_id.hash"`
	sed -i.bak -e "s%^external_address *=.*%external_address = \"`wget -qO- eth0.me`:26656\"%; "\
"s%^seeds *=.*%seeds = \"\"%; "\
"s%^persistent_peers *=.*%persistent_peers = \"${node_id}@${peer}\"%; "\
"s%^enable *=.*%enable = true%; "\
"s%^rpc_servers *=.*%rpc_servers = \"${main_bootstrap},${second_bootstrap}\"%; "\
"s%^trust_height *=.*%trust_height = $block_height%; "\
"s%^trust_hash *=.*%trust_hash = \"$trust_hash\"%" "${node_dir}/config/config.toml"
	sudo systemctl restart "$service_file"
	printf_n "
The node was ${C_LGn}started${RES}!

Command to view the node log:
${C_LGn}sudo journalctl -fn 100 -u ${service_file}${RES}

After success launching remember to restore config.toml by command:
${C_LGn}mv ${node_dir}/config/config.toml.bak ${node_dir}/config/config.toml${RES}
"
}

# Actions
sudo apt install wget jq -y &>/dev/null
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/logo.sh)
state_sync
