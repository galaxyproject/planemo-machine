#!/bin/bash

# Install ansible if needed
dpkg -s ansible
if [ ! $? ];
then
	sudo apt-get update -y
	sudo apt-get install -y software-properties-common
	sudo apt-add-repository -y ppa:ansible/ansible
	sudo apt-get update -o Dir::Etc::sourcelist="sources.list.d/ansible-ansible-trusty.list" -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0"
	sudo apt-get install -y ansible
fi
