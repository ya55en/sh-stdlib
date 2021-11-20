#!/bin/sh

#: End tests for the `shtest` test collector and executor. These tests
#: run independently (shtest is not used for execution) and thus rely
#: on comparing test case output to a predefined expected output, stored
#: in text files (given in vars _TEST_FULL_X_OUTPUT_PATH below).
#:
#: For recreating the expected output files, see
#: `create_expected_output()` documentation below.

. "$POSIXSH_STDLIB_HOME/sys.sh"

import unittest/assert
import unittest/shtest

_SHTEST_EXECUTABLE='src/unittest/shtest'
_OUTPUT_TMP_FILE='/tmp/test-shtest.output'
_SHTEST_SAMPLES_DIR='src/tests/test-data/shtest-samples'

_TEST_MODULE_1_PATH="$_SHTEST_SAMPLES_DIR/module-1"
_TEST_MODULE_2_PATH="$_SHTEST_SAMPLES_DIR/module-2"

_TEST_FULL_MODULE_1_PATH="$_SHTEST_SAMPLES_DIR/test-full/test-full-1.sh"
_TEST_FULL_MODULE_2_PATH="$_SHTEST_SAMPLES_DIR/test-full/test-full-2.sh"
_TEST_FULL_DIR_PATH="$_SHTEST_SAMPLES_DIR/test-full"

_TEST_FULL_1_OUTPUT_PATH="$_SHTEST_SAMPLES_DIR/test-full-1.output"
_TEST_FULL_2_OUTPUT_PATH="$_SHTEST_SAMPLES_DIR/test-full-2.output"
_TEST_FULL_3_OUTPUT_PATH="$_SHTEST_SAMPLES_DIR/test-full-3.output"

#: Create expected output files.  ** NOT USED NORMALLY! **
#: Will overwrite existing ones -- first make sure that your tests are
#: outputting what indeed is expected! Then replace (temporarily, then
#: revert!) the bottom call to `main` with a call to
# `create_expected_output`.
create_expected_output() {
    "$_SHTEST_EXECUTABLE" --with-samples "$_TEST_FULL_MODULE_1_PATH" > "$_TEST_FULL_1_OUTPUT_PATH"
    "$_SHTEST_EXECUTABLE" --with-samples "$_TEST_FULL_MODULE_2_PATH" -t test_pass > "$_TEST_FULL_2_OUTPUT_PATH"
    "$_SHTEST_EXECUTABLE" --with-samples "$_TEST_FULL_DIR_PATH" > "$_TEST_FULL_3_OUTPUT_PATH"
}

_assert_equal() {
    assert_equal "$1" "$2"
    status=$((status + $?))
}

test_parse_module_1() {
    local setup_mod_name=
    local teardown_mod_name=
    local setup_name=
    local teardown_name=
    local test_methods=

    parse_module "$_TEST_MODULE_1_PATH"
    status=0
    _assert_equal "$setup_mod_name" ""
    _assert_equal "$teardown_mod_name" ""
    _assert_equal "$setup_name" ""
    _assert_equal "$teardown_name" ""
    _assert_equal "$test_methods" " test_some_random_test test_second_test"
    if [ $status -eq 0 ]; then
        echo "ok 1 - test_parse_module_1: pass"
    fi
}

test_parse_module_2() {
    local setup_mod_name=
    local teardown_mod_name=
    local setup_name=
    local teardown_name=
    local test_methods=

    parse_module "$_TEST_MODULE_2_PATH"
    status=0
    _assert_equal "$setup_mod_name" "setup_mod"
    _assert_equal "$teardown_mod_name" "teardown_mod"
    _assert_equal "$setup_name" "setup"
    _assert_equal "$teardown_name" "teardown"
    _assert_equal "$test_methods" " test_method_1 test_number_2"
    if [ $status -eq 0 ]; then
        echo "ok 2 - test_parse_module_2: pass"
    fi
}

test_full_1() {
    "$_SHTEST_EXECUTABLE" --with-samples "$_TEST_FULL_MODULE_1_PATH" > "$_OUTPUT_TMP_FILE"
    assert_true diff -u "$_TEST_FULL_1_OUTPUT_PATH" "$_OUTPUT_TMP_FILE"
    if [ $? -eq 0 ]; then
        echo "ok 3 - test_full_1: pass"
    fi
}

test_full_2() { # TODO: uncomment when new version of shtest (-t functionality) is available
    "$_SHTEST_EXECUTABLE" --with-samples "$_TEST_FULL_MODULE_2_PATH" -t test_pass > "$_OUTPUT_TMP_FILE"
    assert_true diff -u "$_TEST_FULL_2_OUTPUT_PATH" "$_OUTPUT_TMP_FILE"
    if [ $? -eq 0 ]; then
        echo "ok 4 - test_full_2: pass"
    fi
}

test_full_3() {
    "$_SHTEST_EXECUTABLE" --with-samples "$_TEST_FULL_DIR_PATH" > "$_OUTPUT_TMP_FILE"
    assert_true diff -u "$_TEST_FULL_3_OUTPUT_PATH" "$_OUTPUT_TMP_FILE"
    if [ $? -eq 0 ]; then
        echo "ok 5 - test_full_3: pass"
    fi
}

setup_mod() {
    old_term="$TERM"
    TERM="xterm"
}

teardown_mod() {
    TERM="$old_term"
    rm -f "$_OUTPUT_TMP_FILE"
}

main() {
    setup_mod
    test_parse_module_1
    test_parse_module_2
    test_full_1
    test_full_2
    test_full_3
    teardown_mod
}

main
