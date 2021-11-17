# posix-sh

Stdlib for posix-compatible shells.

We needed a sort of stdlib for POSIX-compatible Bourne Shell and couldn't
find one, so we decided to set this project up.

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


## Development

To get your repository code to take effect when you run `shtest`, do:

```bash
$ eval `make setenv`
```

(BTW, this will, behind the scenes, create a `src/bin/` directory and place
a symlink to `shtest` there. This directory will finally end up being added
to your `PATH`.)

Check that you get the right `shtest` executable:

```bash
$ which shtest
/home/{USER}/{WorkDir}/sh-stdlib/src/bin/shtest
```


## Known issues

Lots of things to do and improve! ;)


## License

MIT
