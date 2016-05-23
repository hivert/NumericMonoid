# call with
# sage -python setup.py build_ext --inplace

import os, sys, platform

try:
    CILK_ROOT = os.environ['CILK_ROOT']
except KeyError:
    raise EnvironmentError, "Please define the CILK_ROOT environment variable !"
# setup the gcc/cilk compiler
if 'CC' not in os.environ:
    os.environ['CC'] = os.path.join(CILK_ROOT, 'bin', 'g++-5')


from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext
from distutils.extension import Extension
from sage.env import *

#SAGE_INC = os.path.join(SAGE_LOCAL, 'include')
#SAGE_C   = os.path.join(SAGE_SRC, 'c_lib', 'include')
#SAGE_DEV = os.path.join(SAGE_ROOT, 'src')


if platform.system()=="Darwin":
    MARCH='-march=corei7'
    MTUNE='-march=corei7'
    CILK_LIB = os.path.join(CILK_ROOT, 'lib')
else:
    MARCH='-march=native'
    MTUNE='-march=native'
    CILK_LIB = os.path.join(CILK_ROOT, 'lib64')

import Cython.Compiler.Options
Cython.Compiler.Options.annotate = True

sage_include = sage_include_directories()
packs = [x for x in sage_include if x.endswith('site-packages')][0]
sage_include.append(os.path.join(packs, 'cysignals'))

#sage_include+=sys.path
#sage_include.append('/home/data/Sage-Install/sage-7.2.beta2/local/lib/python2.7/site-packages/cysignals/')


setup(
    cmdclass = {'build_ext': build_ext},
    ext_modules = [
        Extension('numeric_monoid',
                  sources = ['numeric_monoid.pyx', 'monoid.cpp', 'treewalk.cpp'],
                  depends = ['numeric_monoid.pxd', 'monoid.hpp', 'treewalk.hpp'],
                  language="c++",
                  extra_compile_args = ['-std=c++11', '-O3',
                                        MARCH, MTUNE,
                                        '-fcilkplus'],
                  define_macros = [('NDEBUG', '1'), ('MAX_GENUS','86')],
                  include_dirs = sage_include, # [SAGE_C,SAGE_DEV],
                  library_dirs = [CILK_LIB],
                  runtime_library_dirs = [CILK_LIB],
                  libraries = ['cilkrts'],
                  ),
        ])

