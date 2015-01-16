# A piece-wise version of roughly the packer recipe for Docker, this
# is much better than packer for interactive debugging, incrementally building
# the image, etc....
FROM toolshed/requirements
MAINTAINER John Chilton <jmchilton@gmail.com>

# Pre-install a bunch of packages to speed up ansible steps.
RUN apt-get update -y
RUN apt-get install -y software-properties-common
RUN apt-add-repository -y ppa:ansible/ansible
RUN apt-add-repository -y ppa:galaxyproject/nginx
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
RUN sh -c "echo 'deb https://get.docker.io/ubuntu docker main' > /etc/apt/sources.list.d/docker.list"
RUN apt-get update -y
RUN apt-get install -y ant atop axel bioperl cmake curl g++ gcc gfortran git-core htop iftop iotop \
            ipython libffi-dev liblapack-dev libncurses5-dev libopenblas-dev libpam0g-dev libpq-dev libsparsehash-dev \
            make mercurial nmon openssh-server patch postgresql postgresql postgresql-client postgresql-plpython-9.3 \
            python-dev python-prettytable python-psycopg2 rsync slurm-drmaa-dev swig sysstat unzip vim wget zlib1g-dev \
            ansible build-essential git m4 ruby texinfo libbz2-dev libcurl4-openssl-dev libexpat-dev \
            automake build-essential fail2ban fuse glusterfs-client libcurl4-openssl-dev libfuse-dev libfuse2 \
            libpcre3-dev libreadline6-dev libslurm-dev libssl-dev libtool libxml2-dev libmunge-dev lxc-docker \
            mime-support munge nfs-common nfs-kernel-server pkg-config postgresql-server-dev-9.3 python-pip python-tk \
            rabbitmq-server slurm-llnl xfsprogs nginx-extras


ADD scripts/setup_docker.sh /tmp/setup_docker.sh
RUN sh /tmp/setup_docker.sh

# Pretasks (somehow should get this into a role for reuse)
WORKDIR /tmp/ansible
RUN mkdir /opt/galaxy && mkdir /opt/galaxy/shed_tools && chown -R ubuntu:ubuntu /opt/galaxy
USER ubuntu
RUN hg clone https://bitbucket.org/galaxy/galaxy-dist /opt/galaxy/galaxy-app
USER root
RUN mkdir /opt/galaxy/db &&  chown -R postgres:postgres /opt/galaxy/db
ADD group_vars/all /tmp/ansible/vars.yml
#ADD roles/galaxyprojectdotorg.cloudmanimage /tmp/ansible/roles/galaxyprojectdotorg.cloudmanimage
ADD roles/ /tmp/ansible/roles
ADD provision.yml /tmp/ansible/provision.yml
RUN ansible-playbook /tmp/ansible/provision.yml --extra-vars galaxy_user_name=ubuntu --tags=image -c local -e "@vars.yml"
RUN ansible-playbook /tmp/ansible/provision.yml --extra-vars galaxy_user_name=ubuntu --tags=database -c local -e "@vars.yml" && \
        ansible-playbook /tmp/ansible/provision.yml --extra-vars galaxy_user_name=ubuntu --tags=galaxy -c local -e "@vars.yml"
RUN ansible-playbook /tmp/ansible/provision.yml --extra-vars galaxy_user_name=ubuntu --tags=galaxyextras -c local -e "@vars.yml"
RUN ansible-playbook /tmp/ansible/provision.yml --extra-vars galaxy_user_name=ubuntu --tags=devbox -c local -e "@vars.yml"
