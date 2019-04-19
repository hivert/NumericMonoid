#include <iostream>
#include <iomanip>
#include <chrono>

using namespace std;
using namespace std::chrono;

#include "treewalk.hpp"

void walk_children_stack(monoid m, results_type &res)
{
  unsigned long int nbr;
  monoid stack[MAX_GENUS], father;
  monoid *stack_pointer = stack + 1;

  stack[0] = m;
  while (stack_pointer != stack)
    {
      // pop from the stack
      --stack_pointer;
      father = *stack_pointer;
      if (father.genus < MAX_GENUS - 1)
	{
	  nbr = 0;
	  auto it = generator_iter<CHILDREN>(father);
	  while (it.move_next())
	    {
              // push on the stack
	      remove_generator(*stack_pointer, father, it.get_gen());
	      stack_pointer++;
	      nbr++;
	    }
	  res[father.genus] += nbr;
	}
      else
	{
	  auto it = generator_iter<CHILDREN>(father);
	  res[father.genus] += it.count();
	}
    }
}


results_type cilk_results[128];


#ifndef STACK_BOUND
#define STACK_BOUND 11
#endif

void walk_children(const monoid m)
{
  if (m.genus < MAX_GENUS - STACK_BOUND)
    {
      auto it = generator_iter<CHILDREN>(m);
      while (it.move_next())
	{
	  cilk_spawn walk_children(remove_generator(m, it.get_gen()));
	  cilk_results[__cilkrts_get_worker_number()][m.genus] ++;
	}
     }
  else
    walk_children_stack(m, cilk_results[__cilkrts_get_worker_number()]);
}




void walk_children_stack(monoid m, ind_t bound, results_type &res)
{
  unsigned long int nbr;
  monoid stack[bound], father;
  monoid *stack_pointer = stack + 1;

  stack[0] = m;
  while (stack_pointer != stack)
    {
      // pop from the stack
      --stack_pointer;
      father = *stack_pointer;
      if (father.genus < bound - 1)
	{
	  nbr = 0;
	  auto it = generator_iter<CHILDREN>(father);
	  while (it.move_next())
	    {
              // push on the stack
	      remove_generator(*stack_pointer, father, it.get_gen());
	      stack_pointer++;
	      nbr++;
	    }
	  res[father.genus] += nbr;
	}
      else
	{
	  auto it = generator_iter<CHILDREN>(father);
	  res[father.genus] += it.count();
	}
    }
}

void walk_children(const monoid &m, ind_t bound)
{
  if (m.genus < bound - STACK_BOUND)
    {
      auto it = generator_iter<CHILDREN>(m);
      while (it.move_next())
	{
	  cilk_spawn walk_children(remove_generator(m, it.get_gen()), bound);
	  cilk_results[__cilkrts_get_worker_number()][m.genus] ++;
	}
     }
  else
    walk_children_stack(m, bound, cilk_results[__cilkrts_get_worker_number()]);
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
      auto it = generator_iter<CHILDREN>(m);
      while (it.move_next())
	cilk_spawn list_children(remove_generator(m, it.get_gen()), bound);
     }
  else
    cilk_list_results.push_back(m);
}

#include "alarm.hpp"

void reset_sizes() {
  for (unsigned int i=0; i<MAX_GENUS; i++)
    for (int w=0; w < __cilkrts_get_nworkers(); w++)
      cilk_results[w][i] = 0;
}

unsigned long int get_sizes(results_type &restab) {
  unsigned long int total = 0;
  for (unsigned int i=0; i<MAX_GENUS; i++) {
    restab[i] = 0;
    for (int w=0; w < __cilkrts_get_nworkers(); w++)
      restab[i] += cilk_results[w][i];
    total += restab[i];
  }
  return total;
}

void print_sizes(void)
{
  results_type restab;
  unsigned long int total = get_sizes(restab);
  for (unsigned int i=0; i<MAX_GENUS; i++)
    cout << restab[i] << " ";
  cout << endl;
  cout << "Total = " << total << endl;
}


void progress_report(void) { print_sizes(); }

#include <cpuid.h>

static void show_usage(string name)
{
  cerr << "Usage: " << name << " [-n <proc_number>] " << endl;
}


int main(int argc, char **argv)
{
  monoid N;
  string nproc = "0";

  if (argc != 1 and argc != 3) { show_usage(argv[0]); return 1; }
  if (argc == 3)
    {
      if (string(argv[1]) != "-n")  { show_usage(argv[0]); return 1; }
      nproc = argv[2];
    }

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

  if (__cilkrts_set_param("nworkers", nproc.c_str() ) != __CILKRTS_SET_PARAM_SUCCESS)
    cerr << "Failed to set the number of Cilk workers" << endl;

  cout << "Computing number of numeric monoids for genus <= "
       << MAX_GENUS << " using " << __cilkrts_get_nworkers() << " workers" << endl;
  cout << "Sizeof(monoid) = " << sizeof(monoid) << endl;
  reset_sizes();
  start_alarm();
  auto begin = high_resolution_clock::now();
  init_full_N(N);
  walk_children(N);
  auto end = high_resolution_clock::now();
  duration<double> ticks = end-begin;

  cout << endl << "============================" << endl << endl;

  print_sizes();
  cout << "computation time = " << std::setprecision(4) << ticks.count() << " s."  << endl;
  return EXIT_SUCCESS;
}

