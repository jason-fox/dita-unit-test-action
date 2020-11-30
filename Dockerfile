#! /bin/sh

# This file is part of the DITA-OT Unit Test Plug-in project.
# See the accompanying LICENSE file for applicable licenses.

FROM maven:3.6.3-jdk-11-slim 

RUN apt-get update && \
    apt-get install -y curl unzip git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/app/bin/
COPY entrypoint.sh entrypoint.sh
RUN chmod +x /opt/app/bin/entrypoint.sh

ENTRYPOINT ["/opt/app/bin/entrypoint.sh"]