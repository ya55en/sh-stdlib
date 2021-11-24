#! /bin/sh

#: Install sh-stdlib.
#: sh-stdlib is a standard library for shell.

_LOCAL="$HOME/.local"
_LOCAL_SUBDIRS='bin lib opt share'

# TODO: do we need to honor POSIXSH_STDLIB_HOME here?
_SHSTDLIB_HOME="${POSIXSH_STDLIB_HOME:-${_LOCAL}/opt/sh-stdlib}"

_DOWNLOAD_CACHE=/tmp

_URL_LATEST=https://github.com/ya55en/sh-stdlib/releases/latest
_URL_DOWNLOAD_RE='^location: https://github.com/ya55en/sh-stdlib/releases/tag/v\(.*\)$'
__latest__=$(curl -Is $_URL_LATEST | grep ^location | tr -d '\n\r' | sed "s|$_URL_DOWNLOAD_RE|\1|")
__version__="${1:-$__latest__}" # version passed as an argument for unreleased builds

_SHSTDLIB_FILENAME="sh-stdlib-v${__version__}.tgz"
_URL_DOWNLOAD="https://github.com/ya55en/sh-stdlib/releases/download/v${__version__}/${_SHSTDLIB_FILENAME}"

if [ "$DEBUG" = true ]; then
    echo "DEBUG: HOME='${HOME}'"
    echo "DEBUG: _SHSTDLIB_HOME='${_SHSTDLIB_HOME}'"
    echo "DEBUG: _SHSTDLIB_FILENAME='${_SHSTDLIB_FILENAME}'"
    echo "DEBUG: _URL_DOWNLOAD='${_URL_DOWNLOAD}'"
    echo "DEBUG: __version__='${__version__}'"
fi

#: Create ~/.local/{bin,lib,opt,share}.
create_dot_local() {
    if [ -e "$_LOCAL" ]; then
        echo "W: $_LOCAL already exists, skipping."
    else
        echo "I: Creating directory ${_LOCAL}..."
        mkdir -p "${_LOCAL}"
    fi

    for directory in $_LOCAL_SUBDIRS; do
        thedir="${_LOCAL}/${directory}"
        if [ -e "${thedir}" ]; then
            echo "W: ${thedir} already exists, skipping."
        else
            echo "I: Creating ${thedir}..."
            mkdir "${thedir}"
        fi
    done
}

#: Download sh-stdlib core tarball and install it.
download_shstdlib_core() {
    target_file_path="${_DOWNLOAD_CACHE}/${_SHSTDLIB_FILENAME}"
    echo "install_shstdlib(): target_file_path=${target_file_path}"

    if [ -e "${target_file_path}" ]; then
        echo "Release file already downloaded, skipping."
    else
        echo "Downloading ${target_file_path}..."
        curl -sL "$_URL_DOWNLOAD" -o "${target_file_path}" ||
            die 9 "Download failed. (URL: $_URL_DOWNLOAD)"
    fi
}

#: Install sh-stdlib into $_SHSTDLIB_HOME, creating
#: $_SHSTDLIB_HOME/{bin,etc,lib,share/recipes}.
install_shstdlib_core() {
    target_file_path="${_DOWNLOAD_CACHE}/${_SHSTDLIB_FILENAME}"

    if [ -e "${_SHSTDLIB_HOME}" ]; then
        echo "Target directory already exists: ${_SHSTDLIB_HOME}, skipping."
    else
        echo "Deploying sh-stdlib archive to target directory ${_SHSTDLIB_HOME}..."
        mkdir -p "${_SHSTDLIB_HOME}"
        tar xf "${target_file_path}" -C "${_SHSTDLIB_HOME}"
    fi
}

#: Create ~/.bashrc.d/ .
create_bashrcd() {
    if [ -e "$HOME/.bashrc.d" ]; then
        echo "W: $HOME/.bashrc.d/ already exists, skipping."
    else
        echo "I: Creating $HOME/.bashrc.d/..."
        mkdir "$HOME/.bashrc.d"
    fi
}

