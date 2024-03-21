#!/bin/bash

# Get the list of instances, and filter for the "GenericVPN-JP" label
INSTANCE_INFO=$(vultr-cli instance list | grep -i "GenericVPN-JP")

if [ -n "${INSTANCE_INFO}" ]; then
    INSTANCE_ID=$(echo $INSTANCE_INFO | awk '{print $1}')
    INSTANCE_MAIN_IP=$(echo $INSTANCE_INFO | awk '{print $2}')
    echo "Instance detected: ${INSTANCE_ID}"
    echo "    Main IP: ${INSTANCE_MAIN_IP}"
else
    echo "Instance not detected. Proceeding to creation."

    NEW_INSTANCE_INFO=$(vultr-cli instance create \
        -l "GenericVPN-JP"\
        -s "a6fb92f8-b8d1-47c9-9511-8f2dc116714b,6bc9749a-ad09-4d35-add4-fc41afeb8341" \
        --os 387 \
        --region nrt \
        --plan "vc2-1c-1gb" \
        --script-id "18a18387-c4ec-4c0a-8fcd-d1151486fa27" \
    )

    # Recover Instance ID
    INSTANCE_INFO=$(vultr-cli instance list | grep -i "GenericVPN-JP")
    INSTANCE_ID=$(echo $INSTANCE_INFO | awk '{print $1}')
    echo "Instance created with ID: ${INSTANCE_ID}"
    echo "   Waiting for instance initialization ..."

    # Wait for the IP to get assign, then return it
    sleep 10s
    INSTANCE_MAIN_IP=$(vultr-cli instance get ${INSTANCE_ID} | awk 'NR==6 {print $3}')
    echo "   Detected Instance IP: ${INSTANCE_MAIN_IP}"
fi
