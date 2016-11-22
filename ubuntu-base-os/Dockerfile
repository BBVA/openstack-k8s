FROM bbvainnotech/ubuntu-base:latest
MAINTAINER Eurocloud <eurocloud-oneteam.group@bbva.com>
# image base based on Ubuntu with the minimal packages to build on top of this new ones

ENV PYTHON_VERSION=2.7 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

RUN     locale-gen en_US.UTF-8 && \
        apt-get update && \
        apt-get install -y locales git unzip crudini gettext-base coreutils moreutils openssl mysql-client libxml2-dev libpq-dev libxslt-dev libffi-dev libssl-dev libmysqlclient-dev python${PYTHON_VERSION} python${PYTHON_VERSION}-dev && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/*

RUN    curl -fSL https://bootstrap.pypa.io/get-pip.py -o get-pip.py \
       && python get-pip.py \
       && pip install tox \
       && pip install mysqlclient \
       && pip install setuptools

ADD     data /

RUN     chown root:root /bootstrap/*.sh && chmod a+x /bootstrap/*.sh
