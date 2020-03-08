#!/bin/bash

CURL_CMD=$(command -v curl)
AWS_CMD=$(command -v aws)
JQ_CMD=$(command -v jq)
TR_CMD=$(command -v tr)

get_instance_tags () {
    instance_id=$($CURL_CMD --silent http://169.254.169.254/latest/meta-data/instance-id)
    echo $($AWS_CMD ec2 describe-tags --filters "Name=resource-id,Values=$instance_id")
}

get_ami_tags () {
    ami_id=$($CURL_CMD --silent http://169.254.169.254/latest/meta-data/ami-id)
    echo $($AWS_CMD ec2 describe-tags --filters "Name=resource-id,Values=$ami_id")
}

tags_to_env () {
    tags=$1

    for key in $(echo "$tags" | $JQ_CMD -r ".[][].Key"); do
        value=$(echo "$tags" | $JQ_CMD -r ".[][] | select(.Key==\"$key\") | .Value")
        key=$(echo "$key" | $TR_CMD '-' '_' | $TR_CMD '[:lower:]' '[:upper:]')
        export "$key"="$value"
    done
}

ami_tags=$(get_ami_tags)
instance_tags=$(get_instance_tags)

tags_to_env "$ami_tags"
tags_to_env "$instance_tags"
