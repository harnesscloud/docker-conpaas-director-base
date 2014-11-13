FROM marklee77/debian-cloudimage:latest
MAINTAINER Mark Stillwell <mark@stillwell.me>

# install dependencies
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    apt-get -y install \
        apache2 \
        autoconf-archive \
        automake \
        build-essential \
        default-jdk \
        git \
        libapache2-mod-php5 \
        libapache2-mod-wsgi \
        libcurl4-openssl-dev \
        libffi-dev \
        php5-curl \
        python \
        python-dev \
        python-httplib2 \
        python-pip \
        python-openssl \
        python-pycurl \
        python-setuptools \
        python-simplejson \
        sqlite3 && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/*

RUN pip install argcomplete

# prepare working directory
RUN mkdir -p /var/cache/docker/workdirs && \
    git clone -b harness https://gitlab.harness-project.eu/mark/conpaas.git \
        /var/cache/docker/workdirs/conpaas
WORKDIR /var/cache/docker/workdirs/conpaas

# install conpaas 
RUN bash mkdist.sh 1.5.0 && \
    tar -xaf cpsdirector-*.tar.gz && \
    tar -xaf cpsfrontend-*.tar.gz && \
    easy_install --always-unzip cpslib-*.tar.gz && \
    rm -rf *.tar.gz && \
    cp -r cpsfrontend-*/www/* /var/www && \
    rm /var/www/index.html && \
    cp /var/www/config-example.php /var/www/config.php && \
    a2enmod ssl && \
    a2ensite default-ssl

# create startup scripts
ADD conpaas-director.sh /etc/my_init.d/10-conpaas-director
RUN chmod 0755 /etc/my_init.d/10-conpaas-director

# data volumes
VOLUME [ "/etc/apache2", "/etc/cpsdirector", "/var/log/apache2" ]

# interface ports
EXPOSE 22 80 443 5555
