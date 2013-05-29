"""
Recompile with::

    sage -python setup.py build_ext --inplace

Due to compilation outside Sage, the option `--force_lib` has ot be given for
doctests to prevent Sage for recompiling this file. The doctest command is::

    sage -t --force-lib mon.pyx`

And the each doctest series should start with::

    sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from mon import *

The following bound are fixed at compile time::

    sage: MAX_SIZE
    128
    sage: MAX_GENUS
    40
"""

print_gen = True

cdef class Monoid(object):
    """
    sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from mon import *
    sage: Full
    < 1 >
    """

    def __init__(self):
        """
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from mon import *
        sage: Monoid()
        < 1 >
        """
        cmonoid.init_full_N(&self._m)

    cpdef int genus(self):
        """
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from mon import *
        sage: Full.genus()
        0
        sage: Monoid.from_generators([3,5]).genus()
        4
        """
        return self._m.genus

    cpdef int min(self):
        """
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from mon import *
        sage: Full.min()
        1
        sage: Monoid.from_generators([3,5]).min()
        3
        """
        return self._m.min

    cpdef int conductor(self):
        """
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from mon import *
        sage: Full.conductor()
        1
        sage: Monoid.from_generators([3,5]).conductor()
        8
        """
        return self._m.conductor

    cpdef _print(self):
        """
        sage: import os; os.sys.path.insert(0,os.path.abspath('.')); from mon import *
        sage: Full._print()
        min = 1, cond = 1, genus = 0, decs = 1 2 3 4 ...  128
        sage: Monoid.from_generators([3,5])._print()
        min = 3, cond = 8, genus = 4, decs = 1 0 0 2 0 2 3 0 4 4 3 6 5 6 8 8 9 10 ... 120
        """
        cmonoid.print_monoid(&self._m)

    def __contains__(self, unsigned int i):
        """
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
        """
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
        """
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

    cpdef Monoid remove_generator(self, unsigned int gen):
        """
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
        """
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
        """
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
        """
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
        """
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
        """
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
        """
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
        """
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
        from sage.rings.arith import gcd

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

Full = Monoid()

MAX_SIZE = cmonoid.SIZE
MAX_GENUS = cmonoid.MAX_GENUS
