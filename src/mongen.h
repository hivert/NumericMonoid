#include<cilk.h>
#include "monoid.h"

extern result *results_proc_local;
extern monoid **stacks_proc_local;
extern unsigned long int target_genus;
extern int nproc;

extern void EXPORT(walk_children)(CilkContext *context, monoid *pm);
