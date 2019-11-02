#!/usr/bin/env bash

set -uo pipefail;

# Ensure we can execute standalone
if [ -n "${TFENV_ROOT:-""}" ]; then
  if [ "${TFENV_DEBUG:-0}" -gt 1 ]; then
    [ -n "${TFENV_HELPERS:-""}" ] \
      && log 'debug' "TFENV_ROOT already defined as ${TFENV_ROOT}" \
      || echo "[DEBUG] TFENV_ROOT already defined as ${TFENV_ROOT}";
  fi;
else
  export TFENV_ROOT="$(cd "$(dirname "${0}")/.." && pwd)";
  if [ "${TFENV_DEBUG:-0}" -gt 1 ]; then
    [ -n "${TFENV_HELPERS:-""}" ] \
      && log 'debug' "TFENV_ROOT declared as ${TFENV_ROOT}" \
      || echo "[DEBUG] TFENV_ROOT declared as ${TFENV_ROOT}";
  fi;
fi;

if [ -n "${TFENV_HELPERS:-""}" ]; then
  log 'debug' 'TFENV_HELPERS is set, not sourcing helpers again';
else
  [ "${TFENV_DEBUG:-0}" -gt 1 ] && echo "[DEBUG] Sourcing helpers from ${TFENV_ROOT}/lib/helpers.sh";
  if source "${TFENV_ROOT}/lib/helpers.sh"; then
    log 'debug' 'Helpers sourced successfully';
  else
    echo "[ERROR] Failed to source helpers from ${TFENV_ROOT}/lib/helpers.sh" >&2;
    exit 1;
  fi;
fi;

declare -a errors

function error_and_proceed() {
  errors+=("${1}");
  log 'warn' "tfenv: ${0}: Test Failed: ${1}";
}

echo "### Uninstall local versions"
cleanup || log 'error' "Cleanup failed?!"

v="0.11.15-oci"
(
  tfenv install "${v}" || exit 1
  tfenv uninstall "${v}" || exit 1
  check_version "${v}" && exit 1 || exit 0
) || error_and_proceed "Uninstall of version "${v}" failed"

v="0.9.1"
(
  tfenv install "${v}" || exit 1
  tfenv uninstall "${v}" || exit 1
  check_version "${v}" && exit 1 || exit 0
) || error_and_proceed "Uninstall of version "${v}" failed"

echo "### Uninstall latest version"
cleanup || log 'error' "Cleanup failed?!"

v="$(tfenv list-remote | head -n 1)"
(
  tfenv install latest || exit 1
  tfenv uninstall latest || exit 1
  check_version "${v}" && exit 1 || exit 0
) || error_and_proceed "Uninstalling latest version ${v}"

echo "### Uninstall latest version with Regex"
cleanup || log 'error' "Cleanup failed?!"

v="$(tfenv list-remote | grep 0.8 | head -n 1)"
(
  tfenv install latest:^0.8 || exit 1
  tfenv uninstall latest:^0.8 || exit 1
  check_version "${v}" && exit 1 || exit 0
) || error_and_proceed "Uninstalling latest version "${v}" with Regex"

if [ "${#errors[@]}" -gt 0 ]; then
  echo -e "===== The following list tests failed =====" >&2
  for error in "${errors[@]}"; do
    echo -e "\t${error}"
  done
  exit 1
else
  echo -e "All list tests passed."
fi;
exit 0
