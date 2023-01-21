#!/bin/bash
set -eo pipefail
STACK=s3-java
if [[ $# -eq 1 ]] ; then
    STACK=$1
    echo "Deleting stack $STACK"
fi

# This will get the `/inbound` host bucket.
IMAGE_BUCKET=$(aws cloudformation describe-stack-resource --stack-name $STACK --logical-resource-id bucket --query 'StackResourceDetail.PhysicalResourceId' --output text)
FUNCTION=$(aws cloudformation describe-stack-resource --stack-name $STACK --logical-resource-id function --query 'StackResourceDetail.PhysicalResourceId' --output text)

# Delete stack
aws cloudformation delete-stack --stack-name $STACK
echo "Deleted $STACK stack."

if [ -f bucket-name.txt ]; then
    ARTIFACT_BUCKET=$(cat bucket-name.txt)
    if [[ ! $ARTIFACT_BUCKET =~ lambda-artifacts-[a-z0-9]{16} ]] ; then
        echo "Bucket was not created by this application. Skipping."
    else
        while true; do
            read -p "Delete deployment artifacts and bucket ($ARTIFACT_BUCKET)? (y/n)" response
            case $response in
                [Yy]* ) aws s3 rb --force s3://$ARTIFACT_BUCKET; rm bucket-name.txt; break;;
                [Nn]* ) break;;
                * ) echo "Response must start with y or n.";;
            esac
        done
    fi
fi

while true; do
    read -p "Delete application bucket ($IMAGE_BUCKET)? (y/n)" response
    case $response in
        [Yy]* ) aws s3 rb --force s3://$IMAGE_BUCKET ; break;;
        [Nn]* ) break;;
        * ) echo "Response must start with y or n.";;
    esac
done

# This probably will fail because we delete s3-stack already.
while true; do
    read -p "Delete function log group (/aws/lambda/$FUNCTION)? (y/n)" response
    case $response in
        [Yy]* ) aws logs delete-log-group --log-group-name /aws/lambda/$FUNCTION; break;;
        [Nn]* ) break;;
        * ) echo "Response must start with y or n.";;
    esac
done

rm -f deploy.yml out.json event.json
rm -rf build .gradle target
