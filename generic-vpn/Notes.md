# Generic VPN for gaming over LAN

Notes regaring the procedure to generate server and client files certificates, keys and configuration for generic VPN for LAN access.

## Dependencies (Arch focused)
- `easyrsa` (pacman -S easy-rsa)
- `openssl` (???)
- `p7zip`  (pacman -S p7zip) for encrypted compression of some sensitive info.

## A. Create a PKI for certificate generation

## B. OpenVPN Server configuration

## C. OpenVPN Client configuration

## D. Usage

## Other notes

### Password locked compression using 7z

- Archive a folder with password lock

```bash
7z a -p"notpassword" -mhe=on -r client-default.7z ./client-default
```

- Decompress password locked archive

```bash
# NOTE: will override existing folder and files
7z x -p"notpassword" -o"." -r client-default.7z
```

### vultr-cli related

- Create an instance

```bash
vultr-cli instance create -o <osId> --p <planId> --r <regionId> -s <sshId_0,sshId_1> --script-id <scriptId_0,scriptId_1> -l <label>

# JP Server VPN Node example
vultr-cli instance create -o 387 -p "vc2-1c-1gb" -r nrt -l "GenericVPN-JP" -s "a6fb92f8-b8d1-47c9-9511-8f2dc116714b,6bc9749a-ad09-4d35-add4-fc41afeb8341" --script-id "18a18387-c4ec-4c0a-8fcd-d1151486fa27"
```

**PKI Certificate Auth. Info @2023-05-16**
- Common name: doss

