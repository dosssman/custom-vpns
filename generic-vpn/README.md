# Generic VPN for gaming over LAN

Notes regaring the procedure to generate server and client files certificates, keys and configuration for generic VPN for LAN access.

### Dependencies (Arch focused)
- `easyrsa` (pacman -S easy-rsa)
- `openssl` (???)
- `p7zip`  (pacman -S p7zip) for encrypted compression of some sensitive info.

The following steps assume one wants to create a LAN focused VPN based on OpenVPN.

### A. Create a PKI for certificate generation
First, a Public Key Infrastructure needs to be created, to be able to sign the OpenVPN's server and client keys.

1. Create the folder to hold the PKI, as well as the various config files.
```bash
mkdir generic-vpn/openvpn-configs -p
cd generic-vpn
ln -s /etc/easyrsa/x509-types x509-types # In case init-pki or build-ca throws an error related to missing x509-types
```

2. Generate the `ca.crt` to be used for signing.

```bash
easyrsa init-pki # This will create a "pki" folder within the working directory
easyrsa build-ca nopass # Will generate the necessary ca.key and ca.crt
```

3. Create folders to hold the `generic-vpn-server` and `generic-vpn-client` OVPN config files
```bash
mkdir openvpn-configs/generic-vpn-server
mkdir openvpn-configs/generic-vpn-client
```

4. Copy the `pki/ca.crt` to `openvpn-configs/generic-vpn-server` and `openvpn-configs/generic-vpn-client`
```bash
# NOTE: could be useful to rename the ca.crt to something more specific 
# to avoid confusing when running multiple different servers on the same machine
cp pki/ca.crt openvpn-configs/generic-vpn-server/.
cp pki/ca.crt openvpn-configs/generic-vpn-client/.
```

### B. OpenVPN Server file generation

The following steps generate the necessary files for the OVPN server.

5. Generate the OVPN server's certificate request.
```bash
easyrsa gen-req "generic-vpn-server" nopass # Found in pki/reqs
```

6. Generate the DH (Diffie Hellman) file (use `-dsaparam` to skip strong prime search, speed up generation)
```bash
openssl dhparam -dsaparam -out openvpn-configs/generic-vpn-server/generic-vpn-server-dh4096.pem 4096
```

7. Generate TA `ta.key`, and also copy it to the client config
```bash
openvpn --genkey secret openvpn-configs/generic-vpn-server/generic-vpn-ta.key
cp openvpn-configs/generic-vpn-server/generic-vpn-ta.key openvpn-configs/generic-vpn-client/.
```

8 . Create the `generic-vpn-server.conf` file based on the publicly available OVPN templates, and put it in the relevant `openvpn-configs/generic-vpn-server`.
Edit variables such as `remote XXX.XXX.XXX.XXX YYYY` to specify the public IP and port of the OVPN server.
Also make sure the change the default name of the `ta.key`, `ca.crt`, `server.key`, `server.crt` and `dh.pem` to reflect hte files creates through the current set of instructions.

### C. OpenVPN Client configuration

The following steps generate the necessary files for the OVPN client.

9. Generate the OVPN client's certificate request.
```bash
easyrsa gen-req "generic-vpn-client" nopass # Found in pki/reqs
```

10. Create the `generic-vpn-client.conf` (Linux client) or `generic-vpn-client.ovpn` (Windows client) based on the public template, and put it in the relevant `openvpn-configs/generic-vpn-client`.

Also make sure the change the default name of the `ta.key`, `ca.crt`, `client.key`, and `client.crt` to reflect hte files creates through the current set of instructions.

### D. Finalize server and client configuration files.

11. Sign the server and client keys with the PKI's `ca.crt` certificate.
The signature will be valid for 100 years, which might not be advisable security wise.

```bash
easyrsa sign-req --days=36500 server generic-vpn-server
easyrsa sign-req --days=36500 client generic-vpn-client
# Check resuts under pki/issued and pki/private
```

12. Copy the signed server and client keys to their respective config folders
```bash
## Server
cp pki/private/generic-vpn-server.key openvpn-configs/generic-vpn-server/.
cp pki/issued/generic-vpn-server.crt openvpn-configs/generic-vpn-server/.
## Client
cp pki/private/generic-vpn-client.key openvpn-configs/generic-vpn-client/.
cp pki/issued/generic-vpn-client.crt openvpn-configs/generic-vpn-client/.
```

The outline of the config folder should thus be as follows:
```
openvpn-configs/
    generic-vpn-client/
        ca.crt
        generic-vpn-client.crt
        generic-vpn-client.key
        generic-vpn-client.ovpn
        generic-vpn-ta.key
    generic-vpn-server/
        ca.crt
        generic-vpn-server-dh4096.pem
        generic-vpn-server.crt
        generic-vpn-server.key
        generic-vpn-server.ovpn
        generic-vpn-ta.key
```

### E. Usage

**Server side**
Assuming a node with public IP address is running (tested with Ubuntu), make sure the following deps. are installed
```bash
apt-get install openvpn easy-rsa -y
```

then copy the previously generated config files:
```bash
sudo cp openvpn-configs/generic-vpn-server/* /etc/openvpn/server/. # NOTE: probably a more elegant way to handle different servers.
sudo chmod 600 /etc/openvpn/server/* -R
```

then enable and start the vpn service as follows:
```bash
systemctl enable --now openvpn-server@generic-vpn-server
```
**Client side**

Assuming windows clients, download a supported version of OpenVPN GUI (tested with 2.4.12), get it working on the machine.

Distribute the `generic-vpn-client` folder with the `.ovpn` file properly configured (namely remote address and port), then place it in `C:\Users\%USERNAME%\OpenVPN\configs` (crete the folders if not existing).

The user should be able to connect by right clicking the OVPN GUI in the icon tray, then the `generic-vpn-client` profile.

As for linux users, essentially copy the configs to `/etc/openvpn/client` and run:
```bash
systemctl start openvpn-client@generic-vpn-client.service
```
or something along those lines.
Note that Linux client probably requires `generic-vpn-client.conf` instead of `.ovpn` file extension to be recongnized.


### Other notes

On Windows, to force apps to use the VPN over the native connection, change the "Adapter Metric" to a small value like 5 (its priority):

( Networks interfaces > Right click on the TAP Adapter > Properties > IPv4 then Properties > Advanced > Uncheck "Automatic Metric" > set it to 5.

### Password locked compression using 7z

- Archive a folder with password lock
)
```bash
7z a -p"notpassword" -mhe=on -r client-default.7z ./client-default
```

- Decompress password locked archive

```bash
# NOTE: will override existing folder and files
7z x -p"notpassword" -o"." -r client-default.7z
```

**PKI Certificate Auth. Info @2023-05-16**
- Common name: doss

