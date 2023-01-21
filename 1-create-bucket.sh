#!/bin/bash

# Generate random bucket name
BUCKET_ID=$(dd if=/dev/random bs=8 count=1 2>/dev/null | od -An -tx1 | tr -d ' \t\n')

# Setup environment variable
ARTIFACT_BUCKET=lambda-artifacts-$BUCKET_ID

# Save to file
echo $ARTIFACT_BUCKET > bucket-name.txt

# Create bucket:
#   md: mkdir s3://dir_name
# If experience SSL certificate invalid issue:
#   `--no-verify-ssl` or `--ca-bundle ~/.aws/aws-ca-bundle.pem`
aws s3 mb s3://$ARTIFACT_BUCKET --cli-binary-format raw-in-base64-out #--no-verify-ssl
