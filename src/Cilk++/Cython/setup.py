# call with
# CC=/home/florent/install/Cilk-gcc/gcc-cilk/bin/g++ sage -python setup.py build_ext --inplace

import os
from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext
from distutils.extension import Extension
from sage.env import *

SAGE_INC = os.path.join(SAGE_LOCAL, 'include')
SAGE_C   = os.path.join(SAGE_SRC, 'c_lib', 'include')
CILK_INC = '/usr/local/include/cilk/'

import Cython.Compiler.Options
Cython.Compiler.Options.annotate = True

setup(
    cmdclass = {'build_ext': build_ext},
    ext_modules = [
        Extension('numeric_monoid',
                  sources = ['numeric_monoid.pyx'],
                  language="c++", 
                  include_dirs = [SAGE_INC, SAGE_C],
                  extra_compile_args = ['-std=c++0x', '-O3', '-march=native', '-mtune=native'],
                  depends = ['../monoid.hpp', 'cmonoid.pxd'],
                  define_macros = [('NDEBUG', '1')],
                  #extra_objects = ['../src/monoid.o']
                  ),
        # Extension('moncilk',
        #           sources = ['moncilk.pyx'],
        #           include_dirs = [SAGE_INC, SAGE_C, CILK_INC],
        #           extra_compile_args = ['-flto', '-march=native', '-mtune=native'],
        #           depends = ['../src/monoid.c', '../src/monoid.h',
        #                      '../src/monoid.c', '../src/alarm.h',
        #                      '../src/mongen.cilk','../src/mongen.h',
        #                      'cmonoid.pxd', 'numeric_monoid.pxd'],
        #           define_macros = [('NDEBUG', '1')],
        #           extra_objects = ['../src/monoid.o', '../src/mongen.o', '../src/alarm.o'],
        #           library_dirs = ['/usr/local/lib64/cilk'],
        #           libraries = ['cilkrt0', 'cilk'])
        ])

