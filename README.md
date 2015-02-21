# ec2-tags-env

**WIP. This script is written for my personal usage, and may not be suitable to use in a production environment.**

Import your AWS EC2 tags as Shell environment variables.

## Requirements

- jq package https://stedolan.github.io/jq/
- AWS CLI tool https://github.com/aws/aws-cli (probably already installed in your AMI)
- IAM policy allowing you to use `ec2:DescribeTags`

## Usage

    . ./import-tags.sh
        
