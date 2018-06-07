# NumericMonoid: Cilk++ version

This is the last and definitive version of NumericMonoid.

It requires GCC 5 and (not mandatory) [Sage](http://www.sagemath.org/).

## Building

If you have multiple versions of GCC installed on your system, you have to specify it to the `make` command:
```
CXX=g++-5 make treewalk MAX_GENUS=40
```

If you only have GCC 5 installed and wish to use the default `MAX_GENUS` (40), simply launch:
```
make treewalk
```
