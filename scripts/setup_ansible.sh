#!/bin/bash

# Install ansible if needed
dpkg -s ansible > /dev/null 2>&1
if [ $? -ne 0 ];
then
    sudo apt-get update -y
    sudo apt-get install -y software-properties-common
    sudo apt-get install -y python-dev
    sudo apt-get install -y python-pip
    sudo pip install ansible==1.9.0
fi
