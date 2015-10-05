#!/bin/bash
set -e

function getCurrentPomVersion {
  mvn -q -Dexec.executable="echo" -Dexec.args='${project.version}' --non-recursive org.codehaus.mojo:exec-maven-plugin:1.4.0:exec 2> /dev/null
}

function incrementPomVersion {

  read currentPomVersion

	declare -a version=($(echo ${currentPomVersion} | tr - . | tr . ' '))

	if [ "$2" == "major" ]; then
		## [THIS].0.1-SNAPSHOT
		version[0]=$[${version[0]} + 1]
	elif [ "$2" == "minor" ]; then
		## 0.[THIS].1-SNAPSHOT
		version[1]=$[${version[1]} + 1]
	else
		## 0.0.[THIS]-SNAPSHOT
		version[2]=$[${version[2]} + 1]
	fi

	if [ -n ${version[3]} ]; then
		version[3]=-${version[3]}
	fi

	echo ${version[0]}.${version[1]}.${version[2]}${version[3]}
}

CURRENT_SNAP_VERSION=$(getCurrentPomVersion)
RELEASE_VERSION=${CURRENT_SNAP_VERSION%-SNAPSHOT}
NEXT_SNAP_VERSION=$(echo ${CURRENT_SNAP_VERSION} | incrementPomVersion)

echo "[INFO] Current Version: ${CURRENT_SNAP_VERSION}"
echo "[INFO] Release Version: ${RELEASE_VERSION}"
echo "[INFO] Next Version:    ${NEXT_SNAP_VERSION}"

# Change to release version
mvn versions:set -DnewVersion=${RELEASE_VERSION}

# Deploy changes to maven central
mvn clean deploy -P release

# Change to snapshot version
mvn versions:set -DnewVersion=${NEXT_SNAP_VERSION}
