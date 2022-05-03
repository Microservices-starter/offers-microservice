#!/bin/bash

currentSlot=$(helm get values --all offers | python3 -c 'import sys,yaml; yml = yaml.safe_load(sys.stdin); print(yml["productionSlot"]);')

if [ $currentSlot == "blue" ]; then
  newSlot=green
elif [ $currentSlot == "green" ]; then
  newSlot=blue
fi

newAppVersion=$(helm get values --all offers | sed -e "s/^$newSlot:/current:/" | python3 -c 'import sys,yaml; yml = yaml.safe_load(sys.stdin); print(yml["current"]["appVersion"]);')
if [ "$#" -eq  "1" ];
  then
    newAppVersion=$1
fi
echo "Start to deploy on slot: $newSlot with version: $newAppVersion"

if [ $newSlot == "blue" ]; then 
  helm upgrade offers . --set blue.enabled=true --set green.enabled=false --set blue.timestamp="$(date '+%Y-%m-%d %H:%M:%S')" --set image.tag=${newAppVersion} --set blue.appVersion=${newAppVersion} --reuse-values --debug
  kubectl rollout status deployments/offers-offers-microservice-blue
  sleep 2
  helm upgrade offers . --set productionSlot=blue --reuse-values --debug
elif [ $newSlot == "green" ]; then
  helm upgrade offers . --set green.enabled=true --set blue.enabled=false --set green.timestamp="$(date '+%Y-%m-%d %H:%M:%S')" --set image.tag=${newAppVersion} --set green.appVersion=${newAppVersion} --reuse-values --debug
  kubectl rollout status deployments/offers-offers-microservice-green
  sleep 2
  helm upgrade offers . --set productionSlot=green --reuse-values --debug
fi
