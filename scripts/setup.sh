#!/bin/bash

set -eu -o pipefail

: "${SKIP_DEFAULT_NAMESPACE_CREATION:=false}"
: "${DEFAULT_NAMESPACE:=default}"
: "${DEFAULT_NAMESPACE_RETENTION:=1}"

: "${SKIP_ADD_CUSTOM_SEARCH_ATTRIBUTES:=false}"

register_default_namespace() {
	echo "Registering default namespace: ${DEFAULT_NAMESPACE}."
	if ! temporal operator namespace describe "${DEFAULT_NAMESPACE}"; then
		echo "Default namespace ${DEFAULT_NAMESPACE} not found. Creating..."
		temporal operator namespace create --retention "${DEFAULT_NAMESPACE_RETENTION}" --description "Default namespace for Temporal Server." "${DEFAULT_NAMESPACE}"
		echo "Default namespace ${DEFAULT_NAMESPACE} registration complete."
	else
		echo "Default namespace ${DEFAULT_NAMESPACE} already registered."
	fi
}

add_custom_search_attributes() {
	until temporal operator search-attribute list --namespace "${DEFAULT_NAMESPACE}"; do
		echo "Waiting for namespace cache to refresh..."
		sleep 1
	done
	echo "Namespace cache refreshed."

	echo "Adding Custom*Field search attributes."
	# TODO: Remove CustomStringField
	# @@@SNIPSTART add-custom-search-attributes-for-testing-command
	temporal operator search-attribute create --namespace "${DEFAULT_NAMESPACE}" \
		--name CustomKeywordField --type Keyword \
		--name CustomStringField --type Text \
		--name CustomTextField --type Text \
		--name CustomIntField --type Int \
		--name CustomDatetimeField --type Datetime \
		--name CustomDoubleField --type Double \
		--name CustomBoolField --type Bool
	# @@@SNIPEND
}

setup_server() {
	echo "Temporal CLI address: 127.0.0.1:7233."

	until temporal operator cluster health | grep SERVING; do
		echo "Waiting for Temporal server to start..."
		sleep 1
	done
	echo "Temporal server started."

	if [[ ${SKIP_DEFAULT_NAMESPACE_CREATION} != true ]]; then
		register_default_namespace
	fi

	if [[ ${SKIP_ADD_CUSTOM_SEARCH_ATTRIBUTES} != true ]]; then
		add_custom_search_attributes
	fi
}

# Run this func in parallel process. It will wait for server to start and then run required steps.
setup_server &
