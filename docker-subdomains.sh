#!/bin/bash
if [ $# -eq 0 ]; then
	docker run --rm -it subdomains.sh
elif [ $1 = "build" ]; then
	docker build . -t subdomains.sh
elif [ $1 = "destroy" ]; then
	docker rmi -f subdomains.sh:latest
else
	docker run --rm -it subdomains.sh $@
fi
