#/bin/bash
echo -n "Enter password for encryption:"
read -s password1
echo .

echo -n "Re-enter password for verification:"
read -s password2
echo .
echo .

if [ "${password1}" = "${password2}" ]; then
    echo "Passwords match. Proceeding to encrypt"
    echo .

    # Encrypt the PKI folder
    7z a -p"${password1}" -r pki.7z ./pki

    # Encrypt the various openvpn-configs
    for CONFIG_FOLDER_NAME in "client-default" "server-default" "server-jp"; do
        cd "openvpn-configs"
        7z a -p"${password1}" -mhe=on -r "${CONFIG_FOLDER_NAME}.7z" "${CONFIG_FOLDER_NAME}"
        cd ..
    done
else
    echo "Passwords do not match. Aborting."
fi