#!/usr/bin/env bash

# Ensure we can execute standalone
[ -n "${TFENV_ROOT}" ] || export TFENV_ROOT="$(cd "$(dirname "${0}")/.." && pwd)";
[ -n "${TFENV_HELPERS}" ] || source "${TFENV_ROOT}/lib/helpers.sh";

declare -a errors;

function error_and_proceed() {
  errors+=("${1}");
  log 'warn' "tfenv: ${0}: Test Failed: ${1}";
};

log 'info' 'Install latest version';
cleanup || log 'error' 'Cleanup failed?!';

v="$(tfenv list-remote | grep -e "^[0-9]\+\.[0-9]\+\.[0-9]\+$" | head -n 1)";
(
  tfenv install latest || exit 1;
  check_version "${v}" || exit 1;
) || error_and_proceed "Installing latest version ${v}";

log 'info' 'Install latest possibly-unstable version';
cleanup || log 'error' 'Cleanup failed?!';

v="$(tfenv list-remote | head -n 1)";
(
  tfenv install latest: || exit 1;
  check_version "${v}" || exit 1;
) || error_and_proceed "Installing latest possibly-unstable version ${v}";

log 'info' 'Install latest alpha';
cleanup || log 'error' 'Cleanup failed?!';

v="$(tfenv list-remote | grep 'alpha' | head -n 1)";
(
  tfenv install latest:alpha || exit 1;
  check_version "${v}" || exit 1;
) || error_and_proceed "Installing latest alpha ${v}";

log 'info' 'Install latest beta';
cleanup || log 'error' 'Cleanup failed?!';

v="$(tfenv list-remote | grep 'beta' | head -n 1)";
(
  tfenv install latest:beta || exit 1;
  check_version "${v}" || exit 1;
) || error_and_proceed "Installing latest beta ${v}";

log 'info' 'Install latest rc';
cleanup || log 'error' 'Cleanup failed?!';

v="$(tfenv list-remote | grep 'rc' | head -n 1)";
(
  tfenv install latest:rc || exit 1;
  check_version "${v}" || exit 1;
) || error_and_proceed "Installing latest rc ${v}";

log 'info' 'Install latest possibly-unstable version from 0.11';
cleanup || log 'error' 'Cleanup failed?!';

v="$(tfenv list-remote | grep '^0\.11\.' | head -n 1)";
(
  tfenv install latest:^0.11. || exit 1;
  check_version "${v}" || exit 1;
) || error_and_proceed "Installing latest possibly-unstable version from 0.11: ${v}";

log 'info' 'Install 0.11.15-oci';
cleanup || log 'error' 'Cleanup failed?!';

v='0.11.15-oci';
(
  tfenv install 0.11.15-oci || exit 1;
  check_version "${v}" || exit 1;
) || error_and_proceed "Installing version ${v}";

log 'info' 'Install latest version with Regex';
cleanup || log 'error' 'Cleanup failed?!';

v='0.8.8';
(
  tfenv install latest:^0.8 || exit 1;
  check_version "${v}" || exit 1;
) || error_and_proceed "Installing latest version ${v} with Regex";

log 'info' 'Install specific version';
cleanup || log 'error' 'Cleanup failed?!';

v='0.7.13';
(
  tfenv install "${v}" || exit 1;
  check_version "${v}" || exit 1;
) || error_and_proceed "Installing specific version ${v}";

log 'info' 'Install specific .terraform-version';
cleanup || log 'error' 'Cleanup failed?!';

v='0.9.1';
echo "${v}" > ./.terraform-version;
(
  tfenv install || exit 1;
  check_version "${v}" || exit 1;
) || error_and_proceed "Installing .terraform-version ${v}";

log 'info' 'Install latest:<regex> .terraform-version';
cleanup || log 'error' 'Cleanup failed?!';

v="$(tfenv list-remote | grep -e '^0.8' | head -n 1)";
echo "latest:^0.8" > ./.terraform-version;
(
  tfenv install || exit 1;
  check_version "${v}" || exit 1;
) || error_and_proceed "Installing .terraform-version ${v}";

log 'info' "Install with ${HOME}/.terraform-version";
cleanup || log 'error' 'Cleanup failed?!';

if [ -f "${HOME}/.terraform-version" ]; then
  mv "${HOME}/.terraform-version" "${HOME}/.terraform-version.bup";
fi;
v="$(tfenv list-remote | grep -e "^[0-9]\+\.[0-9]\+\.[0-9]\+$" | head -n 2 | tail -n 1)";
echo "${v}" > "${HOME}/.terraform-version";
(
  tfenv install || exit 1;
  check_version "${v}" || exit 1;
) || error_and_proceed "Installing ${HOME}/.terraform-version ${v}";

log 'info' 'Install with parameter and use ~/.terraform-version';
v="$(tfenv list-remote | grep -e "^[0-9]\+\.[0-9]\+\.[0-9]\+$" | head -n 1)";
(
  tfenv install "${v}" || exit 1;
  check_version "${v}" || exit 1;
) || error_and_proceed "Use ${HOME}/.terraform-version ${v}";

log 'info' 'Use with parameter and  ~/.terraform-version';
v="$(tfenv list-remote | grep -e "^[0-9]\+\.[0-9]\+\.[0-9]\+$" | head -n 2 | tail -n 1)";
(
  tfenv use "${v}" || exit 1;
  check_version "${v}" || exit 1;
) || error_and_proceed "Use ${HOME}/.terraform-version ${v}";

rm "${HOME}/.terraform-version";
if [ -f "${HOME}/.terraform-version.bup" ]; then
  mv "${HOME}/.terraform-version.bup" "${HOME}/.terraform-version";
fi;

log 'info' 'Install invalid specific version';
cleanup || log 'error' 'Cleanup failed?!';

v="9.9.9";
expected_error_message="No versions matching '${v}' found in remote";
[ -z "$(tfenv install "${v}" 2>&1 | grep "${expected_error_message}")" ] \
  && error_and_proceed "Installing invalid version ${v}";

log 'info' 'Install invalid latest:<regex> version';
cleanup || log 'error' 'Cleanup failed?!';

v="latest:word";
expected_error_message="No versions matching '${v}' found in remote";
[ -z "$(tfenv install "${v}" 2>&1 | grep "${expected_error_message}")" ] \
  && error_and_proceed "Installing invalid version ${v}";

if [ "${#errors[@]}" -gt 0 ]; then
  log 'warn' '===== The following install_and_use tests failed =====';
  for error in "${errors[@]}"; do
    log 'warn' "\t${error}";
  done
  log 'error' 'Test failure(s): install_and_use';
else
  log 'info' 'All install_and_use tests passed';
fi;
exit 0;
