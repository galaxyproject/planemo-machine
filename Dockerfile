# A piece-wise version of roughly the packer recipe for Docker, this
# is much better than packer for interactive debugging, incrementally building
# the image, etc... but is only for testing. To build final produces ignore
# this file and use package.json.

FROM toolshed/requirements
MAINTAINER John Chilton <jmchilton@gmail.com>

# Pre-install a bunch of packages to speed up ansible steps.
RUN apt-get update -y && apt-get install -y software-properties-common && \
    apt-add-repository -y ppa:ansible/ansible && apt-add-repository -y ppa:galaxyproject/nginx && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9 && \
    apt-get update -y && \
    apt-get install -y ant atop axel bioperl cmake curl g++ gcc gfortran git-core htop iftop iotop \
            ipython libffi-dev liblapack-dev libncurses5-dev libopenblas-dev libpam0g-dev libpq-dev libsparsehash-dev \
            make mercurial nmon openssh-server patch postgresql postgresql postgresql-client postgresql-plpython-9.3 \
            python-dev python-prettytable python-psycopg2 rsync slurm-drmaa-dev swig sysstat unzip vim wget zlib1g-dev \
            ansible build-essential git m4 ruby texinfo libbz2-dev libcurl4-openssl-dev libexpat-dev \
            automake fail2ban fuse glusterfs-client libcurl4-openssl-dev libfuse-dev libfuse2 \
            libpcre3-dev libreadline6-dev libslurm-dev libssl-dev libtool libxml2-dev libmunge-dev \
            mime-support munge nfs-common nfs-kernel-server pkg-config postgresql-server-dev-9.3 python-pip python-tk \
            rabbitmq-server slurm-llnl xfsprogs nginx-extras nodejs npm emacs24-nox && \
    apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD scripts/setup_docker.sh /tmp/setup_docker.sh
ADD scripts/cleanup.sh /tmp/cleanup.sh

RUN sh /tmp/setup_docker.sh

# Pretasks (somehow should get this into a role for reuse)
WORKDIR /tmp/ansible
RUN mkdir /opt/galaxy && mkdir /opt/galaxy/shed_tools && chown -R ubuntu:ubuntu /opt/galaxy
# Pre-clone Galaxy into its final destination early in Dockerfile so ansible task
# runs quicker.
USER root
ENV USER root
RUN mkdir /opt/galaxy/db && chown -R postgres:postgres /opt/galaxy/db
ADD group_vars/all /tmp/ansible/vars.yml
ADD roles/ /tmp/ansible/roles
ADD provision.yml /tmp/ansible/provision.yml
RUN ANSIBLE_FORCE_COLOR=1 PYTHONUNBUFFERED=1 ansible-playbook /tmp/ansible/provision.yml --extra-vars galaxy_user_name=ubuntu --extra_vars galaxy_docker_sudo=true --tags=image -c local -e "@vars.yml" && \
    ANSIBLE_FORCE_COLOR=1 PYTHONUNBUFFERED=1 ansible-playbook /tmp/ansible/provision.yml --extra-vars galaxy_user_name=ubuntu --extra_vars galaxy_docker_sudo=true --tags=database -c local -e "@vars.yml" && \
    ANSIBLE_FORCE_COLOR=1 PYTHONUNBUFFERED=1 ansible-playbook /tmp/ansible/provision.yml --extra-vars galaxy_user_name=ubuntu --extra_vars galaxy_docker_sudo=true --tags=galaxy -c local -e "@vars.yml" && \
    ANSIBLE_FORCE_COLOR=1 PYTHONUNBUFFERED=1 ansible-playbook /tmp/ansible/provision.yml --extra-vars galaxy_user_name=ubuntu --extra_vars galaxy_docker_sudo=true --tags=galaxyextras -c local -e "@vars.yml" && \
    ANSIBLE_FORCE_COLOR=1 PYTHONUNBUFFERED=1 ansible-playbook /tmp/ansible/provision.yml --extra-vars galaxy_user_name=ubuntu  --extra_vars galaxy_docker_sudo=true --tags=devbox -c local -e "@vars.yml" &&  \
    sh /tmp/cleanup.sh && \
    apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#CMD ["/usr/sbin/service", "supervisor", "start"]
CMD ["/usr/bin/supervisord", "-n"]
