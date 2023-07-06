#! /bin/sh

# This file is part of the DITA-OT Unit Test GitHub Action project.
# See the accompanying LICENSE file for applicable licenses.

FROM ghcr.io/dita-ot/dita-ot:4.0 AS DITA_OT

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root
WORKDIR /

COPY entrypoint.sh entrypoint.sh

RUN chmod +x /entrypoint.sh && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y --no-install-recommends ant git && \
    ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive locales tzdata && \
    locale-gen en_US.UTF-8 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    curl -O https://downloads.apache.org/maven/maven-3/3.9.3/binaries/apache-maven-3.9.3-bin.tar.gz && \
	tar -zxvf apache-maven-3.9.3-bin.tar.gz && \
	mv apache-maven-3.9.3 /opt/apache-maven-3.9.3 && \
	export PATH=/opt/apache-maven-3.9.3/bin:$PATH && \
	rm apache-maven-3.9.3-bin.tar.gz

ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8 

ENTRYPOINT ["/entrypoint.sh"]
