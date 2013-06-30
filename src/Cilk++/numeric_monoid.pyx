r"""
Recompile with::

    sage -python setup.py build_ext --inplace

Due to compilation outside Sage, the option `--force_lib` has ot be given for
doctests to prevent Sage for recompiling this file. The doctest command is::

    sage -t --force-lib numeric_monoid.pyx`

And the each doctest series should start with::

    sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from numeric_monoid import *

The following bound are fixed at compile time::

    sage: SIZE
    256
    sage: MAX_GENUS
    86

.. warning::

    Due to modular arithmetic the 255-th decomposition number of the full
    monoid is considered as 0 instead of 256.
"""
import cython
from sage.rings.integer cimport Integer
from sage.rings.integer import GCD_list
from sage.structure.sage_object cimport SageObject

include 'sage/ext/interrupt.pxi'

from monoid cimport *
from treewalk cimport *

SIZE = cSIZE
MAX_GENUS = cMAX_GENUS

print_gen = True

cdef class NumericMonoid(SageObject):
    r"""
    sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from numeric_monoid import *
    sage: Full
    < 1 >
    """

    def __init__(self):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from numeric_monoid import *
        sage: NumericMonoid()
        < 1 >
        """
        init_full_N(self._m)

    cpdef int genus(self):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from numeric_monoid import *
        sage: Full.genus()
        0
        sage: NumericMonoid.from_generators([3,5]).genus()
        4
        """
        return self._m.genus

    cpdef int min(self):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from numeric_monoid import *
        sage: Full.min()
        1
        sage: NumericMonoid.from_generators([3,5]).min()
        3
        """
        return self._m.min

    cpdef int conductor(self):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from numeric_monoid import *
        sage: Full.conductor()
        1
        sage: NumericMonoid.from_generators([3,5]).conductor()
        8
        """
        return self._m.conductor

    cpdef _print(self):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from numeric_monoid import *
        sage: Full._print()
        min = 1, cond = 1, genus = 0, decs = 1 1 2 2 3 3 4 4 ...  128 128
        sage: NumericMonoid.from_generators([3,5])._print()
        min = 3, cond = 8, genus = 4, decs = 1 0 0 1 0 1 2 0 2 2 2 3 3 3 4 4 5 5 ... 124 124
        """
        print_monoid(self._m)

    def __contains__(self, unsigned int i):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from numeric_monoid import *
        sage: m = NumericMonoid.from_generators([3,5])
        sage: [i in m for i in range(10)]
        [True, False, False, True, False, True, True, False, True, True]
        sage: 1000 in m
        True
        """
        if i > self._m.conductor:
            return True
        return self._m.decs[i] != 0

    cpdef list elements(self):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from numeric_monoid import *
        sage: Full.elements()
        [0, 1]
        sage: NumericMonoid.from_generators([3,5]).elements()
        [0, 3, 5, 6, 8]
        """
        cdef list res = []
        cdef ind_t i
        for i in range(self._m.conductor+1):
            if self._m.decs[i] > 0:
                res.append(int(i))
        return res

    cpdef list gaps(self):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from numeric_monoid import *
        sage: Full.gaps()
        []
        sage: NumericMonoid.from_generators([3,5]).gaps()
        [1, 2, 4, 7]
        sage: all(len(m.gaps())==m.genus() for i in range(6) for m in Full.nth_generation(i))
        True
        """
        cdef list res = []
        cdef ind_t i
        for i in range(self._m.conductor):
            if self._m.decs[i] == 0:
                res.append(int(i))
        return res

    def __repr__(self):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from numeric_monoid import *
        sage: Full                            # indirect doctest
        < 1 >
        sage: NumericMonoid.from_generators([3,5])   # indirect doctest
        < 3 5 >
        """
        cdef str res
        cdef ind_t i
        if print_gen:
            return "< "+" ".join(str(i) for i in self.generators())+" >"
        else:
            res = "Mon("
            for i in range(self._m.conductor+2):
                if self._m.decs[i] > 0:
                   res += "%i "%i
            return res+"...)"

    def _latex_(self):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from numeric_monoid import *
        sage: Full._latex_()
        '\\langle\\,1\\,\\rangle'
        sage: NumericMonoid.from_generators([3,5])._latex_()
        '\\langle\\,3\\,5\\,\\rangle'
        """
        cdef int i
        if print_gen:
            return "\\langle\\,"+"\\,".join(str(i) for i in self.generators())+"\\,\\rangle"

    def __reduce__(self):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from numeric_monoid import *
        sage: Full.__reduce__()
        (<built-in function _from_pickle>, (<type 'numeric_monoid.NumericMonoid'>, 256, 1L, 1L, 0L, (1, 1, 2, 2, 3, 3, 4, 4, ..., 128)))
        sage: NumericMonoid.from_generators([3,5]).__reduce__()
        (<built-in function _from_pickle>, (<type 'numeric_monoid.NumericMonoid'>, 256, 8L, 3L, 4L, (1, 0, 0, 1, 0, 1, 2, 0, 2, 2, ..., 124, 124)))
        """
        return (_from_pickle,
                (type(self), cSIZE,
                 self._m.conductor, self._m.min, self._m.genus,
                 tuple(self._decomposition_numbers())))


    # < 0    <= 1    == 2    != 3    > 4    >= 5
    def __richcmp__(NumericMonoid self, NumericMonoid other, int op):
        """
        Inclusion Order

        EXAMPLE::

            sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from numeric_monoid import *
            sage: m1 = NumericMonoid.from_generators([3,5,7])
            sage: Full == Full, Full != Full, Full == m1, Full != m1
            (True, False, False, True)
            sage: m1 == m1, m1 != m1, m1 < m1, m1 <= m1, m1 > m1, m1 >= m1
            (True, False, False, True, False, True)
            sage: Full < m1, m1 > Full, Full > m1, m1 < Full
            (False, False, True, True)
        """
        cdef bint eq, incl
        eq = (self._m.conductor ==  other._m.conductor and
              self._m.min ==  other._m.min and
              self.genus ==  other.genus and
              all(self._m.decs[i] == other._m.decs[i] for i in range(cSIZE)))
        if   op == 2: return eq
        elif op == 3: return not eq
        elif op < 2:
            incl = all(i in other for i in self.generators())
            if   op == 0: return incl and not eq
            elif op == 1: return incl
        else:
            incl = all(i in self for i in other.generators())
            if   op == 4: return incl and not eq
            elif op == 5: return incl

    def __hash__(self):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from numeric_monoid import *
        sage: Full.__hash__()
        7122582034698508706
        sage: hash(NumericMonoid.from_generators([3,5,7]))
        7609276871119479011
        sage: len(set(Full.nth_generation(4)))
        7
        """
        return hash((self.conductor(), self.min(), self.genus(),
                     tuple(self._decomposition_numbers())))


    cpdef NumericMonoid remove_generator(self, unsigned int gen):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from numeric_monoid import *
        sage: Full.remove_generator(1)
        < 2 3 >
        sage: NumericMonoid.from_generators([3,5,7]).remove_generator(7)
        < 3 5 >
        sage: NumericMonoid.from_generators([3,5,7]).remove_generator(8)
        Traceback (most recent call last):
        ...
        ValueError: 8 is not a generator for < 3 5 7 >
        """
        cdef NumericMonoid res
        res = NumericMonoid.__new__(type(self))
        if gen > cSIZE or self._m.decs[gen] != 1:
            raise ValueError, "%i is not a generator for %s"%(gen, self)
        remove_generator(res._m, self._m, gen)
        return res

    cpdef list generators(self):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from numeric_monoid import *
        sage: Full.generators()
        [1]
        sage: NumericMonoid.from_generators([3,5,7]).generators()
        [3, 5, 7]
        """
        cdef list res = []
        cdef int gen
        cdef generator_iter *iter = new generator_iter(self._m, ALL)
        while iter.move_next():
            res.append(int(iter.get_gen()))
        del iter
        return res

    cpdef int count_children(self):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from numeric_monoid import *
        sage: Full.count_children()
        1
        sage: NumericMonoid.from_generators([3,5,7]).count_children()
        2
        """
        cdef int res
        cdef generator_iter *iter = new generator_iter(self._m, CHILDREN)
        res = iter.count()
        del iter
        return res

    cpdef list children(self):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from numeric_monoid import *
        sage: Full.children()
        [< 2 3 >]
        sage: NumericMonoid.from_generators([3,5,7]).children()
        [< 3 7 8 >, < 3 5 >]
        """
        cdef list res = []
        cdef generator_iter *iter = new generator_iter(self._m, CHILDREN)
        while iter.move_next():
            res.append(self.remove_generator(iter.get_gen()))
        del iter
        return res

    cpdef list children_generators(self):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from numeric_monoid import *
        sage: Full.children_generators()
        [1]
        sage: NumericMonoid.from_generators([3,5,7]).children_generators()
        [5, 7]
        """
        cdef list res = []
        cdef int gen
        cdef generator_iter *iter = new generator_iter(self._m, CHILDREN)
        while iter.move_next():
            res.append(int(iter.get_gen()))
        del iter
        return res

    cpdef list successors(self):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from numeric_monoid import *
        sage: Full.successors()
        [< 2 3 >]
        sage: NumericMonoid.from_generators([3,5,7]).successors()
        [< 5 6 7 8 9 >, < 3 7 8 >, < 3 5 >]
        """
        cdef list res = []
        cdef generator_iter *iter = new generator_iter(self._m, ALL)
        while iter.move_next():
            # Straigten a monoid obtained by removing an non children generators
            try:
                newmon = self.from_generators(self.remove_generator(iter.get_gen()).generators())
            except ValueError:
                pass # Ignore the result if GCD is not 1 anymore.
            else:
                res.append(newmon)
        del iter
        return res

    cpdef list successor_generators(self):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from numeric_monoid import *
        sage: Full.successor_generators()
        [1]
        sage: NumericMonoid.from_generators([3,5,7]).successor_generators()
        [3, 5, 7]
        """
        cdef list res = []
        cdef int gen
        cdef generator_iter *iter = new generator_iter(self._m, ALL)
        while iter.move_next():
            res.append(int(iter.get_gen()))
        del iter
        return res

    cpdef list nth_generation(self, unsigned int genus):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from numeric_monoid import *
        sage: Full.nth_generation(3)
        [< 4 5 6 7 >, < 3 5 7 >, < 3 4 >, < 2 7 >]
        sage: NumericMonoid.from_generators([3,5,7]).nth_generation(8)
        [< 3 13 14 >, < 3 11 16 >, < 3 10 17 >]
        """
        cdef ind_t i
        cdef list lst = [self]
        for i in range(self._m.genus, genus):
            lst = [x for m in lst for x in m.children()]
        return lst


    cpdef MonoidList nth_generation_cilk(self, unsigned int genus):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from numeric_monoid import *
        sage: list(Full.nth_generation_cilk(0))
        [< 1 >]
        sage: list(Full.nth_generation_cilk(1))
        [< 2 3 >]
        sage: list(Full.nth_generation_cilk(2))
        [< 3 4 5 >, < 2 5 >]
        sage: list(Full.nth_generation_cilk(4))
        [< 5 6 7 8 9 >, < 4 6 7 9 >, < 4 5 7 >, < 4 5 6 >, < 3 7 8 >, < 3 5 >, < 2 9 >]
        """
        cdef MonoidList res = MonoidList.__new__(MonoidList)
        cilk_list_results.get_reference().clear()
        sig_on()
        with nogil:
            list_children(self._m, genus)
        sig_off()
        res._l = cilk_list_results.get_value()
        return res

    # don't know how to make it readonly !
    cpdef unsigned char[:] _decomposition_numbers(self):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from numeric_monoid import *
        sage: Full._decomposition_numbers()
        <MemoryView of 'array' at 0x...>
        sage: len(list(Full._decomposition_numbers())) == 256
        True
        sage: len(list(NumericMonoid.from_generators([3,5,7])._decomposition_numbers())) == 256
        True
        """
        cdef unsigned char[:] slice = (<unsigned char[:cSIZE]>
                                        <unsigned char *> self._m.decs)
        return slice

    cpdef list multiplicities(self):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from numeric_monoid import *
        sage: Full.multiplicities() == range(1, 257)
        True
        sage: NumericMonoid.from_generators([3,5,7]).multiplicities()
        [1, 0, 0, 2, 0, 2, 3, 2, 4, 4, 5, 6, 7, 8, 9, 10, 11, ..., 249, 250]

        """
        cdef unsigned char[:] decs = self._decomposition_numbers()
        cdef int i
        cdef int mults[cSIZE]
        cdef int[:] mults_view = mults
        mults[0] = 1
        for i in range(1, cSIZE):
            mults[i] = decs[i] << 1
            if i % 2 == 0 and mults[i/2] != 0:
                mults[i] -= 1
        return list(mults_view)

    @classmethod
    def from_generators(cls, list l):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from numeric_monoid import *
        sage: NumericMonoid.from_generators([1])
        < 1 >
        sage: NumericMonoid.from_generators([3,5,7])
        < 3 5 7 >
        sage: NumericMonoid.from_generators([3,5,8])
        < 3 5 >
        sage: NumericMonoid.from_generators([3,6])
        Traceback (most recent call last):
        ...
        ValueError: gcd of generators must be 1
        """
        cdef int i
        cdef set gens = {int(i) for i in l}
        cdef NumericMonoid res = cls()
        cdef generator_iter *iter = new generator_iter(res._m, CHILDREN)
        if GCD_list(l) != 1:
            raise ValueError, "gcd of generators must be 1"
        while iter.move_next():
            gen = iter.get_gen()
            if gen not in gens:
                res = res.remove_generator(gen)
                del iter
                iter = new generator_iter(res._m, CHILDREN)
        del iter
        return res

    def gcd_small_generator(self):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from numeric_monoid import *
        sage: Full.gcd_small_generator()
        0
        sage: NumericMonoid.from_generators([3,5,7]).gcd_small_generator()
        3
        """
        if self._m.min == 1:     # self == Full
            return Integer(0)
        return GCD_list([i for i in self.generators() if i < self.conductor()])

    def has_finite_descendance(self):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from numeric_monoid import *
        sage: Full.has_finite_descendance()
        False
        sage: NumericMonoid.from_generators([3,5,7]).has_finite_descendance()
        False
        sage: NumericMonoid.from_generators([3,7]).has_finite_descendance()
        True
        """
        return self.gcd_small_generator() == 1

    def support_generating_series(self):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from numeric_monoid import *
        sage: Full.support_generating_series()
        -1/(x - 1)
        sage: NumericMonoid.from_generators([3,5,7]).support_generating_series()
        -(x^5 - x^4 + x^3 - x + 1)/(x - 1)
        sage: NumericMonoid.from_generators([3,7]).support_generating_series()
        -(x^12 - x^11 + x^9 - x^8 + x^6 - x^4 + x^3 - x + 1)/(x - 1)
        """
        from sage.calculus.var import var
        x = var('x')
        cdef int c = self.conductor()
        return (sum(x**i for i in range(c) if i in self) +
                x**c/(1-x)).normalize()

    def multiplicities_generating_series(self):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from numeric_monoid import *
        sage: Full.multiplicities_generating_series()
        (x - 1)^(-2)
        sage: NumericMonoid.from_generators([3,5,7]).multiplicities_generating_series()
        (x^5 - x^4 + x^3 - x + 1)^2/(x - 1)^2
        sage: NumericMonoid.from_generators([3,7]).multiplicities_generating_series()
        (x^12 - x^11 + x^9 - x^8 + x^6 - x^4 + x^3 - x + 1)^2/(x - 1)^2

        sage: bound = 20
        sage: all( [(m.support_generating_series()^2).taylor(x, 0, bound-1).coefficient(x, i)
        ...         for i in range(bound)] ==
        ...        list(m.multiplicities())[:bound]
        ...       for k in range(7) for m in Full.nth_generation(k))
        True
        """
        return (self.support_generating_series()**2).normalize()

    def generating_series(self):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from numeric_monoid import *
        sage: Full.generating_series()
        (x - 1)/(x*y + x - 1)
        sage: NumericMonoid.from_generators([3,5,7]).generating_series()
        (x - 1)/(x^5*y - x^4*y + x^3*y + x - 1)
        sage: NumericMonoid.from_generators([3,7]).generating_series()
        (x - 1)/(x^12*y - x^11*y + x^9*y - x^8*y + x^6*y - x^4*y + x^3*y + x - 1)
        """
        from sage.calculus.var import var
        return 1/(1-var('y')*(self.support_generating_series()-1)).normalize()

    def _test_monoid(self, **options):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from numeric_monoid import *
        sage: m = NumericMonoid.from_generators([3,5,7])
        sage: m._test_monoid()
        sage: m._decomposition_numbers()[2] = 1    # don't do this at home, kids
        sage: m._test_monoid()
        Traceback (most recent call last):
        ...
        AssertionError: wrong min
        sage: m = NumericMonoid.from_generators([3,5,7])
        sage: m._decomposition_numbers()[20] = 0    # don't do this at home, kids
        sage: m._test_monoid()
        Traceback (most recent call last):
        ...
        AssertionError: wrong genus
        """
        cdef ind_t i, genus = 0, size = cSIZE
        tester = self._tester(**options)
        if self._m.conductor == 1:
            tester.assertEqual(self._m.min, 1, "wrong min")
        tester.assertTrue(all(self._m.decs[i] == 0 for i in range(1, self._m.min)),
                          "wrong min")
        for i in range(size):
            if self._m.decs[i] == 0:
                genus += 1
        tester.assertEqual(self._m.genus, genus, "wrong genus")
        tester.assertEqual(self._m.decs[0], 1, "wrong decs[0]")
        if self._m.conductor != 1:
            tester.assertEqual(self._m.decs[self._m.conductor-1], 0,
                               "conductor in not minimal")
        tester.assertTrue(all(self._m.decs[i] != 0
                              for i in range(self._m.conductor, <unsigned int>cSIZE)),
                          "wrong conductor")

    def _test_generators(self, **options):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from numeric_monoid import *
        sage: Full._test_generators()
        sage: m = NumericMonoid.from_generators([3,5,7])
        sage: m._test_generators()
        sage: m._decomposition_numbers()[2] = 2    # don't do this at home, kids
        sage: m._test_generators()
        Traceback (most recent call last):
        ...
        AssertionError: wrong generators
        """
        tester = self._tester(**options)
        tester.assertEqual(self, NumericMonoid.from_generators(self.generators()),
                           "wrong generators")


    cpdef list walk_children_stack(NumericMonoid self, int bound):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from numeric_monoid import *
        sage: Full.walk_children_stack(5)
        [1, 2, 4, 7, 12]
        """
        cdef results_type res
        cdef int i
        for i in range(bound):
            res[i] = 0
        sig_on()
        walk_children_stack(self._m, bound, res)
        sig_off()
        return [int(res[i]) for i in range(bound)]

    cpdef list walk_children(NumericMonoid self, int bound):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from numeric_monoid import *
        sage: Full.walk_children(15)
        [1, 2, 4, 7, 12, 23, 39, 67, 118, 204, 343, 592, 1001, 1693, 2857]
        """
        cilk_results.reset()
        sig_on()
        walk_children(self._m, bound)
        sig_off()
        return [int(cilk_results[i]) for i in range(bound)]


cpdef NumericMonoid _from_pickle(type typ, int sz, int cond, int mn, int genus, tuple decs):
    r"""
    sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from numeric_monoid import *
    sage: TestSuite(Full).run(verbose=True)                       # indirect doctest
    running ._test_category() . . . pass
    running ._test_generators() . . . pass
    running ._test_monoid() . . . pass
    running ._test_not_implemented_methods() . . . pass
    running ._test_pickling() . . . pass
    sage: TestSuite(Full.remove_generator(1)).run()               # indirect doctest
    sage: TestSuite(NumericMonoid.from_generators([3,5,7])).run() # indirect doctest
    """
    cdef NumericMonoid res
    cdef int i

    if sz != cSIZE:
        raise ValueError, "mon is compiled with different size (pickle size=%i)"%sz
    res = NumericMonoid.__new__(typ)
    res._m.conductor = cond
    res._m.min = mn
    res._m.genus = genus
    for i in range(cSIZE):
        res._m.decs[i] = decs[i]
    return res


Full = NumericMonoid()


cdef class MonoidList(object):
    r"""
    A wrapper for C++ STL lists of monoids.
    """

    def __init__(self):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from numeric_monoid import *
        sage: MonoidList()
        Traceback (most recent call last):
        ...
        RuntimeError: You are not supposed to call init
        """
        raise RuntimeError, "You are not supposed to call init"

    def __len__(self):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from numeric_monoid import *
        sage: len(Full.nth_generation_cilk(4))
        7
        """
        return self._l.size()

    def __iter__(self):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from numeric_monoid import *
        sage: iter(Full.nth_generation_cilk(4))
        <numeric_monoid.MonoidListIterator object at 0x...>
        """
        return MonoidListIterator(self)

