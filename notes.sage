r"""
La descendance d'un monoide est finie ssi le pgcd des generateurs inférieurs
au conducteur est 1::

    sage: l = Full.nth_generation(6)
    sage: [(m.gcd_small_generator(), len(m.nth_generation(20))) for m in l]
    [(0, 36911), (6, 330), (1, 0), (1, 0), (1, 0), (1, 0), (5, 104), (1, 0), (1, 0), (1, 0), (1, 0), (1, 0), (1, 0), (4, 41), (1, 0), (1, 0), (2, 2), (1, 0), (1, 0), (3, 7), (1, 0), (1, 0), (2, 1)]

Nombre de monoides à descendance finie::

    sage: [sum([x^m.gcd_small_generator() for m in Full.nth_generation(i)]).coeff(x)
    ...    for i in range(15)]
    [0, 0, 0, 1, 3, 6, 16, 30, 54, 102, 186, 318, 562, 963, 1644]

Presque tous les monoides sont à descendance finie::

    [0 0 1 3  6 16 30 54 102 186 318 562  963 1644 2798 4735 7955 13355 22324]
    [1 2 4 7 12 23 39 67 118 204 343 592 1001 1693 2857 4806 8045 13467 22464]
"""

import os; os.sys.path.insert(0,os.path.abspath('cython'))
from numeric_monoid import *


def gtree(n):
    G = DiGraph()
    for i in range(n+1):
        for m in Full.nth_generation(i):
            for t in m.children():
                G.add_edge(m, t)
    G.set_latex_options(format='dot2tex', prog='dot')
    return G
