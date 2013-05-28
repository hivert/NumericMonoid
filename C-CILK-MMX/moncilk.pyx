cimport cmonoid, mon

from libc.stdlib cimport malloc, free

cdef extern from "cilk.h":
    ctypedef struct CilkContext:
        pass
    cdef CilkContext *Cilk_init(int *, char**)
    cdef void Cilk_terminate(CilkContext *)

cdef extern from "mongen.h":
    cdef cmonoid.result *results_proc_local
    cdef cmonoid.monoid **stacks_proc_local
    cdef int nproc
    cdef void walk_children_cilk "EXPORT(walk_children)"(CilkContext *, cmonoid.monoid *)

cdef extern from "alarm.h":
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


cpdef list callcilk(mon.Monoid m):
    cdef int proc, res = 0, i
    cdef list resl
    global stacks_proc_local, results_proc_local, nproc


    if context == NULL:
        init()

    for proc in range(nproc):
        for i in range(cmonoid.MAX_GENUS):
            results_proc_local[proc][i] = 0;

    print "GOOOOOOO !!!!!!!!"

    start_alarm()
    walk_children_cilk(context, &m._m)
    stop_alarm()

    resl = []
    for i in range(cmonoid.MAX_GENUS):
        res = 0
        for proc in range(nproc):
            res += results_proc_local[proc][i];
        resl.append(res)
    return resl

init()
