#! /bin/sh

import unittest/assert
import os

test_os_vars() {
    local expected_arch
    local expected_os
    local expected_kernel_name
    local expected_cpu_count
    local expected_mem_total

    expected_arch="$(uname -m)"
    expected_os="$(uname -o)"
    expected_kernel_name="$(uname -s)"
    expected_cpu_count=$(lscpu | awk '/^CPU\(s\)/ {print $2}')
    expected_mem_total=$(awk '/^MemTotal/ {printf("%.0f\n", $2 / 1024.0)}' /proc/meminfo)

    assert_equal "$expected_arch" "$_OS_ARCH"
    assert_equal "$expected_os" "$_OS_OS"
    assert_equal "$expected_kernel_name" "$_OS_KERNEL_NAME"
    assert_equal "$expected_cpu_count" "$_OS_CPU_COUNT"
    assert_equal "$expected_mem_total" "$_OS_MEM_TOTAL"
}

test_set_arch_short() {
    assert_equal 'amd64' "$(_os__get_arch_short x86_64)"
    assert_equal '386' "$(_os__get_arch_short x86)"
}
