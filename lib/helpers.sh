#!/usr/bin/env bash

set -uo pipefail;

if [ -n "${TFENV_DEBUG:-""}" ]; then
  [ -n "${DEBUG:=""}" ] || export DEBUG="${TFENV_DEBUG}";
  if [[ "${TFENV_DEBUG}" -gt 1 ]]; then
    export PS4='+ [${BASH_SOURCE##*/}:${LINENO}] ';
    set -x;
  fi;
fi;

[ -n "${TFENV_ROOT:-""}" ] || export TFENV_ROOT="$(cd "$(dirname "${0}")/.." && pwd)"
source "${TFENV_ROOT}/lib/bashlog.sh";

# Curl wrapper to switch TLS option for each OS
function curlw () {
  local TLS_OPT="--tlsv1.2"

  # Check if curl is 10.12.6 or above
  if [[ -n "$(command -v sw_vers 2>/dev/null)" && ("$(sw_vers)" =~ 10\.12\.([6-9]|[0-9]{2}) || "$(sw_vers)" =~ 10\.1[3-9]) ]]; then
    TLS_OPT=""
  fi

  curl ${TLS_OPT} "$@"
}

check_version() {
  v="${1}"
  [ -n "$(terraform --version | grep -E "^Terraform v${v}((-dev)|( \([a-f0-9]+\)))?$")" ]
}

cleanup() {
  rm -rf ./versions
  rm -rf ./.terraform-version
  rm -rf ./min_required.tf
}

export TFENV_HELPERS=1;
