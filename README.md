# Retro Game Dev

This is my personal repository for the code in RetroGameDev Volumes 1
and 2 book series converted to acme cross-assembler. To make it easy
to use, I've also added a `Makefile` to each chapter directory.

# Building

Choose a volume/chapter and run `make` on that directory. One can also
use the `-C` argument to `make` to instruct to execute on a
subdirectory. For example:

```
$ make -C volume1/chapter10
     AS       chapter10.prg
     D64      chapter10.d64
```

The target `run` will autoload the generated D64 image on either `x64`
or `x64sc` VICE emulator binary, whichever it finds.

```
$ make -C volume1/chapter10 run
Hotkeys: Initializing.
Hotkeys: Parsing C64 hotkeys file:
Hotkeys: OK.
[...]
```
