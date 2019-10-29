#!/usr/bin/env bash

# Ensure we can execute standalone
[ -n "${TFENV_ROOT}" ] || export TFENV_ROOT="$(cd "$(dirname "${0}")/.." && pwd)";
[ -n "${TFENV_HELPERS}" ] || source "${TFENV_ROOT}/lib/helpers.sh";

declare -a errors

function error_and_proceed() {
  errors+=("${1}");
  log 'warn' "tfenv: ${0}: Test Failed: ${1}";
}

echo "### List local versions"
cleanup || log 'error' "Cleanup failed?!"

for v in 0.7.2 0.7.13 0.9.1 0.9.2 0.9.11; do
  tfenv install "${v}" || error_and_proceed "Install of version ${v} failed"
done

result="$(tfenv list)"
expected="$(cat << EOS
* 0.9.11 (set by $(tfenv version-file))
  0.9.2
  0.9.1
  0.7.13
  0.7.2
EOS
)"

if [ "${expected}" != "${result}" ]; then
  error_and_proceed "List mismatch.\nExpected:\n${expected}\nGot:\n${result}"
fi

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
