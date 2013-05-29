// Compilation:
//    gcc -O3 -Wall -ggdb mgen.c -c && gcc mgen.o -o mgen
// Visualisation:
//    objdump -dS mgen.o

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include "alarm.h"
#include "monoid.h"

result results;

unsigned long int stack_pointer = 0;
monoid stack[100], current;

void print_sizes(void)
{
  int i;

  printf("Size = ");
  for (i=0; i<MAX_GENUS; i++) printf("%llu ", results[i]);
  printf("\n");
}
void progress_report(void) { print_sizes(); }

int main(void)
{
  unsigned long int i;

  printf("Computing number of numeric monoids for genus <= %i\n", MAX_GENUS);
  start_alarm();

  for (i=0; i<MAX_GENUS; i++) results[i] = 0;

  init_full_N(&current);
  remove_generator(&current, &(stack[0]), 1);
  stack_pointer++;
  results[0] = 1;

  walk_children_stack(stack, MAX_GENUS, results);

  printf("\n============================\n\n");
  print_sizes();
  return EXIT_SUCCESS;
}

