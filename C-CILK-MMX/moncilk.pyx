cimport cmonoid, mon

from libc.stdlib cimport malloc, free

cdef extern from "cilk.h":
    ctypedef struct CilkContext:
        pass
    cdef CilkContext *Cilk_init(int *, char**)

cdef extern from "mongen.h":
    cdef cmonoid.result *results_proc_local
    cdef cmonoid.monoid **stacks_proc_local
    cdef int nproc
    cdef void walk_children_cilk "EXPORT(walk_children)"(CilkContext *context, cmonoid.monoid *pm)

cdef extern from "alarm.h":
     void start_alarm()

cdef list argv = ["bla", "-nproc", "8"]

cpdef unsigned long int callcilk(mon.Monoid m):
    cdef char **c_argv = <char**>malloc(sizeof(char*) * len(argv))
    cdef int argc = len(argv), proc, res = 0, i
    cdef CilkContext *context
    global stacks_proc_local, results_proc_local, nproc

    nproc=8

    # Init the various stacks
    stacks_proc_local = <cmonoid.monoid **> malloc(nproc*sizeof(cmonoid.monoid*));
    for proc in range(nproc):
        stacks_proc_local[proc] = <cmonoid.monoid *> malloc(100*sizeof(cmonoid.monoid));

    # Init the proc local results
    results_proc_local = <cmonoid.result *> malloc(nproc*sizeof(cmonoid.result))
    for proc in range(nproc):
        for i in range(cmonoid.MAX_GENUS):
            results_proc_local[proc][i] = 0;

    for idx in range(len(argv)):
         c_argv[idx] = argv[idx]

    start_alarm()
    context = Cilk_init(&argc, c_argv)
    print "GOOOOOOO !!!!!!!!"
    walk_children_cilk(context, &m._m)

    for i in range(cmonoid.MAX_GENUS):
        res = 0
        for proc in range(nproc):
            res += results_proc_local[proc][i];
        print "nmon(%s) = %s"%(i, res)
    res = 0
    for proc in range(nproc):
        res += results_proc_local[proc][cmonoid.MAX_GENUS-1];
    for proc in range(nproc):
        free(stacks_proc_local[proc])
    free(stacks_proc_local)
    free(results_proc_local)
    return res
