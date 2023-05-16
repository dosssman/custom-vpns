#!/bin/bash

# Get the list of instances, and filter for the "GenericVPN-FR" label
INSTANCE_INFO=$(vultr-cli instance list | grep -i "GenericVPN-FR")

if [ -n "${INSTANCE_INFO}" ]; then
    INSTANCE_ID=$(echo $INSTANCE_INFO | awk '{print $1}')
    INSTANCE_MAIN_IP=$(echo $INSTANCE_INFO | awk '{print $2}')
    echo "Instance detected: ${INSTANCE_ID}"
    echo "    Main IP: ${INSTANCE_MAIN_IP}"
else
    echo "Instance not detected. Proceeding to creation."

    NEW_INSTANCE_INFO=$(vultr-cli instance create -o 387 -p "vc2-1c-1gb" -r cdg -l "GenericVPN-FR" -s "a6fb92f8-b8d1-47c9-9511-8f2dc116714b,6bc9749a-ad09-4d35-add4-fc41afeb8341" --script-id "11a14387-3a48-4668-9528-563c7b8744eb")
    
    # Recover Instance ID
    INSTANCE_INFO=$(vultr-cli instance list | grep -i "GenericVPN-FR")
    INSTANCE_ID=$(echo $INSTANCE_INFO | awk '{print $1}')
    echo "Instance created with ID: ${INSTANCE_ID}"
    echo "   Waiting for instance initialization ..."

    # Wait for the IP to get assign, then return it
    sleep 10s
    INSTANCE_MAIN_IP=$(vultr-cli instance get ${INSTANCE_ID} | awk 'NR==6 {print $3}')
    echo "   Detected Instance IP: ${INSTANCE_MAIN_IP}"
fi
