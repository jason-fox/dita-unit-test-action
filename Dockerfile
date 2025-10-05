#! /bin/sh

# This file is part of the DITA-OT Unit Test GitHub Action project.
# See the accompanying LICENSE file for applicable licenses.

FROM debian:12.11-slim AS dita-ot
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV JAVA_HOME=/opt/java/openjdk
COPY --from=eclipse-temurin:21 $JAVA_HOME $JAVA_HOME
ENV PATH="${JAVA_HOME}/bin:${PATH}"

ENV DITA_HOME=/opt/app
ENV PATH=${PATH}:${DITA_HOME}/bin
COPY --from=ghcr.io/dita-ot/dita-ot:4.3.3 $DITA_HOME $DITA_HOME

USER root
WORKDIR /

COPY entrypoint.sh entrypoint.sh

RUN chmod +x /entrypoint.sh && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y --no-install-recommends ant git locales curl && \
    ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive locales tzdata && \
    locale-gen en_US.UTF-8 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    curl -O https://downloads.apache.org/maven/maven-3/3.9.11/binaries/apache-maven-3.9.11-bin.tar.gz && \
	tar -zxvf apache-maven-3.9.11-bin.tar.gz && \
	mv apache-maven-3.9.11 /opt/apache-maven-3.9.11 && \
	export PATH=/opt/apache-maven-3.9.11/bin:$PATH && \
	rm apache-maven-3.9.11-bin.tar.gz

ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8 

ENTRYPOINT ["/entrypoint.sh"]
