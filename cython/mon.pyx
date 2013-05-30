r"""
Recompile with::

    sage -python setup.py build_ext --inplace

Due to compilation outside Sage, the option `--force_lib` has ot be given for
doctests to prevent Sage for recompiling this file. The doctest command is::

    sage -t --force-lib mon.pyx`

And the each doctest series should start with::

    sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from mon import *

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

cdef class Monoid(SageObject):
    r"""
    sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from mon import *
    sage: Full
    < 1 >
    """

    def __init__(self):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from mon import *
        sage: Monoid()
        < 1 >
        """
        cmonoid.init_full_N(&self._m)

    cpdef int genus(self):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from mon import *
        sage: Full.genus()
        0
        sage: Monoid.from_generators([3,5]).genus()
        4
        """
        return self._m.genus

    cpdef int min(self):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from mon import *
        sage: Full.min()
        1
        sage: Monoid.from_generators([3,5]).min()
        3
        """
        return self._m.min

    cpdef int conductor(self):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from mon import *
        sage: Full.conductor()
        1
        sage: Monoid.from_generators([3,5]).conductor()
        8
        """
        return self._m.conductor

    cpdef _print(self):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from mon import *
        sage: Full._print()
        min = 1, cond = 1, genus = 0, decs = 1 2 3 4 ...  128
        sage: Monoid.from_generators([3,5])._print()
        min = 3, cond = 8, genus = 4, decs = 1 0 0 2 0 2 3 0 4 4 3 6 5 6 8 8 9 10 ... 120
        """
        cmonoid.print_monoid(&self._m)

    def __contains__(self, unsigned int i):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from mon import *
        sage: m = Monoid.from_generators([3,5])
        sage: [i in m for i in range(10)]
        [True, False, False, True, False, True, True, False, True, True]
        sage: 1000 in m
        True
        """
        if i > self._m.conductor:
            return True
        return bool(self._m.decs[i])

    cpdef list elements(self):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from mon import *
        sage: Full.elements()
        [0, 1]
        sage: Monoid.from_generators([3,5]).elements()
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
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from mon import *
        sage: Full                            # indirect doctest
        < 1 >
        sage: Monoid.from_generators([3,5])   # indirect doctest
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

    def __reduce__(self):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from mon import *
        sage: Full.__reduce__()
        (<built-in function _from_pickle>, (<type 'mon.Monoid'>, 128, 1L, 1L, 0L, (1, 2, ..., 128)))
        sage: Monoid.from_generators([3,5]).__reduce__()
        (<built-in function _from_pickle>, (<type 'mon.Monoid'>, 128, 8L, 3L, 4L, (1, 0, 0, 2, 0, 2, 3, 0, 4, 4, 3, 6, 5, 6, 8, 8, 9, 10, ..., 120)))
        """
        return (_from_pickle,
                (type(self), cmonoid.SIZE,
                 self._m.conductor, self._m.min, self._m.genus,
                 tuple(self._decomposition_numbers())))


    cpdef Monoid remove_generator(self, unsigned int gen):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from mon import *
        sage: Full.remove_generator(1)
        < 2 3 >
        sage: Monoid.from_generators([3,5,7]).remove_generator(7)
        < 3 5 >
        sage: Monoid.from_generators([3,5,7]).remove_generator(8)
        Traceback (most recent call last):
        ...
        ValueError: 8 is not a generator for < 3 5 7 >
        """
        cdef Monoid res
        res = Monoid.__new__(self.__class__)
        if gen > cmonoid.SIZE or self._m.decs[gen] != 2:
            raise ValueError, "%i is not a generator for %s"%(gen, self)
        cmonoid.remove_generator(&self._m, &res._m, gen)
        return res

    cpdef list generators(self):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from mon import *
        sage: Full.generators()
        [1]
        sage: Monoid.from_generators([3,5,7]).generators()
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
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from mon import *
        sage: Full.count_children()
        1
        sage: Monoid.from_generators([3,5,7]).count_children()
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
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from mon import *
        sage: Full.children()
        [< 2 3 >]
        sage: Monoid.from_generators([3,5,7]).children()
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
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from mon import *
        sage: Full.children_generators()
        [1]
        sage: Monoid.from_generators([3,5,7]).children_generators()
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
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from mon import *
        sage: Full.nth_generation(3)
        [< 4 5 6 7 >, < 3 5 7 >, < 3 4 >, < 2 7 >]
        sage: Monoid.from_generators([3,5,7]).nth_generation(8)
        [< 3 13 14 >, < 3 11 16 >, < 3 10 17 >]
        """
        cdef int i
        cdef list lst = [self]
        for i in range(self._m.genus, genus):
            lst = [x for m in lst for x in m.children()]
        return lst

    # don't know how to make it readonly !
    cpdef _decomposition_numbers(self):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from mon import *
        sage: Full._decomposition_numbers()
        <MemoryView of 'array' at 0x...>
        sage: list(Full._decomposition_numbers()) == range(1, 129)
        True
        sage: lst = list(Monoid.from_generators([3,5,7])._decomposition_numbers())
        sage: lst == [1, 0, 0, 2, 0, 2, 3, 2, 4] + range(4, 123)
        True
        """
        cdef unsigned char[:] slice = (<unsigned char[:cmonoid.SIZE]>
                                        <unsigned char *> self._m.decs)
        return slice

    @classmethod
    def from_generators(cls, list l):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from mon import *
        sage: Monoid.from_generators([1])
        < 1 >
        sage: Monoid.from_generators([3,5,7])
        < 3 5 7 >
        sage: Monoid.from_generators([3,5,8])
        < 3 5 >
        sage: Monoid.from_generators([3,6])
        Traceback (most recent call last):
        ...
        ValueError: gcd of generators must be 1
        """
        cdef int i
        cdef set gens = {int(i) for i in l}
        cdef Monoid res = cls()
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
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from mon import *
        sage: Full.gcd_small_generator()
        0
        sage: Monoid.from_generators([3,5,7]).gcd_small_generator()
        3
        """
        return gcd([i for i in self.generators() if i < self.conductor()])

    def has_finite_descendance(self):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from mon import *
        sage: Full.has_finite_descendance()
        False
        sage: Monoid.from_generators([3,5,7]).has_finite_descendance()
        False
        sage: Monoid.from_generators([3,7]).has_finite_descendance()
        True
        """
        return self.gcd_small_generator() == 1

    # < 0    <= 1    == 2    != 3    > 4    >= 5
    def __richcmp__(Monoid self, Monoid other, int op):
        """
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from mon import *
        sage: m1 = Monoid.from_generators([3,5,7])
        sage: Full == m1
        False
        sage: Full != m1
        True
        sage: Full == m1
        False
        sage: m1 == m1
        True
        sage: m1 != m1
        False
        sage: m1 < m1
        Traceback (most recent call last):
        ...
        NotImplementedError
        """
        cdef int i
        cdef bint res = (self._m.conductor ==  other._m.conductor and
               self._m.min ==  other._m.min and
               self._m.genus ==  other._m.genus and
               all(self._m.decs[i] == other._m.decs[i] for i in range(cmonoid.SIZE)))
        if op == 2:
            return res
        elif op == 3:
            return not res
        else:
            raise NotImplementedError

    def _test_monoid(self, **options):
        r"""
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from mon import *
        sage: m = Monoid.from_generators([3,5,7])
        sage: m._test_monoid()
        sage: m._decomposition_numbers()[2] = 1    # don't do this at home, kids
        sage: m._test_monoid()
        Traceback (most recent call last):
        ...
        AssertionError: wrong min
        sage: m = Monoid.from_generators([3,5,7])
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
        tester.assertEqual(self, Monoid.from_generators(self.generators()))


def _from_pickle(typ, sz, cond, mn, genus, decs):
    r"""
    sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from mon import *
    sage: TestSuite(Full).run()                            # indirect doctest
    sage: TestSuite(Full.remove_generator(1)).run()        # indirect doctest
    sage: TestSuite(Monoid.from_generators([3,5,7])).run() # indirect doctest
    """
    cdef Monoid res
    cdef int i

    if sz != cmonoid.SIZE:
        raise ValueError, "mon is compiled with different size (pickle size=%i)"%sz
    res = Monoid.__new__(typ)
    res._m.conductor = cond
    res._m.min = mn
    res._m.genus = genus
    for i in range(cmonoid.SIZE):
        res._m.decs[i] = decs[i]
    return res


Full = Monoid()

