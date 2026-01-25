#!/bin/bash -e

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

COUNT=0

. "${SCRIPT_DIR}/build.sh"

context () {
	TAG="$1"
	OCI=".oci.${TAG//\//-}"
	echo "${TAG}=oci-layout://${PWD}/${OCI}"
}

clean

#NO_CACHE=--no-cache

build mxe openscad/mxe-requirements $NO_CACHE "$@"
build mxe openscad/mxe-base --build-context srv=/srv/data "$@"
build mxe openscad/mxe-x86_64-deps "$@"
build mxe openscad/mxe-x86_64-gui "$@"
build mxe openscad/mxe-x86_64-openscad "$@"

list 'openscad/mxe-*'
