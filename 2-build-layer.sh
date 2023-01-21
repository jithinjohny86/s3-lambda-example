#!/bin/bash

set -eo pipefail

#gradle -q packageLibs
mvn clean package -Dmaven.test.skip=true

mv build/distributions/s3-java.zip build/s3-java-lib.zip
