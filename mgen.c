// Compilation:
//    gcc -O3 -Wall -ggdb mgen.c -c && gcc mgen.o -o mgen
// Visualisation:
//    objdump -dS mgen.o

#include <stdio.h>
#include <emmintrin.h>
#include <assert.h>

typedef char epi8 __attribute__ ((vector_size (16)));
epi8 zero   = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
epi8 block2 = {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2};

#define nth_block(st, i) (((epi8 *) st)[i])
#define load_epi8(t) ((epi8) _mm_loadu_si128((__m128i *) (t)))
#define store_epi8(t, v) (_mm_store_si128((__m128i *) (t), (__m128i) (v)))
#define storeu_epi8(t, v) (_mm_storeu_si128((__m128i *) (t), (__m128i) (v)))

#define MAX_GENUS 30
#define SIZE_BOUND (3*MAX_GENUS-1)
#define NBLOCKS ((SIZE_BOUND+15) >> 4)
#define SIZE (NBLOCKS << 4)



typedef unsigned char nb_decompositions[SIZE] __attribute__ ((aligned (16)));
typedef struct {
  nb_decompositions decs;
  unsigned char conductor, min, genus;
} monoid;

unsigned long long int number[MAX_GENUS+1];
unsigned int stack_pointer = 0;
monoid stack[100], current;

void print_monoid(monoid *pm)
{
  unsigned int i;
  printf("min = %i, cond = %i, genus = %i, decs = ",
	 pm->min, pm->conductor, pm->genus);
  for (i=0; i<SIZE; i++) printf("%u ", pm->decs[i]);
  printf("\n");
}

void print_epi8(epi8 bl)
{
  unsigned int i;
  for (i=0; i<16; i++) printf("%u ", bl[i]);
  printf("\n");
}

void remove_generator(monoid *src, monoid *dst, unsigned char gen)
{
  unsigned char start_block, decal, i;
  epi8 block;

  assert(src->decs[gen] == 2);

  dst->conductor = gen + 1;
  dst->genus = src->genus + 1;
  if (gen == src->min) dst->min = dst->conductor;
  else                 dst->min = src->min;
  start_block = gen >> 4;
  for (i=0; i<start_block; i++)
    nth_block(dst->decs, i) = nth_block(src->decs, i);
  decal = gen - (gen & 0xFFF0);
  block = zero;
  for (i=decal; i<16; i++) block[i] = src->decs[i-decal];
  nth_block(dst->decs, start_block) =
    nth_block(src->decs, start_block) - ((block != zero) & block2);
  for (i=start_block+1; i<NBLOCKS; i++)
    {
      // The following won't work due to a bug in GCC 4.7.1
      // block = *((epi8*)(src->decs+ ((i-start_block)<<4) - decal));
      block = load_epi8(src->decs+ ((i-start_block)<<4) - decal);
      nth_block(dst->decs, i) =
	nth_block(src->decs, i) - ((block != zero) & block2);
    }
  if (gen+gen<SIZE) dst->decs[gen+gen]++;

  assert(dst->decs[dst->conductor-1] == 0);
}


int main(void)
{
  unsigned int i, genus;
  epi8 block;

  for (i=0; i<=MAX_GENUS; i++) number[i] = 0;
  for (i=0; i<16; i++) block[i] = i+1;
  for (i=0; i<NBLOCKS; i++) nth_block(current.decs, i) = block + ((char) (i<<4));
  current.genus = 0;
  current.conductor = 1;
  current.min = 1;
  remove_generator(&current, &(stack[0]), 1);
  stack_pointer++;

  while (stack_pointer)
    {
      stack_pointer--;
      genus = stack[stack_pointer].genus;
      number[genus]++;
      if (genus < MAX_GENUS)
	{
	  current = stack[stack_pointer];
	  for (i = current.conductor; i <= current.conductor+current.min; i++)
	    if (current.decs[i] == 2)
	      {
		remove_generator(&current, &(stack[stack_pointer]), i);
		stack_pointer++;
	      }
	}
    }
  printf("Size = ");
  for (i=1; i<=MAX_GENUS; i++) printf("%llu ", number[i]);
  printf("\n");
  return EXIT_SUCCESS;
}

