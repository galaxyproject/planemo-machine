planemo-machine
=====================

A set of [packer](http://packer.io) and
[ansible](http://www.ansible.com/) configuration files and scripts
used to build [Ubuntu](http://www.ubuntu.com/) environment for
[Galaxy](http://galaxyproject.org) tool development.


Setup
-----------------------

This project makes use of git submodules and before you build any planemo
machines, you'll need to initialize them:

``make init``

This will simply execute the following command ``git submodule init && git submodule update``.

Example Uses
-----------------------

 * Build and register Vagrant box (named ``planemo``).

``make vagrant``

 * Build a virtualbox OVA for this vagrant box.

``make virtualbox``

The virtualbox OVA unlink the other variants will include a graphical environment ([Xubuntu](http://xubuntu.org/)) tailored for development (auto logins to the ``ubuntu`` user, configured with tools such as [Komodo](http://komodoide.com/komodo-edit/)).

 * Build a modified variant of the recipes with a Dockerfile directly
     (skipping packer). Skipping packer makes it easier to iterate on and applicable
     for tools like Docker Hub, the cost is some amount of duplication between
     the ``Dockerfile`` in this directory and ``provision.yml``.

``make docker``

To override the Docker command to use sudo for instance do

``make docker DOCKER_COMMAND='sudo docker'``

 * Build docker image using development Dockerfile (``dev.Dockerfile``).
     This Dockefile is broken out into more steps and will result in a much
     larger final container but can be quicker to develop against since the
     individual steps are checkmarked.

``make docker-dev``

 * Build Docker image (using packer directly).

``make docker-via-packer``

The VM version of this build process will enable Docker by default - but when
building a Docker image we disable this so the developer doesn't need to
configure docker-in-docker functionality.

 * Build Google Compute Engine image (untested). Follow instructions on
     https://www.packer.io/docs/builders/googlecompute.html, you will
     need to download your account file to gce_account.json (or set a
     path with ``-var 'gce_account_file=/path/to/account.json'``)

``packer build -var 'gce_project_id=<PROJECT_ID>' --only googlecompute packer.json``

 * Build Amazon Web Services AMI (untested).

``packer build -var 'ami_access_key=<AWS ACCESS KEY>' -var 'ami_secret_key=<AWS SECRET KEY>' --only googlecompute packer.json``

How it works
------------

The file ``packer.json`` contains a description of steps to execute to
provision a box - broken out by where it is being provisioned (Docker,
AWS,GCE, etc...). The main step is the ansible provisioning step preceeded
immediately by the execution of the ``setup_ansible.sh`` script. These steps
are executed for all platforms. To get to that point however, the RAW image
needs to be configured - basically an Ubuntu 14.04 machine needs to be created
with a password-less sudoing user (defaulting to ``ubuntu`` but overridable
using ``-var 'username=XXX'`` argument to ``packer`` - see for instance
``vagrant_create_box.sh`` script which overrides this to be ``ubuntu``).

The Ansible roles used to provision the box are found in ``roles`` and the
ansible playbook used to specify and configure them is ``provision.yml``.
Overview of the roles:

 * ``galaxyprojectdotorg.cloudmanimage`` A subset of the CloudMan image role,
   hopefully this can be refactored an trimmed down so this project and
   CloudMan can share the same base (via Ansible Galaxy or gitsubmodules).
 * ``galaxyprojectdotorg.cloudmandatabase`` The database role from CloudMan
   (maybe with added defaults that should be backported). Used to create
   postgres database.
 * ``galaxyprojectdotorg.galaxy`` Nate's Galaxy image - clones Galaxy, fetches
   eggs, sets up static configuration, etc...
 * ``galaxyprojectdotorg.galaxyextras`` New role created by extracting and
   generalizing stuff in Bjoern's Galaxy stable. Sets up Slurm, Proftp,
   Supervisor, uwsgi, nginx.
 * ``galaxyprojectdotorg.devbox`` New role created explicitly for allocating
   a development box. Install ``linuxbrew``, ``planemo``, and a ``codebox``
   IDE.

 * ``galaxyprojectdotorg.trackster``, ``smola.java`` - these are modified roles
   from CloudMan that work but seem less important for the devbox. They are
   commented out in provision.yml but should be added back in once things
   stabilize to unify CloudMan and this project.

Ideas and code borrowed from various places
-------------------------------------------

 * https://github.com/galaxyproject/cloudman-image-playbook
 * https://github.com/bgruening/docker-galaxy-stable
 * https://www.packer.io/docs/
 * https://github.com/flomotlik/packer-example
 * https://github.com/eggsby/docker-ansible-packer
