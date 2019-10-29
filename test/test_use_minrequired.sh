#!/usr/bin/env bash

# Ensure we can execute standalone
[ -n "${TFENV_ROOT}" ] || export TFENV_ROOT="$(cd "$(dirname "${0}")/.." && pwd)";
[ -n "${TFENV_HELPERS}" ] || source "${TFENV_ROOT}/lib/helpers.sh";

declare -a errors

function error_and_proceed() {
  errors+=("${1}");
  log 'warn' "tfenv: ${0}: Test Failed: ${1}";
}

echo "### Install not min-required version"
cleanup || log 'error' "Cleanup failed?!"

v="0.8.8"
minv="0.8.0"
(
  tfenv install "${v}" || true
  tfenv use "${v}" || exit 1
  check_version "${v}" || exit 1
) || error_and_proceed "Installing specific version ${v}"

echo "terraform {

  required_version = \">=${minv}\"
}" >> min_required.tf

tfenv install min-required
tfenv use min-required

check_version "${minv}" || error_and_proceed "Min required version doesn't match"

cleanup || log 'error' "Cleanup failed?!"


if [ "${#errors[@]}" -gt 0 ]; then
  echo -e "===== The following install_and_use tests failed =====" >&2
  for error in "${errors[@]}"; do
    echo -e "\t${error}"
  done
  exit 1
else
  echo -e "All install_and_use tests passed."
fi;
exit 0
