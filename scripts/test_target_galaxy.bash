#!/bin/bash

set -e
: ${BIOBLEND_GALAXY_MASTER_API_KEY:="HSNiugRFvgT574F43jZ7N9F3"}
: ${BIOBLEND_GALAXY_URL:="http://localhost:8080"}
: ${BIOBLEND_GALAXY_USER_EMAIL:="dev@galaxyproject.org"}
: ${BIOBLEND_TEST_SUITE:="quick"}

: ${BIOBLEND_INSTALL_TARGET:="https://github.com/galaxyproject/bioblend/archive/master.zip"}

export BIOBLEND_GALAXY_MASTER_API_KEY
export BIOBLEND_GALAXY_URL
export BIOBLEND_TEST_SUITE
export BIOBLEND_GALAXY_USER_EMAIL

echo "Entering loop"

for i in {1..40}; do curl --silent --fail "${BIOBLEND_GALAXY_URL}/api/version" && break || sleep 5; done

curl -v --fail "${BIOBLEND_GALAXY_URL}/api/version"

VENV_DIR=`mktemp -d`
virtualenv "$VENV_DIR"
. "$VENV_DIR/bin/activate"
pip install "$BIOBLEND_INSTALL_TARGET" "pytest"
echo $BIOBLEND_GALAXY_URL
echo $BIOBLEND_GALAXY_MASTER_API_KEY
echo $BIOBLEND_TEST_SUITE
bioblend-galaxy-tests
