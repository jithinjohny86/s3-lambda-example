#!/bin/bash
set -eo pipefail
FUNCTION=$(aws cloudformation describe-stack-resource --stack-name s3-java --logical-resource-id function --query 'StackResourceDetail.PhysicalResourceId' --output text --output text)
IMAGE_BUCKET=$(aws cloudformation describe-stack-resource --stack-name s3-java --logical-resource-id bucket --query 'StackResourceDetail.PhysicalResourceId' --output text)

cp -f event.json.template event.json
sed -i'' -e "s/BUCKET_NAME/$IMAGE_BUCKET/" event.json

aws lambda invoke --function-name $FUNCTION --payload file://event.json out.json
cat out.json

