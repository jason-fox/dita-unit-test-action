#! /bin/sh

# This file is part of the DITA-OT Unit Test Plug-in project.
# See the accompanying LICENSE file for applicable licenses.

FROM ubuntu:18.04

RUN apt-get update && \
    apt-get install -y default-jdk maven ant curl unzip git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/app/bin/
COPY entrypoint.sh entrypoint.sh
RUN chmod +x /opt/app/bin/entrypoint.sh

ENTRYPOINT ["/opt/app/bin/entrypoint.sh"]