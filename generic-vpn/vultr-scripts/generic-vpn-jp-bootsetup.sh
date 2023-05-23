#!/bin/sh

# Installing dependencies
apt-get update
apt-get install openvpn easy-rsa p7zip-full -y
cd
git clone https://github.com/dosssman/custom-vpns.git
cd custom-vpns/generic-vpn/openvpn-configs

# Decompress the relevant OVPN server config
7z x -p"password" -o"." -r "server-jp.7z"

# Copy the server config files to the relevant path, then clean up
cp server-jp/* /etc/openvpn/server/.
chmod 600 /etc/openvpn/server/* -R
cd ../../..
rm -rf custom-vpns

systemctl enable --now openvpn-server@generic-vpn-server

# Disable default ufw that blocks the OpenVPN server connection recently
sudo systemctl disable ufw --now
