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
CILK_DIR = '/home/florent/install/Cilk-gcc/gcc-cilk'

import Cython.Compiler.Options
Cython.Compiler.Options.annotate = True

setup(
    cmdclass = {'build_ext': build_ext},
    ext_modules = [
        Extension('numeric_monoid',
                  sources = ['numeric_monoid.pyx'],
                  language="c++", 
                  include_dirs = [SAGE_C],
                  extra_compile_args = ['-std=c++0x', '-O3', '-march=native', '-mtune=native'],
                  library_dirs = [CILK_DIR + '/lib64'],
                  #  'cilkrts' should be here
                  # but then sage needs to be run with the correct LD_LIBRARY_PATH            
                  libraries = ['csage',],
                  depends = ['../monoid.hpp', 'cmonoid.pxd'],
                  define_macros = [('NDEBUG', '1')],
                  extra_objects = ['../monoid-cy.o', '../treewalk-cy.o',
                                   CILK_DIR + '/lib64/' + 'libcilkrts.a']
                  ),
        ])

