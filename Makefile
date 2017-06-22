PACKER_COMMAND=packer
DOCKER_COMMAND=docker
DOCKER_PRIVILEGED=true
TEST_FOLDER=test
IMAGE_NAME=planemo-machine
CONTAINER_NAME=planemo

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
_virtualbox: packer
	$(PACKER_COMMAND) build -var 'include_x=true' --only virtualbox-iso packer.json

virtualbox-nox: packer
	$(PACKER_COMMAND) build --only virtualbox-iso packer.json

docker: packer
	$(DOCKER_COMMAND) build -t planemo/interactive .

docker-x: packer
	$(DOCKER_COMMAND) build --build-arg INCLUDE_X=true -t planemo/interactive:x .

docker-dev: packer
	$(DOCKER_COMMAND) build -t planemo/interactive-dev -f dev.Dockerfile .

docker-server: packer
	$(DOCKER_COMMAND) build -t planemo/server server

docker-server-x: packer
	$(DOCKER_COMMAND) build --build-arg INCLUDE_X=true -t planemo/server:x server

docker-server-dev: packer
	$(DOCKER_COMMAND) build -t planemo/server-dev -f dev.server.Dockerfile .

run-docker-dev:
	$(DOCKER_COMMAND) run -v `pwd`/$(TEST_FOLDER):/opt/galaxy/tools -p 8010:80 -i -t planemo-dev

docker-via-packer: packer
	$(PACKER_COMMAND) build -var 'docker_autostart=false' -var 'docker_base=toolshed/requirements' --only docker packer.json

_virtualbox-ova:
	mv output-virtualbox-iso/*ovf $(IMAGE_NAME).ovf
	mv output-virtualbox-iso/*-disk001.vmdk $(IMAGE_NAME)-disk001.vmdk
	sed -i -e 's/<File.*/<File ovf:href="planemo-machine-disk001.vmdk" ovf:id="file1"\/>/g' $(IMAGE_NAME).ovf
	sed -i -e 's/<Clipboard.*/<Clipboard mode="Bidirectional"\/>/g' $(IMAGE_NAME).ovf
	sed -i -e "s:packer-virtualbox-iso:$(IMAGE_NAME):g" $(IMAGE_NAME).ovf
	tar cvf $(IMAGE_NAME).ova $(IMAGE_NAME).ovf
	tar uvf $(IMAGE_NAME).ova $(IMAGE_NAME)-disk001.vmdk

# Convert the VirtualBox Image into a Qemu Image for use in OpenStack
_create_qemu_image: packer
	qemu-img convert -O qcow2 $(IMAGE_NAME).ova $(IMAGE_NAME).qcow2

virtualbox: _virtualbox _virtualbox-ova

qemu: _virtualbox _virtualbox-ova _create_qemu_image

run-test-docker-server:
	docker run -d -p 8080:80 --rm --name "$(CONTAINER_NAME)" \
         --privileged="$(DOCKER_PRIVILEGED)" \
         -e GALAXY_CONFIG_ALLOW_USER_DATASET_PURGE=True \
         -e GALAXY_CONFIG_ALLOW_LIBRARY_PATH_PASTE=True \
         -e GALAXY_CONFIG_ENABLE_USER_DELETION=True \
         -e GALAXY_CONFIG_ENABLE_BETA_WORKFLOW_MODULES=True \
         planemo/server

run-test-docker-server-x:
	docker run -d -p 8080:80 --rm --name "$(CONTAINER_NAME)" \
         --privileged="$(DOCKER_PRIVILEGED)" \
         -e GALAXY_CONFIG_ALLOW_USER_DATASET_PURGE=True \
         -e GALAXY_CONFIG_ALLOW_LIBRARY_PATH_PASTE=True \
         -e GALAXY_CONFIG_ENABLE_USER_DELETION=True \
         -e GALAXY_CONFIG_ENABLE_BETA_WORKFLOW_MODULES=True \
         planemo/server:x

check-test-server:
	docker ps
	docker logs "$(CONTAINER_NAME)"
	docker exec "$(CONTAINER_NAME)" bash /usr/bin/check-planemo-machine.sh
	bash scripts/test_target_galaxy.bash
