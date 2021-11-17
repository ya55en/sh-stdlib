import unittest/assert

test_pass() {
    assert_true true
}

test_fail() {
    assert_true false
}

setup() {
    echo "setup()"
}

teardown() {
    echo "teardown()"
}

setup_mod() {
    echo "setup_mod()"
}

teardown_mod() {
    echo "teardown_mod()"
}