cdef class MonoidListIterator(object):
    r"""
    A wrapper for C++ STL iterator for list of monoids.
    """
    def __cinit__(self, MonoidList l):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from numeric_monoid import *
        sage: MonoidListIterator(Full.nth_generation_cilk(0))
        <numeric_monoid.MonoidListIterator object at 0x...>
        """
        self._ml = l  # keep a reference on _ml to prevent _ml._l from being deallocated
        self._it = self._ml._l.begin()
        self._end = self._ml._l.end()

    def __next__(self):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from numeric_monoid import *
        sage: it = iter(Full.nth_generation_cilk(2))
        sage: it.__next__()
        < 3 4 5 >
        sage: it.__next__()
        < 2 5 >
        sage: it.__next__()
        Traceback (most recent call last):
        ...
        StopIteration

        sage: it = iter(Full.nth_generation_cilk(10))
        sage: it.__next__()
        < 11 12 13 14 15 16 17 18 19 20 21 >
        sage: it.__next__()
        < 10 12 13 14 15 16 17 18 19 21 >
        """
        cdef NumericMonoid res = NumericMonoid.__new__(NumericMonoid)
        if self._it != self._end:
            res._m = cython.operator.dereference(self._it)
            cython.operator.preincrement(self._it)
            return res
        else:
            raise StopIteration

    def __iter__(self):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from numeric_monoid import *
        sage: it = iter(Full.nth_generation_cilk(0))
        sage: iter(it) is it
        True
        """
        return self

