// Compilation:
//    gcc -O3 -Wall -ggdb mgen.c -c && gcc mgen.o -o mgen
// Visualisation:
//    objdump -dS mgen.o

#include <assert.h>
#include <stdio.h>
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
  epi8 block;

  printf("Computing number of numeric monoids for genus <= %i\n", MAX_GENUS);
  start_alarm();

  for (i=0; i<MAX_GENUS; i++) results[i] = 0;

  for (i=0; i<16; i++) block[i] = i+1;
  for (i=0; i<NBLOCKS; i++) nth_block(current.decs, i) = block + ((char) (i<<4));
  current.genus = 0;
  current.conductor = 1;
  current.min = 1;
  remove_generator(&current, &(stack[0]), 1);
  stack_pointer++;
  results[0] = 1;

  while (stack_pointer)
    {
      monoid_generator_scan scan;

      --stack_pointer;
      if (stack[stack_pointer].genus < MAX_GENUS - 1)
	{
	  unsigned long int nbr = 0, gen;

	  current.genus = stack[stack_pointer].genus;
	  current.conductor = stack[stack_pointer].conductor;
	  current.min = stack[stack_pointer].min;
	  copy_decs(&current.decs, &(stack[stack_pointer].decs));

	  init_generator_scan(&current, &scan);

	  while ((gen = next_generator_scan(&current, &scan)) != 0)
	    {
	      remove_generator(&current, &(stack[stack_pointer++]), gen);
	      nbr++;
	    }
	  results[current.genus] += nbr;
	}
      else
	{
	  init_generator_scan(&stack[stack_pointer], &scan);
	  results[stack[stack_pointer].genus] +=
	    count_generator_scan(&stack[stack_pointer], &scan);
	}
    }
  printf("\n============================\n\n");
  print_sizes();
  return EXIT_SUCCESS;
}

