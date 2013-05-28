#include<cilk.h>
#include "monoid.h"

extern result *results_proc_local;
extern monoid **stacks_proc_local;
extern int nproc;

extern void EXPORT(walk_children)(CilkContext *context, monoid *pm);
