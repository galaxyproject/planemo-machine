#!/bin/bash

set -e

if [ "$INCLUDE_X" == "true" ]
then
    SUFFIX="-x"
else
    SUFFIX=""
fi
make docker$SUFFIX
make docker-server$SUFFIX
make run-test-docker-server$SUFFIX
sleep 5
make check-test-server
