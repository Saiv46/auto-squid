#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
REPO_OWNER='Saiv46'
NODE_VER='12'

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

setup() {
cd /home/

print_status "Installing cURL & Git..."
exec_cmd 'apt-get update > /dev/null 2>&1'
exec_cmd 'apt-get install -y curl git > /dev/null 2>&1'

print_status "Installing NodeJS..."
exec_cmd "curl -sL https://deb.nodesource.com/setup_${NODE_VER}.x | bash -"
exec_cmd 'apt-get install -y nodejs > /dev/null 2>&1'

print_status "Downloading flying-squid..."
exec_cmd "git clone https://github.com/${REPO_OWNER}/flying-squid.git > /dev/null 2>&1"

print_status "Downloading prismarine-panel..."
exec_cmd "git clone https://github.com/${REPO_OWNER}/prismarine-panel.git > /dev/null 2>&1"

print_status "Creating daemon..."
exec_cmd 'touch /etc/systemd/system/flying-squid.service > /dev/null 2>&1'
exec_cmd 'chmod 664 /etc/systemd/system/flying-squid.service > /dev/null 2>&1'
echo "[Unit]
Description=An minecraft-compatible server
Documentation=https://github.com/Saiv46/auto-squid#readme
[Service]
Environment=NODE_ENV=production
Type=notify
WorkingDirectory=/home/flying-squid
ExecStart=node app.js |& tee -a output.log
TimeoutStartSec=10
Restart=always
WatchdogSec=10
[Install]
Alias=minecraft
WantedBy=multi-user.target" > /etc/systemd/system/flying-squid.service

print_status "Adding auto-update to crontab..."
exec_cmd 'curl -sL -o /etc/cron.daily/ https://raw.githubusercontent.com/Saiv46/auto-squid/master/install.sh'

print_status "Enabling daemon..."
exec_cmd 'systemctl daemon-reload > /dev/null 2>&1'
exec_cmd 'systemctl enable flying-squid > /dev/null 2>&1'
exec_cmd 'systemctl start flying-squid > /dev/null 2>&1'
exec_cmd 'systemctl status flying-squid'

cd flying-squid

print_status "Making default config file..."
exec_cmd 'cat ./config/default-settings.json > ./config/settings.json'

print_status
print_status "Done! The config is stored at:"
print_status "/home/flying-squid/config/settings.json"
print_status
}

setup
