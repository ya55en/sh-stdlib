# sh-stdlib

A (proto) standard library for posix-compatible shells.

We needed a sort of stdlib for POSIX-compatible Bourne Shell and couldn't find one, so we decided to set this project
up.


## Status

This project is an alpha (very preliminary!) state of development.


## Modules

Currently, we have initial versions of:

- sys
- os
- logging
- string
- path
- unittest


## Install

(IMPORTANT: Do not install on a production machine -- use a Virtual Machine or another way to isolate the installation.)

Download and run the installer with a single command:

```bash

 curl -sSL https://github.com/ya55en/sh-stdlib/raw/main/install.sh | sh
```


## Development

### Set up the environment

To get your repository code to take effect when you run `shtest`, do:

```bash
$ eval `make setenv`
```

(BTW, this will, behind the scenes, create a `src/bin/` directory and place a symlink to `shtest` there. This directory
will finally end up being added to your `PATH`.)

Check that you get the right `shtest` executable:

```bash
$ which shtest
/home/{USER}/{WorkDir}/sh-stdlib/src/bin/shtest
```

### Run tests

```bash
$ shtest src/tests/ | bin/tapview
```

Or, if detailed report is desired, just:

```bash
$ shtest src/tests/
```

Individual suites can also be run, like:

```bash
$ shtest src/tests/test-string.sh | bin/tapview
```

### Create a dist file

To get the current code packed into a tarball located at `dist/sh-stdlib-vx.y.z-abcde.tgz`, do:

```bash
$ make dist
```

The tarball name above is a pattern; `x.y.z` represents the current version (something like `0.2.1`)
and `abcde` represent the first five characters if the commit hash.

The command would do nothing if the tarball exists and there are no changes in the source files. To force `make dist` to
have an effect, first clean the `dist/` directory:

```bash
 $ make clean-dist
```


## Known issues

Lots of things to do and improve! ;)


## License

MIT -- see `LICENSE` file.
