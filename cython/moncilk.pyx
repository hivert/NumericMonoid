cimport cmonoid, numeric_monoid
from sage.rings.integer cimport Integer

from libc.stdlib cimport malloc, free

cdef extern from "cilk.h":
    ctypedef struct CilkContext:
        pass
    cdef CilkContext *Cilk_init(int *, char**)
    cdef void Cilk_terminate(CilkContext *)

cdef extern from "../src/mongen.h":
    cdef cmonoid.result *results_proc_local
    cdef cmonoid.monoid **stacks_proc_local
    cdef unsigned long int target_genus
    cdef int nproc
    cdef void walk_children_cilk "EXPORT(walk_children)"(CilkContext *, cmonoid.monoid *)

cdef extern from "../src/alarm.h":
     void start_alarm()
     void stop_alarm()

cdef CilkContext *context = NULL


cpdef init():
    cdef list argv = ["bla", "-nproc", "8"]
    cdef char *c_argv[3]
    cdef int argc = len(argv), proc, i
    global stacks_proc_local, results_proc_local, nproc, context

    nproc=int(argv[2])

    stacks_proc_local = <cmonoid.monoid **> malloc(nproc*sizeof(cmonoid.monoid*));
    for proc in range(nproc):
        stacks_proc_local[proc] = <cmonoid.monoid *> malloc(100*sizeof(cmonoid.monoid));
    results_proc_local = <cmonoid.result *> malloc(nproc*sizeof(cmonoid.result))


    for idx in range(len(argv)):
         c_argv[idx] = argv[idx]

    context = Cilk_init(&argc, c_argv)

cpdef cleanup():
    global stacks_proc_local, results_proc_local, context
    Cilk_terminate (context)
    context = NULL
    for proc in range(nproc):
        free(stacks_proc_local[proc])
    free(stacks_proc_local)
    free(results_proc_local)


cpdef list callcilk(numeric_monoid.NumericMonoid m):
    """
    sage: import os; os.sys.path.insert(0,os.path.abspath('.')); import mon, moncilk
    sage: r = moncilk.callcilk(mon.Full)
    GOOOOOOO !!!!!!!!
    <BLANKLINE>
    Progress report no 0
    Size = 1 2 4 7 ...
    sage: r
    [1, 2, 4, 7, 12, 23, 39, 67, 118, 204, 343, 592, 1001, 1693, 2857, 4806, 8045, 13467, 22464, 37396, 62194, 103246, 170963, 282828, 467224, 770832, 1270267, 2091030, 3437839, 5646773, 9266788, 15195070, 24896206, 40761087, 66687201, 109032500, 178158289, 290939807, 474851445, 774614284]
    """
    cdef int proc, i
    cdef Integer res
    cdef list resl
    global stacks_proc_local, results_proc_local, target_genus, nproc


    if context == NULL:
        init()

    for proc in range(nproc):
        for i in range(cmonoid.MAX_GENUS):
            results_proc_local[proc][i] = 0;

    print "GOOOOOOO !!!!!!!!"

    target_genus = cmonoid.MAX_GENUS
    start_alarm()
    walk_children_cilk(context, &m._m)
    stop_alarm()

    resl = []
    for i in range(cmonoid.MAX_GENUS):
        res = Integer(0)
        for proc in range(nproc):
            res += Integer(results_proc_local[proc][i]);
        resl.append(res)
    return resl

init()
