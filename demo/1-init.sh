#!/bin/bash

APPS=$(pwd)/../apps
PLATFORM=$(pwd)/../platform


## build image of generator movements app
cd "$APPS/fraud-checker-generator"
#mvn clean spring-boot:build-image -Dspring-boot.build-image.imageName=fraud-checker-generator:v1 -DskipTests

## Launch platform
cd "$PLATFORM"
docker-compose up -d

echo ""
echo "Waiting for platform to be ready...."
(docker-compose logs ksqldb-cli -f -t &) | grep -q 'Exiting ksqlDB.'

echo "Platform ready!"
echo "Now you can execute the next script to send movements automatically to the broker or sending manually"
echo "To execute the script:"
echo "    sh 2-generate-movements.sh"
echo ""
echo ""