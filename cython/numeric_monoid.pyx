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
    128
    sage: MAX_GENUS
    40
"""
from sage.rings.arith import gcd
from sage.structure.sage_object cimport SageObject

SIZE = cmonoid.SIZE
MAX_GENUS = cmonoid.MAX_GENUS

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
        cmonoid.init_full_N(&self._m)

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
        min = 1, cond = 1, genus = 0, decs = 1 2 3 4 ...  128
        sage: NumericMonoid.from_generators([3,5])._print()
        min = 3, cond = 8, genus = 4, decs = 1 0 0 2 0 2 3 0 4 4 3 6 5 6 8 8 9 10 ... 120
        """
        cmonoid.print_monoid(&self._m)

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
        cdef int i
        for i in range(self._m.conductor+1):
            if self._m.decs[i] > 0:
                res.append(i)
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
        cdef int i
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
        (<built-in function _from_pickle>, (<type 'numeric_monoid.NumericMonoid'>, 128, 1L, 1L, 0L, (1, 2, 3, 4, ..., 128)))
        sage: NumericMonoid.from_generators([3,5]).__reduce__()
        (<built-in function _from_pickle>, (<type 'numeric_monoid.NumericMonoid'>, 128, 8L, 3L, 4L, (1, 0, 0, 2, 0, 2, 3, 0, 4, 4, 3, 6, 5, 6, 8, 8, 9, 10, 11, ..., 120)))
        """
        return (_from_pickle,
                (type(self), cmonoid.SIZE,
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
              all(self._m.decs[i] == other._m.decs[i] for i in range(cmonoid.SIZE)))
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
        4104806067970577762
        sage: hash(NumericMonoid.from_generators([3,5,7]))
        4956859272429548688
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
        if gen > cmonoid.SIZE or self._m.decs[gen] != 2:
            raise ValueError, "%i is not a generator for %s"%(gen, self)
        cmonoid.remove_generator(&self._m, &res._m, gen)
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
        cdef cmonoid.generator_iter iter
        cmonoid.init_all_generator_iter(&self._m, &iter)
        gen = cmonoid.next_generator_iter(&self._m, &iter)
        while gen != 0:
            res.append(gen)
            gen = cmonoid.next_generator_iter(&self._m, &iter)
        return res

    cpdef int count_children(self):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from numeric_monoid import *
        sage: Full.count_children()
        1
        sage: NumericMonoid.from_generators([3,5,7]).count_children()
        2
        """
        cdef int res = 0
        cdef cmonoid.generator_iter iter
        with nogil:
            cmonoid.init_children_generator_iter(&self._m, &iter)
            res += cmonoid.count_generator_iter(&self._m, &iter)
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
        cdef int gen
        cdef cmonoid.generator_iter iter
        cmonoid.init_children_generator_iter(&self._m, &iter)
        gen = cmonoid.next_generator_iter(&self._m, &iter)
        while gen != 0:
            res.append(self.remove_generator(gen))
            gen = cmonoid.next_generator_iter(&self._m, &iter)
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
        cdef cmonoid.generator_iter iter
        cmonoid.init_children_generator_iter(&self._m, &iter)
        gen = cmonoid.next_generator_iter(&self._m, &iter)
        while gen != 0:
            res.append(gen)
            gen = cmonoid.next_generator_iter(&self._m, &iter)
        return res

    cpdef list nth_generation(self, unsigned int genus):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from numeric_monoid import *
        sage: Full.nth_generation(3)
        [< 4 5 6 7 >, < 3 5 7 >, < 3 4 >, < 2 7 >]
        sage: NumericMonoid.from_generators([3,5,7]).nth_generation(8)
        [< 3 13 14 >, < 3 11 16 >, < 3 10 17 >]
        """
        cdef int i
        cdef list lst = [self]
        for i in range(self._m.genus, genus):
            lst = [x for m in lst for x in m.children()]
        return lst

    # don't know how to make it readonly !
    cpdef unsigned char[:] _decomposition_numbers(self):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from numeric_monoid import *
        sage: Full._decomposition_numbers()
        <MemoryView of 'array' at 0x...>
        sage: list(Full._decomposition_numbers()) == range(1, 129)
        True
        sage: lst = list(NumericMonoid.from_generators([3,5,7])._decomposition_numbers())
        sage: lst == [1, 0, 0, 2, 0, 2, 3, 2, 4] + range(4, 123)
        True
        """
        cdef unsigned char[:] slice = (<unsigned char[:cmonoid.SIZE]>
                                        <unsigned char *> self._m.decs)
        return slice

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
        cdef cmonoid.generator_iter iter
        if gcd(l) != 1:
            raise ValueError, "gcd of generators must be 1"
        cmonoid.init_children_generator_iter(&res._m, &iter)
        gen = cmonoid.next_generator_iter(&res._m, &iter)
        while gen != 0:
            if gen not in gens:
                res = res.remove_generator(gen)
                cmonoid.init_children_generator_iter(&res._m, &iter)
            gen = cmonoid.next_generator_iter(&res._m, &iter)
        return res

    def gcd_small_generator(self):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from numeric_monoid import *
        sage: Full.gcd_small_generator()
        0
        sage: NumericMonoid.from_generators([3,5,7]).gcd_small_generator()
        3
        """
        return gcd([i for i in self.generators() if i < self.conductor()])

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
        ...        list(m._decomposition_numbers())[:bound]
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
        cdef int i, genus
        tester = self._tester(**options)
        tester.assertTrue(all(self._m.decs[i] == 0 for i in range(1, self._m.min)),
                          "wrong min")
        genus = 0
        for i in range(cmonoid.SIZE):
            if self._m.decs[i] == 0:
                genus += 1
        tester.assertEqual(self._m.genus, genus, "wrong genus")
        tester.assertEqual(self._m.decs[0], 1, "wrong decs[0]")
        if self._m.conductor != 1:
            tester.assertEqual(self._m.decs[self._m.conductor-1], 0,
                               "conductor in not minimal")
        tester.assertTrue(all(self._m.decs[i] != 0
                              for i in range(self._m.conductor, cmonoid.SIZE)),
                          "wrong conductor")
        tester.assertEqual(self, NumericMonoid.from_generators(self.generators()))


cpdef NumericMonoid _from_pickle(type typ, int sz, int cond, int mn, int genus, tuple decs):
    r"""
    sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from numeric_monoid import *
    sage: TestSuite(Full).run()                            # indirect doctest
    sage: TestSuite(Full.remove_generator(1)).run()        # indirect doctest
    sage: TestSuite(NumericMonoid.from_generators([3,5,7])).run() # indirect doctest
    """
    cdef NumericMonoid res
    cdef int i

    if sz != cmonoid.SIZE:
        raise ValueError, "mon is compiled with different size (pickle size=%i)"%sz
    res = NumericMonoid.__new__(typ)
    res._m.conductor = cond
    res._m.min = mn
    res._m.genus = genus
    for i in range(cmonoid.SIZE):
        res._m.decs[i] = decs[i]
    return res

Full = NumericMonoid()


