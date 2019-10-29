#!/usr/bin/env bash

# Ensure we can execute standalone
[ -n "${TFENV_ROOT}" ] || export TFENV_ROOT="$(cd "$(dirname "${0}")/.." && pwd)";
[ -n "${TFENV_HELPERS}" ] || source "${TFENV_ROOT}/lib/helpers.sh";

export PATH="${TFENV_ROOT}/bin:${PATH}";

errors=()
if [ "${#}" -ne 0 ]; then
  targets="${@}";
else
  targets="$(\ls "$(dirname "${0}")" | grep 'test_')";
fi

for t in ${targets}; do
  bash "$(dirname "${0}")/${t}" \
    || errors+=( "${t}" );
done;

if [ "${#errors[@]}" -ne 0 ]; then
  log 'warn' '===== The following test suites failed =====';
  for error in "${errors[@]}"; do
    log 'warn' "\t${error}";
  done;
  log 'error' 'Test suite failure(s)';
else
  log 'info' 'All test suites passed.';
fi;
exit 0;
