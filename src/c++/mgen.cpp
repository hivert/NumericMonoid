// Compilation:
//    gcc -O3 -Wall -ggdb mgen.c -c && gcc mgen.o -o mgen
// Visualisation:
//    objdump -dS mgen.o

#include <assert.h>
#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include "alarm.hpp"
#include "monoid.hpp"

using namespace std;

result results;

unsigned long int stack_pointer = 0;
monoid stack[100], current;

void print_sizes(void)
{
  int i;

  cout<<"Size = ";
  for (i=0; i<MAX_GENUS; i++) cout<<results[i]<<' ';
  cout<<endl;
}

void progress_report(void) { print_sizes(); }

int main(void)
{
  unsigned long int i;

  cout<<"Computing number of numeric monoids for genus <= "<<MAX_GENUS<<endl;
  start_alarm();

  for (i=0; i<MAX_GENUS; ++i) results[i] = 0;

  init_full_N(&current);
  remove_generator(&current, &(stack[0]), 1);
  ++stack_pointer;
  results[0] = 1;

  walk_children_stack(stack, MAX_GENUS, results);

  cout<<endl<<"============================"<<endl<<endl;
  print_sizes();
  return EXIT_SUCCESS;
}

