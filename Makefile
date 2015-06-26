PACKER_COMMAND=packer
DOCKER_COMMAND=docker
TEST_FOLDER=test

# Location of virtualenv used for development.
VENV=.venv
# Source virtualenv to execute command (for pyyaml)
IN_VENV=if [ -f $(VENV)/bin/activate ]; then . $(VENV)/bin/activate; fi;

init:
	git submodule init && git submodule update

setup-venv:
	if [ -f $(VENV) ]; then virtualenv $(VENV); fi;
	$(IN_VENV) pip install -r requirements.txt && pip install -r dev-requirements.txt

packer:
	$(IN_VENV) python yaml-to-json.py --force packer.yaml

# Create virtualbox image for vagrant - setup vagrant goodies and do not use X
# since vagrant is designed to be a command-line tool.
# TODO: script to makefile
vagrant: packer
	bash vagrant_create_box.sh

# Create a vanilla virtualbox image - setup X for people who would like a windowed
# environment to develop in.
virtualbox: packer
	$(PACKER_COMMAND) build -var 'include_x=true' --only virtualbox-iso packer.json

virtualbox-nox: packer
	$(PACKER_COMMAND) build --only virtualbox-iso packer.json	

docker: packer
	$(DOCKER_COMMAND) build -t planemo .

docker-dev: packer
	$(DOCKER_COMMAND) build -t planemo-dev -f dev.Dockerfile .

run-docker-dev:
	$(DOCKER_COMMAND) run -v `pwd`/$(TEST_FOLDER):/opt/galaxy/tools -p 8010:80 -i -t planemo-dev

docker-via-packer: packer
	$(PACKER_COMMAND) build -var 'docker_autostart=false' -var 'docker_base=toolshed/requirements' --only docker packer.json
