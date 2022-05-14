#!/bin/bash

newSlot=$1
appVersion=$2
echo "Start to deploy on slot: $newSlot with version: $appVersion"


if [ $newSlot == "blue" ]; then
	helm upgrade --install offers . --set blue.enabled=true --set green.enabled=false --set blue.timestamp="$(date '+%Y-%m-%d %H:%M:%S')" --set image.tag="${appVersion}" --reuse-values --debug
fi
