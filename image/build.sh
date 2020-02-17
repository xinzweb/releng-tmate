#!/bin/bash

docker build -t baotingfang/tmate-ssh-server .
docker rmi baotingfang/tmate-ssh-server:2.3.0
docker tag baotingfang/tmate-ssh-server:latest baotingfang/tmate-ssh-server:2.3.0
docker push baotingfang/tmate-ssh-server:2.3.0


