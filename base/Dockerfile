FROM      ubuntu:latest
MAINTAINER Genc Tato <genc.tato@irisa.fr>


RUN apt-get update && apt-get install -y \
    git default-jdk libffi-dev \
    build-essential python-pip python-setuptools python-dev \
    apache2 libapache2-mod-wsgi libcurl4-openssl-dev \
    libapache2-mod-php5 php5-curl \
    python-httplib2 sqlite3 vim

CMD ["/bin/bash"]

