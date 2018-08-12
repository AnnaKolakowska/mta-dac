#!/bin/bash
set -e

#generate password for encyption
KEY=$(docker run -t --rm sofianinho/pwgen-alpine 15 1 | tr -d '\040\011\012\015')

#tag with today's date
TAG=`date +%Y-%m-%d`

docker build -t broyal/mta-dac:$TAG --build-arg KEY=$KEY .

echo "------"
echo "# macOS / Linux Users - requires Docker for Mac"
echo "$ mkdir ~/mta-dac"
echo "$ docker run --name mta-dac -e KEY=$KEY -p 8080:8080 -v ~/mta-dac:/app/content -d broyal/mta-dac:$TAG"
echo "------"
echo "# Windows Users (PowerShell) - requires Docker for Windows (linux container mode)"
echo "PS> docker run --name mta-dac -e KEY=$KEY -p 8080:8080 -v \"\$env:USERPROFILE\mta-dac:/app/content\" -d broyal/mta-dac:$TAG"
echo "------"