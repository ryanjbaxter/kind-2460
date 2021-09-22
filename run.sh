#!/bin/bash

# standard bash error handling
set -o errexit;
set -o pipefail;
set -o nounset;
# debug commands
set -x;

# working dir to install binaries etc, cleaned up on exit
BIN_DIR="$(mktemp -d)"
# kind binary will be here
KIND="${BIN_DIR}/kind"


CURRENT_DIR="$(pwd)"

# cleanup on exit (useful for running locally)
cleanup() {
    "${KIND}" delete cluster || true
    rm -rf "${BIN_DIR}"
}
trap cleanup EXIT

# util to install the latest kind version into ${BIN_DIR}
install_latest_kind() {
    # clone kind into a tempdir within BIN_DIR
    local tmp_dir
    tmp_dir="$(TMPDIR="${BIN_DIR}" mktemp -d "${BIN_DIR}/kind-source.XXXXX")"
    cd "${tmp_dir}" || exit
    git clone https://github.com/kubernetes-sigs/kind && cd ./kind
    make install INSTALL_DIR="${BIN_DIR}"
}

# util to install a released kind version into ${BIN_DIR}
install_kind_release() {
    VERSION="v0.11.1"
    KIND_BINARY_URL="https://github.com/kubernetes-sigs/kind/releases/download/${VERSION}/kind-linux-amd64"
    if [[ "$OSTYPE" == "darwin"*  ]]; then
        KIND_BINARY_URL="https://github.com/kubernetes-sigs/kind/releases/download/${VERSION}/kind-darwin-amd64"
	elif [[ "$OSTYPE" == "cygwin" ]]; then
        KIND_BINARY_URL="https://github.com/kubernetes-sigs/kind/releases/download/${VERSION}/kind-windows-amd64"
	elif [[ "$OSTYPE" == "msys" ]]; then
        KIND_BINARY_URL="https://github.com/kubernetes-sigs/kind/releases/download/${VERSION}/kind-windows-amd64"
	elif [[ "$OSTYPE" == "win32" ]]; then
        KIND_BINARY_URL="https://github.com/kubernetes-sigs/kind/releases/download/${VERSION}/kind-windows-amd64"
	else
        echo "Unknown OS, using linux binary"
	fi
    wget -O "${KIND}" "${KIND_BINARY_URL}"
    chmod +x "${KIND}"
}

main() {
    # get kind
    install_latest_kind

    # create a cluster
    cd $CURRENT_DIR

    #TODO what happens if cluster is already there????
    "${KIND}" create cluster

    # set KUBECONFIG to point to the cluster
    kubectl cluster-info --context kind-kind

	done

    # teardown will happen automatically on exit
}

main