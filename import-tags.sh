#!/bin/bash

INSTANCE_ID=$(curl --silent http://169.254.169.254/latest/meta-data/instance-id)
TAGS=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID")

for KEY in $(echo $TAGS | jq -r ".[][].Key"); do
    VALUE=$(echo $TAGS | jq -r ".[][] | select(.Key==\"$KEY\") | .Value")
    KEY=$(echo $KEY | tr '-' '_' | tr '[:lower:]' '[:upper:]')
    export $KEY=$VALUE
done
