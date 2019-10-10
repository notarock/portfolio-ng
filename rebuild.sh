#!/bin/bash

imageName=notarock:blog
containerName=blog

docker build -t $imageName -f Dockerfile .

echo Delete old container...
docker rm -f $containerName

echo Run new container...
docker run -d -p 80:80 --name $containerName $imageName
