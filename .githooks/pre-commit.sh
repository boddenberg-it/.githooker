#!/bin/bash

# usually .githooker must be part of 'path' but since we're .githooker itself there's no need to do so.
source generic_hooks.sh "pre-commit"

run_command_for_each_file ".sh" "shellcheck  -e SC2154 -e SC1090 -e SC2181 -e SC2086 -e SC2068 -e SC2046 -e SC1091"

run_command_once ".sh,.exp" "./tests/run_tests.sh"

exit $exit_code
