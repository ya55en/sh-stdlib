#!/bin/sh

#: End-user level tests for `sys.sh`.

# import sys by sys ... but hey, this shows explicitly
# what is under test ;)
import sys
import unittest/assert

setup_mod() {
    _POSIXSH_IMPORT_PATH_OLD="$POSIXSH_IMPORT_PATH"
    __test_dir=
}

teardown_mod() {
    POSIXSH_IMPORT_PATH="$_POSIXSH_IMPORT_PATH_OLD"
    unset _POSIXSH_IMPORT_PATH_OLD
    unset __test_dir
}

setup() {
    __test_dir="$(dirname "$_mod_path_")"
}

test_enduse_case_1() {
    POSIXSH_IMPORT_PATH="$__test_dir/test-data:$__test_dir"
    import foorc
    import bar
    import foo-pkg/foo-pkg-bar
    import foo-pkg/foo-pkg-bazzrc
    import bar
    import foorc
    import foo-pkg/foo-pkg-bar

    assert_equal 'bar_sh_func() called' "$(bar_sh_func)"
    assert_equal 'foorc_func() called' "$(foorc_func)"
    assert_equal 'foo_pkg_bar_sh_func() called' "$(foo_pkg_bar_sh_func)"
    assert_equal 'foo_pkg_bazzrc_func() called' "$(foo_pkg_bazzrc_func)"
}
