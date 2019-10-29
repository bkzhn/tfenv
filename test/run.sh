#!/usr/bin/env bash

if [ -n "${TFENV_DEBUG}" ]; then
  export PS4='+ [${BASH_SOURCE##*/}:${LINENO}] '
  set -x
fi
TFENV_ROOT="$(cd "$(dirname "${0}")/.." && pwd)"
export PATH="${TFENV_ROOT}/bin:${PATH}"

errors=()
if [ "${#}" -ne 0 ];then
  targets="${@}"
else
  targets="$(\ls "$(dirname "${0}")" | grep 'test_')"
fi

for t in ${targets}; do
  bash "$(dirname "${0}")/${t}" || errors+=( "${t}" )
done

if [ "${#errors[@]}" -ne 0 ];then
  log 'error' '===== The following test suites failed ====='
  for error in "${errors[@]}"; do
    log 'error' "\t${error}" >&2
  done
  exit 1
else
  log 'info' 'All test suites passed.'
fi
exit 0
