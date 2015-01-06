## -*- python -*-
## feff85exafs build system based on scons
## see HEADERS/license.h for license information

import sys
sys.path.append( 'src' )
from FeffBuild import CompilationEnvironment, InstallEnvironment

env  = CompilationEnvironment()

#env = Environment()
print '\n\tFortran compiler is ' + env['FORTRAN']
ienv = InstallEnvironment()
print "\tinstallation prefix is: " + ienv['i_prefix'] +"\n"

SConscript([
            'src/PAR/SConstruct',
            'src/COMMON/SConstruct',
            'src/json-fortran/SConstruct',
            'src/JSON/SConstruct',
            'src/MATH/SConstruct',
            'src/ATOM/SConstruct',
            'src/DEBYE/SConstruct',
            'src/EXCH/SConstruct',
            'src/FOVRG/SConstruct',
            'src/FMS/SConstruct',
            'src/RDINP/SConstruct',
            'src/POT/SConstruct',
            'src/XSPH/SConstruct',
            'src/PATH/SConstruct',
            'src/GENFMT/SConstruct',
	    'src/FF2X/SConstruct',
        ])

# RDINP  -> feff.inp reader
# POT    -> module 1
# XSPH   -> module 2
# FMS    -> module 3, executable is not a part of feff85exafs
# PATH   -> module 4
# GENFMT -> module 5
# FF2X   -> module 6
