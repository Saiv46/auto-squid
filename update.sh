#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

print_status() {
    echo
    echo "## $1"
    echo
}

bail() {
    echo 'Error executing command, exiting'
    exit 1
}

exec_cmd_nobail() {
    echo "+ $1"
    bash -c "$1"
}

exec_cmd() {
    exec_cmd_nobail "$1" || bail
}

update() {
	exec_cmd 'apt-get update > /dev/null 2>&1'
	exec_cmd 'apt-get upgrade > /dev/null 2>&1'

	cd /home/flying-squid/
	if [ -a .installing ]
	then
		exit 0
	fi
	touch .installing

	print_status "Fetching changes from repo..."
	status = `git pull`
	echo status
	if ([ "$status" == "Already up-to-date." ])
	then
		exit 0
	fi

	print_status "Updating dependecies..."
	exec_cmd 'npm install'
	exec_cmd 'npm update'

	print_status "Restarting server..."
	exec_cmd 'systemctl restart flying-squid > /dev/null 2>&1'

	print_status "Done"
	rm .installing
}
