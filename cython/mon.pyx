print_gen = True

cdef class Monoid(object):
    """
    sage: import mon
    sage: mon.Full
    """
    def __init__(self):
        cmonoid.init_full_N(&self._m)

    cpdef int genus(self):
        return self._m.genus
    cpdef int min(self):
        return self._m.min
    cpdef int conductor(self):
        return self._m.conductor
    cpdef prnt(self):
        cmonoid.print_monoid(&self._m)

    def __contains__(self, unsigned int i):
        if i > cmonoid.SIZE:
            raise ValueError, "%i is too large for %s"%(i, self)
        return bool(self._m.decs[i])

    cpdef list elements(self):
        cdef list res = []
        cdef int i
        for i in range(self._m.conductor+1):
            if self._m.decs[i] > 0:
                res.append(i)
        return res

    def __repr__(self):
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
        cdef Monoid res
        res = Monoid.__new__(self.__class__)
        if gen > cmonoid.SIZE or self._m.decs[gen] != 2:
            raise ValueError, "%i is not a generator for %s"%(gen, self)
        cmonoid.remove_generator(&self._m, &res._m, gen)
        return res

    cpdef list generators(self):
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
        cdef int res
        cdef cmonoid.generator_iter iter
        with nogil:
            cmonoid.init_children_generator_iter(&self._m, &iter)
            res = cmonoid.count_generator_iter(&self._m, &iter)
        return res

    cpdef list children(self):
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
        cdef list res = []
        cdef int gen
        cdef cmonoid.generator_iter iter
        cmonoid.init_children_generator_iter(&self._m, &iter)
        gen = cmonoid.next_generator_iter(&self._m, &iter)
        while gen != 0:
            res.append(gen)
            gen = cmonoid.next_generator_iter(&self._m, &iter)
        return res

    cpdef list nth_generation(self, unsigned int n):
        cdef int i
        cdef list lst = [self]
        for i in range(self._m.genus, n):
            lst = [x for m in lst for x in m.children()]
        return lst

    # don't know how to make it readonly !
#    def decomposition_numbers(self):
#        cdef unsigned char[:] slice = (<unsigned char[:cmonoid.SIZE]>
#                                        <unsigned char *> self._m.decs)
#        return slice

    @classmethod
    def from_generators(cls, list l):
        cdef int i
        cdef set gens = {int(i) for i in l}
        cdef Monoid res = cls()
        cdef cmonoid.generator_iter iter
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
