# Galaxy - Stable
#
# VERSION       Galaxy-central

FROM toolshed/requirements

MAINTAINER Björn A. Grüning, bjoern.gruening@gmail.com

# * Make sure the package repository is up to date
# * Install all requirements that are recommend by the Galaxy project
# * Enable the @natefoo magic
# Web server infrastructure matching usegalaxy.org - supervisor, uwsgi, and nginx.

RUN apt-get -qq update && apt-get install --no-install-recommends -y apt-transport-https  software-properties-common && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9 && \
    sh -c "echo deb https://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list" && \
    apt-get update -qq && apt-get upgrade -y && \
    add-apt-repository ppa:galaxyproject/nginx && \
    apt-add-repository -y ppa:ansible/ansible && \
    apt-get -qq update && \
    apt-get purge -y software-properties-common && \
    apt-get install --no-install-recommends -y mercurial python-psycopg2 postgresql-9.3 sudo samtools python-virtualenv \
    nginx-extras uwsgi uwsgi-plugin-python supervisor lxc-docker slurm-llnl slurm-llnl-torque libswitch-perl \
    slurm-drmaa-dev proftpd proftpd-mod-pgsql libyaml-dev nodejs-legacy npm aufs-tools ansible && \
    apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN groupadd -r galaxy -g 450 && \
    useradd -u 451 -r -g galaxy -d /home/galaxy -c "Galaxy user" galaxy && \
    mkdir /export/ /home/galaxy/ && chown -R galaxy:galaxy /home/galaxy /export/ && \
    gpasswd -a galaxy docker

RUN ls
RUN git clone https://github.com/jmchilton/ansible-galaxy-extras.git /tmp/ansible-galaxy-extras && \
    cd /tmp/ansible-galaxy-extras && \
    ansible-playbook -i localhost, local.yml --tags=slurm,nginx,proftpd,supervisor -e "@defaults/main.yml" && \
    rm -rf /tmp/ansible-galaxy-extras
