cimport cmonoid

print_gen = True

cdef class Monoid:
    def __init__(self):
        cmonoid.init_full_N(&self.pmon)

    cpdef int genus(self):
        return self.pmon.genus
    cpdef int min(self):
        return self.pmon.min
    cpdef int conductor(self):
        return self.pmon.conductor
    cpdef prnt(self):
        cmonoid.print_monoid(&self.pmon)

    cpdef Monoid remove_generator(self, unsigned int gen):
        cdef Monoid res
        res = Monoid.__new__(Monoid)
        if gen > cmonoid.SIZE or self.pmon.decs[gen] != 2:
            raise ValueError, "%i is not a generator for %s"%(gen, self)
        cmonoid.remove_generator(&self.pmon, &res.pmon, gen)
        return res

    cpdef int count_children(self):
        cdef cmonoid.monoid_generator_scan scan
        cmonoid.init_children_generator_scan(&self.pmon, &scan)
        return cmonoid.count_generator_scan(&self.pmon, &scan)

    cpdef list children(self):
        cdef list res = []
        cdef int gen
        cdef cmonoid.monoid_generator_scan scan
        cmonoid.init_children_generator_scan(&self.pmon, &scan)
        gen = cmonoid.next_generator_scan(&self.pmon, &scan)
        while gen != 0:
            res.append(self.remove_generator(gen))
            gen = cmonoid.next_generator_scan(&self.pmon, &scan)
        return res

    cpdef list elements(self):
        cdef list res = []
        cdef int i
        for i in range(self.pmon.conductor+1):
            if self.pmon.decs[i] > 0:
                res.append(i)
        return res

    cpdef list generation(self, n):
        cdef int i
        cdef list lst = [self]
        for i in range(self.pmon.genus, n):
            lst = [x for m in lst for x in m.children()]
        return lst

    def __repr__(self):
        cdef str res
        cdef int i
        if print_gen:
            return "< "+" ".join(str(i) for i in self.generators())+" >"
        else:
            res = "Mon("
            for i in range(self.pmon.conductor+2):
                if self.pmon.decs[i] > 0:
                   res += "%i "%i
            return res+"...)"

    cpdef list generators(self):
        cdef list res = []
        cdef int gen
        cdef cmonoid.monoid_generator_scan scan
        cmonoid.init_all_generator_scan(&self.pmon, &scan)
        gen = cmonoid.next_generator_scan(&self.pmon, &scan)
        while gen != 0:
            res.append(gen)
            gen = cmonoid.next_generator_scan(&self.pmon, &scan)
        return res

    @classmethod
    def from_generators(cls, list l):
        cdef int i
        cdef set gens = {int(i) for i in l}
        cdef Monoid res = cls()
        cdef cmonoid.monoid_generator_scan scan
        cmonoid.init_children_generator_scan(&res.pmon, &scan)
        gen = cmonoid.next_generator_scan(&res.pmon, &scan)
        while gen != 0:
            if gen not in gens:
                res = res.remove_generator(gen)
                cmonoid.init_children_generator_scan(&res.pmon, &scan)
            gen = cmonoid.next_generator_scan(&res.pmon, &scan)
        return res


Full = Monoid()

MAX_SIZE = cmonoid.SIZE
