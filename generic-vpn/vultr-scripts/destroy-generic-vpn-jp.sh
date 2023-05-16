#!/bin/bash

# Get the list of instances, and filter for the "GenericVPN-JP" label
INSTANCE_INFO=$(vultr-cli instance list | grep -i "GenericVPN-JP")

if [ -n "${INSTANCE_INFO}" ]; then
    INSTANCE_ID=$(echo $INSTANCE_INFO | awk '{print $1}')
    echo "Instance detected: ${INSTANCE_ID}"
    echo "Proceeding to destroy ..." # TODO: add some form of verification ?

    vultr-cli instance destroy ${INSTANCE_ID}
else
    echo "Instance not found. Exiting."
fi