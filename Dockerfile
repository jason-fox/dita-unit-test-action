#! /bin/sh

# This file is part of the DITA-OT Unit Test Plug-in project.
# See the accompanying LICENSE file for applicable licenses.

FROM ubuntu:20.04

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update && \
    apt-get install -y --no-install-recommends openjdk-11-jre ant curl unzip git locales && \
    curl -O http://apachemirror.wuchna.com/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz && \
    tar -zxvf apache-maven-3.6.3-bin.tar.gz && \
	mv apache-maven-3.6.3 /opt/apache-maven-3.6.3 && \
	export PATH=/opt/apache-maven-3.6.3/bin:$PATH && \
	rm apache-maven-3.6.3-bin.tar.gz && \
    dpkg-reconfigure --frontend noninteractive locales && \
    locale-gen en_US.UTF-8 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8 

WORKDIR /opt/app/bin/
COPY entrypoint.sh entrypoint.sh
RUN chmod +x /opt/app/bin/entrypoint.sh

ENTRYPOINT ["/opt/app/bin/entrypoint.sh"]