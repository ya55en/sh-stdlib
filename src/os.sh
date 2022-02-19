#! /bin/sh

#: os standard module for sh-stdlib project.

_OS_ARCH=
_OS_ARCH_SHORT=
_OS_OS=
_OS_KERNEL_NAME=

# TODO: we might need kernel version and/or release variables

#: Set global processor/machine architecture related variables.
_os__set_vars() {
    IFS_SAVED="$IFS"
    IFS=' '

    # shellcheck disable=2034
    read -r _OS_KERNEL_NAME _OS_ARCH _OS_OS << EOS
$(uname -smo)
EOS

    IFS="$IFS_SAVED"
}

# shellcheck disable=2120
#: Print short version of the processor architecture tag. (Used
#: by recipes like `github-cli`.)
_os__get_arch_short() {

    os_arch=${1:-$_OS_ARCH}

    if [ "$os_arch" = x86_64 ]; then
        printf 'amd64'

    elif [ "$os_arch" = x86 ]; then
        printf '386'

    # TODO: provide mapping for all supported architectures
    else
        die 77 "Architecture not implemented yet: os_arch=[$os_arch]"
    fi
}

into_dir_do() {
    #: Save current working dir (cwd), then `cd` to given dir and execute
    #: the script, then `cd` back to the original dir.

    dir="$1" script="$2"

    [ -z "${script}" ] && die 42 "into_dir_do() called with empty script: [$script]"

    cwd="$(pwd)"
    rc=0
    cd "$dir" || {
        _error "cd into $dir FAILED"
        return $?
    }
    eval "$script" || {
        _error "into_dir_do(): eval FAILED: script=[$script]"
        return $?
    }
    _debug "into_dir_do(): eval rc=$?"
    cd "$cwd" || return 0
}

[ -z "$_OS_ARCH" ] && _os__set_vars
[ -z "$_OS_ARCH_SHORT" ] && _OS_ARCH_SHORT="$(_os__get_arch_short)"
