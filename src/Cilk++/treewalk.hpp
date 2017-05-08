#include <cilk/cilk.h>
#include <atomic>
#include "monoid.hpp"

using results_type = std::atomic_uint_fast64_t[MAX_GENUS];

void walk_children_stack(monoid m, results_type res);
void walk_children_stack(monoid m, ind_t bound, results_type res);

extern results_type results;

void walk_children(const monoid m);
void walk_children(const monoid &m, ind_t bound);
void list_children(const monoid &m, ind_t bound);
