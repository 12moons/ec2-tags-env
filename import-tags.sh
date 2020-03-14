#!/bin/bash

# The following linux commands are required:
# - curl
# - aws
# - jr
# - tr

CURL_CMD=$(command -v curl)
AWS_CMD=$(command -v aws)
JQ_CMD=$(command -v jq)
TR_CMD=$(command -v tr)

# Enabled/Disable the types of tags you want to convert to envrionment variables.
GET_AMI_TAG=true
GET_INSTANCE_TAG=true

# Array of missing dependencies
MISSINGS=()

# Associative array of tags to look for.
# Add an associative tag name in the TAG_NAME array using the following examples.
# IF this array is left empty, then all tags will be converted to envrionment variables.
declare -A TAG_NAMES=(
#    ['TAG_NAME1']=1
#    ['TAG2']=1
#    ['FOO']=1
)

join_array_items () {
    local IFS="$1"; shift; echo "$*";
}

check_dependencies() {
    ERROR_MSG="Missing dependencie(s): "

    if [ ! -f "$CURL_CMD" ]; then
        MISSINGS+=('curl')
    fi

    if [ ! -f "$AWS_CMD" ]; then
        MISSINGS+=('aws')
    fi

    if [ ! -f "$JQ_CMD" ]; then
        MISSINGS+=('jq')
    fi

    if [ ! -f "$TR_CMD" ]; then
        MISSINGS+=('tr')
    fi

    if [ ${#MISSINGS[@]} -gt "0" ]; then
        MISSING_ITEMS=$(join_array_items ', ' ${MISSINGS[@]})
        PLURAL="";

        if [ ${#MISSINGS[@]} -gt "1" ]; then
            PLURAL="s"
        fi

        echo "Missing dependencie${PLURAL}: ${MISSING_ITEMS}"

        exit 1
    fi
}

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

        if [ ${#TAG_NAMES[@]} -gt "0" ]; then

            if [ -n "${TAG_NAMES[$key]}" ]; then
                echo "The tag ${key} was found"
                export "$key"="$value"
            fi

            # When using specific tag names, then continue to the next iteration 
            continue

        fi

        echo "Generic tag"
        export "$key"="$value"
    done
}

check_dependencies

if [ ${GET_AMI_TAG} = true ]; then
    #echo "Getting AMI TAG"
    ami_tags=$(get_ami_tags)
    tags_to_env "$ami_tags"
fi

if [ ${GET_INSTANCE_TAG} = true ]; then
    #echo "Getting INSTANCE TAG"
    instance_tags=$(get_instance_tags)
    tags_to_env "$instance_tags"
fi
