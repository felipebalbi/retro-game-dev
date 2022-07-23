# Retro Game Dev

This is my personal repository for the code in RetroGameDev Volume 1
book converted to acme cross-assembler. To make it easy to use, I've
also added a `Makefile` to each directory.

# Building

Choose a diretory and run `make` on that directory. One can also use
the `-C` argument to `make` to instruct to execute on a
subdirectory. For example:

```
$ make -C chapter10
     AS       chapter10.prg
     D64      chapter10.d64
```

The target `run` will autoload the generated D64 image on either `x64`
or `x64sc` VICE emulator binary, whichever it finds.

```
$ make -C chapter10 run
Hotkeys: Initializing.
Hotkeys: Parsing C64 hotkeys file:
Hotkeys: OK.
[...]
```
