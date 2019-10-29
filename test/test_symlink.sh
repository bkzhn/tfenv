#!/usr/bin/env bash

# Ensure we can execute standalone
[ -n "${TFENV_ROOT}" ] || export TFENV_ROOT="$(cd "$(dirname "${0}")/.." && pwd)";
[ -n "${TFENV_HELPERS}" ] || source "${TFENV_ROOT}/lib/helpers.sh";

declare -a errors

function error_and_proceed() {
  errors+=("${1}");
  log 'warn' "tfenv: ${0}: Test Failed: ${1}";
}

TFENV_BIN_DIR="/tmp/tfenv-test"
rm -rf "${TFENV_BIN_DIR}" && mkdir "${TFENV_BIN_DIR}"
ln -s "${PWD}"/bin/* "${TFENV_BIN_DIR}"
export PATH="${TFENV_BIN_DIR}:${PATH}"

echo "### Test supporting symlink"
cleanup || log 'error' "Cleanup failed?!"
tfenv install 0.8.2 || error_and_proceed "Install failed"
tfenv use 0.8.2 || error_and_proceed "Use failed"
check_version 0.8.2 || error_and_proceed "Version check failed"

if [ "${#errors[@]}" -gt 0 ]; then
  echo -e "===== The following symlink tests failed =====" >&2
  for error in "${errors[@]}"; do
    echo -e "\t${error}"
  done
  exit 1
else
  echo -e "All symlink tests passed."
fi;
exit 0
