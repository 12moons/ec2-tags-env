# ec2-tags-env

**This was inspired by https://github.com/12moons/ec2-tags-env.**

Import your AWS EC2 (instance and/or IAM) tags as Shell environment variables.

## Requirements

- curl
- jq ... package https://stedolan.github.io/jq/
- tr ... man page https://linux.die.net/man/1/tr
- AWS CLI tool https://github.com/aws/aws-cli (probably already installed in your AMI)
- IAM policy allowing you to use `ec2:DescribeTags`

## Usage

    . ./import-tags.sh
