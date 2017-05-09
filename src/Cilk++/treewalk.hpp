#include <cilk/cilk.h>
#include <cilk/cilk_api.h>
#include <cilk/reducer.h>
#include <cilk/reducer_list.h>
#include "monoid.hpp"

typedef unsigned long int results_type[1024]; // to avoid false sharing
void walk_children_stack(monoid m, results_type res);
void walk_children_stack(monoid m, ind_t bound, results_type res);

extern results_type cilk_results[128];

#ifdef TBB
#include <tbb/scalable_allocator.h>
extern cilk::reducer_list_append<monoid, tbb::scalable_allocator<monoid>> cilk_list_results;
#else
extern cilk::reducer_list_append<monoid> cilk_list_results;
#endif


void walk_children(const monoid m);
void walk_children(const monoid &m, ind_t bound);
void list_children(const monoid &m, ind_t bound);
