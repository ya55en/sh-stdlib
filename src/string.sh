#! /bin/sh
# Non-executable: string lib

_strip() {
    local special="$1"
    local str="$2"
    local chars="${3:- }"
    local res="$str"
    local res_old

    while true; do
        res_old="$res"
        # shellcheck disable=1083,2086
        eval "res="\${res${special}${chars}}""
        [ "$res_old" = "$res" ] && break
    done
    printf '%s' "$res"
}

#: TODO: doc
lstrip() {
    local _FUNCNAME=lstrip
    _debug "\$#=[$#]" >&2

    [ "$#" = 2 ] && [ -z "$2" ] && {
        printf '%s' "$1"
        return 0
    }

    _strip '#' "$1" "$2"
}

#: TODO: doc
rstrip() {
    local _FUNCNAME=rstrip
    _debug "\$#=[$#]" >&2

    [ "$#" = 2 ] && [ -z "$2" ] && {
        printf '%s' "$1"
        return 0
    }

    _strip '%' "$1" "$2"
}

#: TODO: doc
strip() {
    local _FUNCNAME=strip
    _debug "\$#=[$#]" >&2

    [ "$#" = 2 ] && [ -z "$2" ] && {
        printf '%s' "$1"
        return 0
    }

    local str="$1"
    local chars="${2:- }"
    local lstripped
    local rstripped

    lstripped=$(lstrip "$str" "$chars")
    rstripped=$(rstrip "$lstripped" "$chars")
    printf '%s' "$rstripped"
}

#: Evaluates the string argument and prints the resulting string.
reeval() {
    eval "printf '%s' $1"
}

#: Print length of given argument to stdout.
len() {
    printf '%u' ${#1}
}

#: Return success if "$2" is found within "$1", otherwise fail.
#: If $1 is empty, fail with '1', If $2 is empty, die promptly with 101
#: as behavior is undefined for $2=''.
contains() {
    # Empty string does not contain anything
    [ -z "$1" ] && return 1
    # Calling with empty substring is illegal
    [ -z "$2" ] && die 101 "string#contains: Illegal sub-string '$2'"
    [ -z "${1##*$2*}" ]
}

# contains() {
#     local str="$1"
#     local substr="$2"

#     # Empty string does not contain anything
#     [ -z "$str" ] && return 1

#     # Calling with empty substring is illegal
#     [ -z "$substr" ] && die 101 "string#contains: Illegal sub-string '$2'"

#     case "$str" in
#         *${substr}*)
#             return 0
#             ;;
#         *)
#             return 1
#             ;;
#     esac
# }

capitalize() {
    #: Echo back a capitalized version of given word.
    # (based on https://stackoverflow.com/questions/12487424)
    # BAD: Works only for lowercase input!
    # TODO: Provide a better implementation

    echo "$1" | sed 's/.*/\u&/'
}

upper() {
    echo -n "$1" | tr '[:lower:]' '[:upper:]'
}

lower() {
    echo -n "$1" | tr '[:upper:]' '[:lower:]'
}

#: Assign multiple space-delimited values of "$1" to multiple variables
#: given as the remaining arguments. Example:
#:   assign_multiple "ONE TWO THREE" one two three
#: We do not support custom delims, because IFS change affects
#: the way the list of variables is interpreted.
assign_multiple() {
    # IMPORTANT: IFS *must* be set *first* as it affects $* and $@!
    local multiple_values
    local varnames
    local IFS_SAVED="$IFS"
    IFS=' '

    multiple_values="$1"
    shift
    varnames="$*"

    # shellcheck disable=2086,2229
    read -r $varnames << EOS
$multiple_values
EOS
    IFS="$IFS_SAVED"
}
