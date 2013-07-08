#include <iostream>

using namespace std;

#include "treewalk.hpp"

void walk_children_stack(monoid m, results_type &res)
{
  unsigned long int nbr;
  monoid data[MAX_GENUS-1], *stack[MAX_GENUS], *current;
  monoid **stack_pointer = stack + 1;

  for (ind_t i=1; i<MAX_GENUS; i++) stack[i] = &(data[i-1]); // Nathann's trick to avoid copy
  stack[0] = &m;
  while (stack_pointer != stack)
    {
      --stack_pointer;
      current = *stack_pointer;
      if (current->genus < MAX_GENUS - 1)
	{
	  nbr = 0;
	  auto it = generator_iter(*current, generator_iter::CHILDREN);
	  while (it.move_next())
	    {
	      // exchange top with top+1
	      stack_pointer[0] = stack_pointer[1];
	      remove_generator(**stack_pointer, *current, it.get_gen());
	      stack_pointer++;
	      nbr++;
	    }
	  *stack_pointer = current;
	  res[current->genus] += nbr;
	}
      else
	{
	  auto it = generator_iter(*current, generator_iter::CHILDREN);
	  res[current->genus] += it.count();
	}
    }
}


ResultsReducer cilk_results;

#define STACK_BOUND 11
void walk_children(const monoid &m)
{
  unsigned long int nbr = 0;

  if (m.genus < MAX_GENUS - STACK_BOUND)
    {
      auto it = generator_iter(m, generator_iter::CHILDREN);
      while (it.move_next())
	{
	  cilk_spawn walk_children(remove_generator(m, it.get_gen()));
	  nbr++;
	}
      cilk_results[m.genus] += nbr;
     }
  else
    walk_children_stack(m, cilk_results.get_array());
}




void walk_children_stack(monoid m, ind_t bound, results_type &res)
{
  ind_t stack_pointer = 1;
  unsigned long int nbr;
  monoid data[bound], *stack[bound], *current;

  for (ind_t i=1; i<bound; i++) stack[i] = &(data[i-1]); // Nathann's trick to avoid copy
  stack[0] = &m;
  while (stack_pointer)
    {
      --stack_pointer;
      current = stack[stack_pointer];
      if (current->genus < bound - 1)
	{
	  nbr = 0;
	  auto it = generator_iter(*current, generator_iter::CHILDREN);
	  while (it.move_next())
	    {
	      // exchange top with top+1
	      stack[stack_pointer] = stack[stack_pointer+1];
	      remove_generator(*stack[stack_pointer], *current, it.get_gen());
	      stack_pointer++;
	      nbr++;
	    }
	  stack[stack_pointer] = current;
	  res[current->genus] += nbr;
	}
      else
	{
	  auto it = generator_iter(*current, generator_iter::CHILDREN);
	  res[current->genus] += it.count();
	}
    }
}

void walk_children(const monoid &m, ind_t bound)
{
  unsigned long int nbr = 0;

  if (bound > STACK_BOUND && m.genus < bound - STACK_BOUND)
    {
      auto it = generator_iter(m, generator_iter::CHILDREN);
      while (it.move_next())
	{
	  cilk_spawn walk_children(remove_generator(m, it.get_gen()), bound);
	  nbr++;
	}
      cilk_results[m.genus] += nbr;
     }
  else
    walk_children_stack(m, bound, cilk_results.get_array());
}

#ifdef TBB
#include <tbb/scalable_allocator.h>
cilk::reducer_list_append<monoid, tbb::scalable_allocator<monoid>> cilk_list_results;
#else
cilk::reducer_list_append<monoid> cilk_list_results;
#endif

void list_children(const monoid &m, ind_t bound)
{
  if (m.genus < bound)
    {
      auto it = generator_iter(m, generator_iter::CHILDREN);
      while (it.move_next())
	cilk_spawn list_children(remove_generator(m, it.get_gen()), bound);
     }
  else
    cilk_list_results.push_back(m);
}


#include <cpuid.h>
#include <cilk/cilk_api.h>

int main(void)
{
  monoid N;
  unsigned long int total = 0;

  unsigned int ax, bx, cx, dx;
  if (!__get_cpuid(0x00000001, &ax, &bx, &cx, &dx))
    {
      cerr << "Unable to determine the processor type !" << endl;
      return EXIT_FAILURE;
    }
  if (!(cx & bit_SSSE3))
    {
      cerr << "This programm require sse3 instructions set !" << endl;
      return EXIT_FAILURE;
    }
  if (!(cx & bit_POPCNT))
    {
      cerr << "This programm require popcount instruction !" << endl;
      return EXIT_FAILURE;
    }

  if (__cilkrts_set_param("nworkers", "0") != __CILKRTS_SET_PARAM_SUCCESS)
    cerr << "Failed to set the number of Cilk workers" << endl;

  cout << "Computing number of numeric monoids for genus <= "
	    << MAX_GENUS << " using " << __cilkrts_get_nworkers() << " workers" << endl;
  init_full_N(N);
  walk_children(N);

  cout << endl << "============================" << endl << endl;
  for (unsigned int i=0; i<MAX_GENUS; i++)
    {
      cout << cilk_results[i] << " ";
      total += cilk_results[i];
    }
  cout << endl;
  cout << "Total = " << total << endl;
  return EXIT_SUCCESS;
}

