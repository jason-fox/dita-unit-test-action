#! /bin/sh

# This file is part of the DITA-OT Unit Test GitHub Action project.
# See the accompanying LICENSE file for applicable licenses.

set -e

DITA_OT_VERSION="${1}"
PLUGIN="${2}"
PREREQUISITES="${3}"
SETUP_SCRIPT="${4:-test-setup.sh}"
FILE=/github/workspace/${SETUP_SCRIPT}
 
if [ ! -z "${DITA_OT_VERSION}" ]; then 
	echo "[INFO] Installing DITA-OT ${DITA_OT_VERSION}"
	rm -rf  /opt/app
	mkdir /opt/app

	curl -sLo /tmp/dita-ot-"${DITA_OT_VERSION}".zip https://github.com/dita-ot/dita-ot/releases/download/"${DITA_OT_VERSION}"/dita-ot-"${DITA_OT_VERSION}".zip
    unzip -qq /tmp/dita-ot-"${DITA_OT_VERSION}".zip -d /tmp/
    rm /tmp/dita-ot-"${DITA_OT_VERSION}".zip
    mkdir -p /opt/app/
    mv /tmp/dita-ot-"${DITA_OT_VERSION}"/bin /opt/app/bin
    chmod 755 /opt/app/bin/dita
    mv /tmp/dita-ot-"${DITA_OT_VERSION}"/config /opt/app/config
    mv /tmp/dita-ot-"${DITA_OT_VERSION}"/lib /opt/app/lib
    mv /tmp/dita-ot-"${DITA_OT_VERSION}"/plugins /opt/app/plugins
    mv /tmp/dita-ot-"${DITA_OT_VERSION}"/build.xml /opt/app/build.xml
    mv /tmp/dita-ot-"${DITA_OT_VERSION}"/integrator.xml /opt/app/integrator.xml
    rm -r /tmp/dita-ot-"${DITA_OT_VERSION}"
	dita --install
fi


echo "[INFO]" $(dita --version)
echo "[INFO] Installing DITA-OT Unit Test Harness"
dita --install \
	https://github.com/doctales/org.doctales.xmltask/archive/master.zip
dita --install \
	https://github.com/jason-fox/fox.jason.unit-test/archive/master.zip

if [ -f "$FILE" ]; then
	echo "[INFO] Installing additional runtime dependencies"
	"${FILE}"
fi

if [ ! -z "${PREREQUISITES}" ]; then 
	echo "[INFO] Installing prequisite DITA-OT plugins"
	list=$(echo "$PREREQUISITES" | tr "," "\n")
	for prereq in $list
	do
		dita install "$prereq"
	done
fi


if [ -z "${PLUGIN}"  ]; then 
	echo "No plugin to test"
else
	cp -r /github/workspace /opt/app/plugins/"${PLUGIN}"
	dita --install
	echo "[INFO] Instrumenting ${PLUGIN} plugin"
	dita --input /opt/app/plugins/"${PLUGIN}" -f xsl-instrument
	echo "[INFO] Testing ${PLUGIN} plugin"
	dita --input /opt/app/plugins/"${PLUGIN}" -f unit-test -o /github/workspace -v
	if [ ! -z "${COVERALLS_TOKEN}" ]; then 
		echo "[INFO] Uploading Coverage report to coveralls"
		cd /tmp
		git clone "${GITHUB_SERVER_URL}"/"${GITHUB_REPOSITORY}"
		cd "${GITHUB_REPOSITORY##*/}"
		cp /opt/app/plugins/"${PLUGIN}"/*.xml .
		cp /github/workspace/coverage.xml coverage.xml
		cp /opt/app/plugins/fox.jason.unit-test/resource/pom.xml pom.xml
		/opt/apache-maven-3.9.3/bin/mvn -q org.eluder.coveralls:coveralls-maven-plugin:report -DrepoToken="${COVERALLS_TOKEN}"
	fi
fi
