#include <time.h>
#include <iostream>
#include <iomanip>
#include <cpuid.h>
#include "monoid.hpp"

using namespace std;

void walk_stack(monoid m, unsigned long int* res)
{
  unsigned long int nbr;
  monoid data[SIZE_BOUND], *stack[SIZE_BOUND], *current;
  monoid **stack_pointer = stack + 1;

  for (ind_t i=1; i<SIZE_BOUND; i++) stack[i] = &(data[i-1]); // Nathann's trick to avoid copy
  stack[0] = &m;
  while (stack_pointer != stack)
    {
      --stack_pointer;
      current = *stack_pointer;
      if (current->genus < MAX_GENUS - 1)
	{
	  nbr = 0;
	  auto it = generator_iter<CHILDREN>(*current);
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
	  auto it = generator_iter<CHILDREN>(*current);
	  res[current->genus] += it.count();
	}
    }
}




int main(int argc, char **argv)
{
  monoid N;
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

  init_full_N(N);
  unsigned long int ng[MAX_GENUS];
  for(unsigned int i=0;i<MAX_GENUS;++i){
    ng[i]=0;
  }
  walk_stack(N,ng);

  
  // cout << endl << "============================" << endl << endl;
  // for (unsigned int i=0; i<MAX_GENUS; i++)
  //   {
  //     cout << ng[i] << " ";
  //   }
  // cout << endl;
  cout<<1.0*long(clock())/CLOCKS_PER_SEC<<endl;
  return EXIT_SUCCESS;
}

