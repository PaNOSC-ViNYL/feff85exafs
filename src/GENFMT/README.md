
# Content of the GENFMT folder

This directory contains routines for generalized F matrix
calculations, as described in
[the 1990 Rehr-Albers paper](http://dx.doi.org/10.1103/PhysRevB.41.8139).

All routines in this directory are covered by the [LICENSE](../HEADERS/license.h)

This directory also contains the Fortran subroutine `onepath.f` which
combines the F-matrix caluclation of `GENFMT/genfmt.f` with the
presentation of F-effective from `FF2X/feffdt.f`.  The `onepath`
subroutine can be called with a specified path geometry and it will
return the columns of the `feffNNNN.dat` file as arrays.  Optionally,
it can also write out a `feffNNNN.dat` file or a JSON file containing
all information from the `feffNNNN.dat` file.

Also here is a C wrapper around `onepath.f` called `feffpath.c`.  This
is compiled into `libfeffpath.so`.  `feffpath.h` defines a struct
containing all the information found in a `feffNNNN.dat` file.  See
[wrappers/C/makepath.c](../../wrappers/C/makepath.c) for an example of
the use of the C wrapper in a C program.

The C library can be wrapped for use in other languages.
[Here's a use of the perl wrapper as an example.](../../wrappers/perl/examples/pathsdat.pl)
[And here's a very simple larch script.](../../wrappers/python/makepath.lar)

# Build and install

To build, type `scons`.  This will build:

 * `libgenfmt.f`: most of the functionality of genfmt
 * `genfmt`: the stand-alone program
 * `libonepath.so`: the Fortran entry point for generating a single path
 * `libfeffpath.so`: the C wrapper around onepath
 * `perl/feffpath_wrap.c` and `perl/FeffPath.pm`: the SWIG wrapper for perl around feffpath
 * `pythin/feffpath_wrap.c` and `python/feffpathwrapper.py`: the SWIG wrapper for python around feffpath

Once built, type `scons install` to install everything:

 * `libgenfmt.f`, `libonepath.so`, `libfeffpath.so`: installed to `/usr/local/lib`
 * `genfmt`: installed to `/usr/local/bin`
 * `perl/feffpath_wrap.c` and `perl/FeffPath.pm`: installed to `../../wrappers/perl`
 * `python/feffpath_wrap.c` and `python/feffpathwrapper.py`: installed to `../../wrappers/python`

You **must** install before building the Perl or Python wrappers.
Other wrappers almost certainly require at least that `libfeffpath.so`
be installed.

# Simple static analysis

To make HTML files explaining data I/O for each fortran source file, do

	../src> ftnchek -mkhtml *.f

# Call graph

![call graph for the GENFMT folder](tree/genfmt.png)

# Feff's standard header

Feff's standard header, which is parsed by Larch's feffdat reader,
contains information that is available in several different parts of
Feff.

The following parameters are available (or readily computed) in
`onepath.f`:

 * `edge` : float, energy threshold relative to atomic value (a poor estimate)
 * `gam_ch` : float, core level energy width
 * `kf` : float, k value at Fermi level
 * `mu` : float, Fermi level, eV
 * `rnorman` : float, Norman radius
 * `version` : string, Feff version

The following are not available to `onepath.f`.  In normal Feff, these
are passed via common block in the form of the pre-written standard
header.  All of this information is written to `pot.bin` by the pot
module, read from `pot.bin` by xsph, and written to the standard
header in `xsph.f`.

 * `exch`, a string giving the electronic exchange model (see
   `head.f`, this is evaluated from `ixc` and a Data block
 * `r_MuffinTin` and `r_Norman` for each unique potential.  Larch
   places these in the `potentials` attribute, which is a list of tuples
 * `rs_int`, the interstitial radius
 * `vint`, the interstitial potential

The best solution would be to write that information into `phase.bin`
to that it can be read by `onepath`.
