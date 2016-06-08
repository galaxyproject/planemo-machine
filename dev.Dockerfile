
# Piece-wise variant of the Dockerfile for testing - produces larger
# images so it is less appropriate for publishing Docker images.
FROM toolshed/requirements:16.04
MAINTAINER John Chilton <jmchilton@gmail.com>

# Pre-install a bunch of packages to speed up ansible steps.
RUN apt-get update -y && apt-get install -y software-properties-common && \
    apt-add-repository -y ppa:ansible/ansible && apt-add-repository -y ppa:m-vandenbeek/nginx-upload-store && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9 && \
    apt-get update -y && \
    apt-get install -y ant atop axel cmake curl g++ gcc gfortran git-core htop iftop iotop \
            ipython libffi-dev liblapack-dev libncurses5-dev libopenblas-dev libpam0g-dev libpq-dev libsparsehash-dev \
            make mercurial nmon openssh-server patch postgresql postgresql postgresql-client postgresql-plpython-9.5 \
            python-dev python-prettytable python-psycopg2 rsync slurm-drmaa-dev swig sysstat unzip vim wget zlib1g-dev \
            ansible build-essential git m4 ruby texinfo libbz2-dev libcurl4-openssl-dev libexpat-dev \
            automake fail2ban fuse glusterfs-client libcurl4-openssl-dev libfuse-dev libfuse2 \
            libpcre3-dev libreadline6-dev libslurm-dev libssl-dev libtool libxml2-dev libmunge-dev \
            mime-support munge nfs-common nfs-kernel-server pkg-config postgresql-server-dev-9.5 python-pip python-tk \
            rabbitmq-server slurm-llnl xfsprogs nginx-extras nodejs npm emacs24-nox sudo libglib2.0-bin gnome-settings-daemon-schemas && \
    apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD scripts/setup_docker.sh /tmp/setup_docker.sh
ADD scripts/cleanup.sh /tmp/cleanup.sh

RUN sh /tmp/setup_docker.sh

# Pretasks (somehow should get this into a role for reuse)
WORKDIR /tmp/ansible
RUN mkdir /opt/galaxy && mkdir /opt/galaxy/shed_tools && chown -R ubuntu:ubuntu /opt/galaxy
USER root
ENV USER root
RUN mkdir /opt/galaxy/db &&  chown -R postgres:postgres /opt/galaxy/db
ADD group_vars/all /tmp/ansible/vars.yml
ADD roles/ /tmp/ansible/roles
ADD playbook/templates/ /tmp/ansible/templates
ADD provision.yml /tmp/ansible/provision.yml
ENV ANSIBLE_EXTRA_VARS="--extra-vars galaxy_user_name=ubuntu --extra-vars galaxy_docker_sudo=true --extra-vars docker_package=docker-engine  --extra-vars startup_chown_on_directory=/opt/galaxy/tools"
RUN ANSIBLE_FORCE_COLOR=1 PYTHONUNBUFFERED=1 ansible-playbook /tmp/ansible/provision.yml --tags=image -c local -e "@vars.yml" $ANSIBLE_EXTRA_VARS
# Database creation and migration need to happen in the same step so
# that postgres is still running.
RUN ANSIBLE_FORCE_COLOR=1 PYTHONUNBUFFERED=1 ansible-playbook /tmp/ansible/provision.yml --tags=database -c local -e "@vars.yml" $ANSIBLE_EXTRA_VARS && \
    ANSIBLE_FORCE_COLOR=1 PYTHONUNBUFFERED=1 ansible-playbook /tmp/ansible/provision.yml --tags=galaxy -c local -e "@vars.yml" $ANSIBLE_EXTRA_VARS 

# Database creation and migration need to happen in the same step so
# that postgres is still running.
RUN ANSIBLE_FORCE_COLOR=1 PYTHONUNBUFFERED=1 ansible-playbook /tmp/ansible/provision.yml --tags=database -c local -e "@vars.yml" $ANSIBLE_EXTRA_VARS && \
    ANSIBLE_FORCE_COLOR=1 PYTHONUNBUFFERED=1 ansible-playbook /tmp/ansible/provision.yml --tags=toolshed -c local -e "@vars.yml" $ANSIBLE_EXTRA_VARS 

RUN ANSIBLE_FORCE_COLOR=1 PYTHONUNBUFFERED=1 ansible-playbook /tmp/ansible/provision.yml --tags=galaxyextras -c local -e "@vars.yml" $ANSIBLE_EXTRA_VARS 
RUN ANSIBLE_FORCE_COLOR=1 PYTHONUNBUFFERED=1 ansible-playbook /tmp/ansible/provision.yml --tags=devbox -c local -e "@vars.yml" $ANSIBLE_EXTRA_VARS 
ADD scripts/cleanup.sh /tmp/cleanup.sh
RUN sh /tmp/cleanup.sh

WORKDIR /

EXPOSE 80
EXPOSE 9009

CMD GALAXY_LOGGING=notail /usr/bin/startup; su - ubuntu
