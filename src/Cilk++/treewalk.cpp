#include <cilk/reducer.h>
#include <iostream>

using namespace std;

#include "monoid.hpp"

struct Results
{
  typedef unsigned long int type[MAX_GENUS];
  type values;
  Results() {for(int i=0; i<MAX_GENUS; i++) values[i] = 0;};
};

class ResultsReducer
{
  struct Monoid: cilk::monoid_base<Results>
  {
    static void reduce (Results *left, Results *right){
      for(int i=0; i<MAX_GENUS; i++) left->values[i] += right->values[i];
    };
  };
private:
  cilk::reducer<Monoid> imp_;
public:
  ResultsReducer() : imp_() {};
  inline unsigned long int & operator[](int i) {
    return imp_.view().values[i];
  };
  inline Results::type &get_array() {return imp_.view().values;}
};


#define STACK_SIZE 50
void walk_children_stack(monoid m, unsigned long int bound, Results::type &res)
{
  unsigned long int stack_pointer = 1, nbr;
  monoid data[STACK_SIZE-1], *stack[STACK_SIZE], *current;

  for (int i=1; i<STACK_SIZE; i++) stack[i] = &(data[i-1]); // Nathann's trick to avoid copy
  stack[0] = &m;
  while (stack_pointer)
    {
      --stack_pointer;
      current = stack[stack_pointer];
      if (current->genus < bound - 1)
	{
	  nbr = 0;
	  for (auto it = generator_iter::children(*current);
	       not it.is_finished();
	       ++it)
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
	  res[current->genus] +=
	    generator_iter::children_count(*current).count();
	}
    }
}

ResultsReducer cilk_results;
////////////////////////////////////////////
#define STACK_BOUND 11
void walk_children(const monoid &m)
{
  unsigned long int nbr = 0;

  if (m.genus < target_genus - STACK_BOUND)
    {
      for (auto it = generator_iter::children(m);
	   not it.is_finished();
	   ++it)
	{
	  cilk_spawn walk_children(remove_generator(m, it.get_gen()));
	  nbr++;
	}
      cilk_results[m.genus] += nbr;
     }
  else
    walk_children_stack(m, target_genus, cilk_results.get_array());
}

#include <cilk/cilk_api.h>

int main(void)
{
  monoid N;

  if (__cilkrts_set_param("nworkers", "0") != __CILKRTS_SET_PARAM_SUCCESS)
    cerr << "Failed to set the number of workers" << endl;

  cout << "Computing number of numeric monoids for genus <= "
	    << target_genus << " using " << __cilkrts_get_nworkers() << " workers" << endl;
  init_full_N(N);
  walk_children(N);

  cout << endl << "============================" << endl << endl;
  for (unsigned int i=0; i<target_genus; i++)
    cout << cilk_results[i] << " ";
  cout << endl;
  return EXIT_SUCCESS;
}

