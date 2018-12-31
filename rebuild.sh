#!/bin/bash

imageName=xx:portfolio
containerName=portfolio

docker build -t $imageName -f Dockerfile .

echo Delete old container...
docker rm -f $containerName

echo Run new container...
docker run -d -p 1313:1313 --network="proxy" --name $containerName $imageName
