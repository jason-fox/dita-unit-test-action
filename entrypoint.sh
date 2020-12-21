#! /bin/sh

# This file is part of the DITA-OT Unit Test Plug-in project.
# See the accompanying LICENSE file for applicable licenses.

#!/bin/bash

set -e

DITA_OT_VERSION="${1:-3.5.4}"
PLUGIN="${2}"
PREREQUISITES="${3}"
SETUP_SCRIPT="${4:-test-setup.sh}"
FILE=/github/workspace/${SETUP_SCRIPT}
 
cd /opt/app/bin/
curl -sLO https://github.com/dita-ot/dita-ot/releases/download/"${DITA_OT_VERSION}"/dita-ot-"${DITA_OT_VERSION}".zip
unzip -q dita-ot-"${DITA_OT_VERSION}".zip
rm dita-ot-"${DITA_OT_VERSION}".zip
chmod 755 dita-ot-"${DITA_OT_VERSION}"/bin/dita

PATH="${PATH}":/opt/app/bin/dita-ot-"${DITA_OT_VERSION}"/bin

echo -e "\x1B[01;96m Installling DITA-OT Unit Test Harness \x1B[0m\n"
dita --install
dita --install \
	https://github.com/doctales/org.doctales.xmltask/archive/master.zip
dita --install \
	https://github.com/jason-fox/fox.jason.unit-test/archive/master.zip

if [ -f "$FILE" ]; then
	echo -e "\x1B[01;96m Installling additional runtime dependencies \x1B[0m\n"
	"${FILE}"
fi

if [ ! -z "${PREREQUISITES}" ]; then 
	echo -e "\x1B[01;96m Installling prequisite DITA-OT plugins \x1B[0m\n"
	list=$(echo "$PREREQUISITES" | tr "," "\n")
	for prereq in $list
	do
		dita install "$prereq"
	done
fi


if [ -z "${PLUGIN}"  ]; then 
	echo "No plugin to test"
else
	cp -r /github/workspace dita-ot-"${DITA_OT_VERSION}"/plugins/"${PLUGIN}"
	dita --install
	echo -e "\n\x1B[01;96m Instrumenting ${PLUGIN} plugin \x1B[0m\n"
	dita --input dita-ot-"${DITA_OT_VERSION}"/plugins/"${PLUGIN}" -f xsl-instrument
	echo -e "\n\x1B[01;96m Testing ${PLUGIN} plugin \x1B[0m\n"
	dita --input dita-ot-"${DITA_OT_VERSION}"/plugins/"${PLUGIN}" -f unit-test -o /github/workspace -v
	if [ ! -z "${COVERALLS_TOKEN}" ]; then 
		echo -e "\n\x1B[01;96m Uploading Coverage report to coveralls \x1B[0m\n"
		cd /tmp
		git clone "${GITHUB_SERVER_URL}"/"${GITHUB_REPOSITORY}"
		cd "${GITHUB_REPOSITORY##*/}"
		cp /github/workspace/coverage.xml coverage.xml
		cp /opt/app/bin/dita-ot-"${DITA_OT_VERSION}"/plugins/fox.jason.unit-test/resource/pom.xml pom.xml
		mvn -q org.eluder.coveralls:coveralls-maven-plugin:report -DrepoToken="${COVERALLS_TOKEN}"
	fi
fi
