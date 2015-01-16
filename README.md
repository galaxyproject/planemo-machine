planemo-machine
=====================

A set of [packer](http://packer.io) configuration files and scripts
used to build Ubuntu environment for
[Galaxy](http://galaxyproject.org) tool development.

Example Uses
-----------------------

 * Build Docker image.

``packer build --only docker packer.json``

 * Build Docker image based on toolshed base dependencies (much faster).

``packer build -var 'docker_base=toolshed/requirements' --only docker packer.json``

 * Build and register Vagrant box (named galaxydev).

``vagrant_create_box.sh``

 * Build Google Compute Engine image (untested). Follow instructions on
     https://www.packer.io/docs/builders/googlecompute.html, you will
     need to download your account file to gce_account.json (or set a
     path with ``-var 'gce_account_file=/path/to/account.json'``)
    
``packer build -var 'gce_project_id=<PROJECT_ID>' --only googlecompute packer.json``

 * Build Amazon Web Services AMI (untested).

``packer build -var 'ami_access_key=<AWS ACCESS KEY>' -var 'ami_secret_key=<AWS SECRET KEY>' --only googlecompute packer.json``


Ideas and code borrowed from various places
-------------------------------------------

 * https://github.com/galaxyproject/cloudman-image-playbook
 * https://github.com/bgruening/docker-galaxy-stable
 * https://www.packer.io/docs/
 * https://github.com/flomotlik/packer-example
 * https://github.com/eggsby/docker-ansible-packer