#: Create bashrcd script ~/.bashrc.d/00-sh-stdlib-init.sh.
create_bashrcd_script_00() {
    target_file_path="$HOME/.bashrc.d/00-sh-stdlib-init.sh"

    if [ -e "${target_file_path}" ]; then
        echo "Bashrcd script '00-sh-stdlib-init.sh' already exists, skipping. (${target_file_path})"
    else
        echo "Installing bashrcd script ${target_file_path}..."
        cat > "${target_file_path}" << EOS
# ~/.bashrc.d/00-sh-stdlib-init.sh - sh-stdlib: initialization: first things first ;)

_LOCAL="\$HOME/.local"
_LOCAL_SHARE_APPS="\$_LOCAL/share/applications"

echo "\$PATH" | grep -q "\$_LOCAL/bin" || PATH="\$_LOCAL/bin:\$PATH"

# Set XDG_DATA_DIRS, if needed, so it includes user's private share section if it exists.
# See https://specifications.freedesktop.org/desktop-entry-spec/latest/ar01s02.html
echo "\$XDG_DATA_DIRS" | grep -q "\$_LOCAL_SHARE_APPS" ||
    XDG_DATA_DIRS="\$_LOCAL_SHARE_APPS:\$XDG_DATA_DIRS"

EOS
        echo "Adding POSIXSH_STDLIB_HOME setup to bashrcd script ${target_file_path}..."
        cat >> "${target_file_path}" << EOS

# sh-stdlib: set POSIXSH_STDLIB_HOME and add sh-stdlib/bin to PATH

POSIXSH_STDLIB_HOME="$_SHSTDLIB_HOME" ; export POSIXSH_STDLIB_HOME
echo \$PATH | grep -q "\$POSIXSH_STDLIB_HOME/bin" || PATH="\$POSIXSH_STDLIB_HOME/bin:\$PATH"
EOS

    fi
}

#: Create bashrcd script ~/.bashrc.d/99-sh-stdlib-import-path.sh.
create_bashrcd_script_99_import_path() {
    target_file_path="$HOME/.bashrc.d/99-sh-stdlib-import-path.sh"

    if [ -e "${target_file_path}" ]; then
        echo "bashrcd script '99-sh-stdlib-import-path.sh' already exists, skipping. (${target_file_path})"
    else
        echo "Installing bashrcd script ${target_file_path}..."
        cat > "${target_file_path}" << EOS
# ~/.bashrc.d/99-sh-stdlib-import-path.sh - sh-stdlib: set POSIXSH_IMPORT_PATH

# POSIXSH_IMPORT_PATH is necessary for sys.sh 'import()' to work.
echo "\$POSIXSH_IMPORT_PATH" | grep -q "\$POSIXSH_STDLIB_HOME/etc" || POSIXSH_IMPORT_PATH="\$POSIXSH_STDLIB_HOME/etc:\$POSIXSH_IMPORT_PATH"
echo "\$POSIXSH_IMPORT_PATH" | grep -q "\$POSIXSH_STDLIB_HOME/lib" || POSIXSH_IMPORT_PATH="\$POSIXSH_STDLIB_HOME/lib:\$POSIXSH_IMPORT_PATH"

export POSIXSH_IMPORT_PATH
export PATH

EOS
    fi
}

#: Add ~/.bashrc.d/ activation code to ~/.bashrc.
add_bashrcd_sourcing_snippet() {
    # shellcheck disable=SC2016
    if grep -q 'for file in "\$HOME/\.bashrc.d/"\*\.sh; do' ~/.bashrc; then
        echo "bashrc.d sourcing snippet already set, skipping."
    else
        echo "Setting bashrc.d sourcing snippet..."
        cat >> "$HOME/.bashrc" << EOS

#: sh-stdlib: sourcing initializing scripts from ~/.bashrc.d/*.sh
if [ -d "\$HOME/.bashrc.d/" ]; then
    for file in "\$HOME/.bashrc.d/"*.sh; do
        . "\$file"
    done
fi
EOS
    fi
}

#: Print adequate instructions on the console.
instruct_user() {
    cat << EOS

Please close and reopen any shell-based terminals
in order to refresh your variables.

TODO: ** Instruct user what to do after installation. **

TODO: Think on having a refresh-env command to reload env
vars from ~/bashrc.d/.

EOS
}

main() {
    create_dot_local
    download_shstdlib_core
    install_shstdlib_core
    create_bashrcd
    create_bashrcd_script_00
    create_bashrcd_script_99_import_path
    add_bashrcd_sourcing_snippet
    instruct_user
}

main
