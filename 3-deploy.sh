#!/bin/bash

set -eo pipefail

ARTIFACT_BUCKET=$(cat bucket-name.txt)

TEMPLATE=template-mvn.yml

if [ $1 ]
then
  if [ $1 = gradle ]
  then
    TEMPLATE=template.yml
    gradle build -i
  fi
else
  TEMPLATE=template-mvn.yml
fi

aws cloudformation package --template-file $TEMPLATE --s3-bucket $ARTIFACT_BUCKET --output-template-file deploy.yml
aws cloudformation deploy --template-file deploy.yml --stack-name s3-java --capabilities CAPABILITY_NAMED_IAM
