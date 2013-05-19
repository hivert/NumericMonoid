// Compilation:
//    gcc -O3 -Wall -ggdb mgen.c -c && gcc mgen.o -o mgen
// Visualisation:
//    objdump -dS mgen.o

#include <assert.h>
#include <stdio.h>
#include <x86intrin.h>


typedef char epi8 __attribute__ ((vector_size (16)));
epi8 zero   = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
epi8 block2 = {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2};
epi8 shift16[16] =
  { { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15},
    {-1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14},
    {-1,-1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13},
    {-1,-1,-1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12},
    {-1,-1,-1,-1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11},
    {-1,-1,-1,-1,-1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10},
    {-1,-1,-1,-1,-1,-1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9},
    {-1,-1,-1,-1,-1,-1,-1, 0, 1, 2, 3, 4, 5, 6, 7, 8},
    {-1,-1,-1,-1,-1,-1,-1,-1, 0, 1, 2, 3, 4, 5, 6, 7},
    {-1,-1,-1,-1,-1,-1,-1,-1,-1, 0, 1, 2, 3, 4, 5, 6},
    {-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, 0, 1, 2, 3, 4, 5},
    {-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, 0, 1, 2, 3, 4},
    {-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, 0, 1, 2, 3},
    {-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, 0, 1, 2},
    {-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, 0, 1},
    {-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, 0} };
epi8 mask16[16] =
  { {-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
    { 0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
    { 0, 0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
    { 0, 0, 0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
    { 0, 0, 0, 0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
    { 0, 0, 0, 0, 0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
    { 0, 0, 0, 0, 0, 0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
    { 0, 0, 0, 0, 0, 0, 0,-1,-1,-1,-1,-1,-1,-1,-1,-1},
    { 0, 0, 0, 0, 0, 0, 0, 0,-1,-1,-1,-1,-1,-1,-1,-1},
    { 0, 0, 0, 0, 0, 0, 0, 0, 0,-1,-1,-1,-1,-1,-1,-1},
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,-1,-1,-1,-1,-1,-1},
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,-1,-1,-1,-1,-1},
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,-1,-1,-1,-1},
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,-1,-1,-1},
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,-1,-1},
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,-1} };


#define nth_block(st, i) (((epi8 *) st)[i])
#define load_epi8(t) ((epi8) _mm_loadu_si128((__m128i *) (t)))
#define store_epi8(t, v) (_mm_store_si128((__m128i *) (t), (__m128i) (v)))
#define storeu_epi8(t, v) (_mm_storeu_si128((__m128i *) (t), (__m128i) (v)))

#define MAX_GENUS 35
#define SIZE_BOUND (3*MAX_GENUS-1)
#define NBLOCKS ((SIZE_BOUND+15) >> 4)
#define SIZE (NBLOCKS << 4)



typedef unsigned char nb_decompositions[SIZE] __attribute__ ((aligned (16)));
typedef struct {
  nb_decompositions decs;
  unsigned long int conductor, min, genus;
} monoid;

unsigned long long int results[MAX_GENUS+1];
unsigned long int stack_pointer = 0;
monoid stack[100], current;

void print_monoid(monoid *pm)
{
  unsigned int i;
  printf("min = %li, cond = %li, genus = %li, decs = ",
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

void print_sizes(void)
{
  int i;

  printf("Size = ");
  for (i=0; i<MAX_GENUS; i++) printf("%llu ", results[i]);
  printf("\n");
}


#include <unistd.h>
#include <signal.h>

#define PERIOD 5
int nproc, nloops=0;
void sigalrm_handler( int sig )
{
  printf("\nNloops = %i\n", nloops++);
  print_sizes();
  alarm(PERIOD);
}

void start_alarm(void)
{
    struct sigaction sact;

    sigemptyset(&sact.sa_mask);
    sact.sa_flags = 0;
    sact.sa_handler = sigalrm_handler;
    sigaction(SIGALRM, &sact, NULL);

    alarm(PERIOD);
}


inline void remove_generator(monoid *__restrict__ src,
		      monoid *__restrict__ dst,
		      unsigned long int gen)
{
  unsigned long int start_block, decal, i;
  epi8 block;

  assert(src->decs[gen] == 2);

  dst->conductor = gen + 1;
  dst->genus = src->genus + 1;
  dst->min = gen == src->min ? dst->conductor : src->min;

  for (i=0; i<NBLOCKS; i++)
    nth_block(dst->decs, i) = nth_block(src->decs, i);

  start_block = gen >> 4;
  decal = gen & 0xF;
  // Shift block by decal uchar
  block = (epi8) _mm_shuffle_epi8((__m128i) nth_block(src->decs, 0),
				  (__m128i) shift16[decal]);
  nth_block(dst->decs, start_block) -= ((block != zero) & block2);

  for (i=start_block+1; i<NBLOCKS; i++)
    {
      // The following won't work due to a bug in GCC 4.7.1
      // block = *((epi8*)(src->decs + ((i-start_block)<<4) - decal));
      block = load_epi8(src->decs + ((i-start_block)<<4) - decal);
      nth_block(dst->decs, i) -= ((block != zero) & block2);
    }
  if (2*gen<SIZE) dst->decs[2*gen]++;

  assert(dst->decs[dst->conductor-1] == 0);
}


int main(void)
{
  unsigned long int i;
  epi8 block;

  printf("Computing number of numeric monoids for genus <= %i\n", MAX_GENUS);
  start_alarm();

  for (i=0; i<=MAX_GENUS; i++) results[i] = 0;

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
      unsigned long int iblock, decal, shift, gen;
      unsigned int mask;
      epi8 block;

      // current = stack[--stack_pointer];
      --stack_pointer;
      current.genus = stack[stack_pointer].genus;
      current.conductor = stack[stack_pointer].conductor;
      current.min = stack[stack_pointer].min;
      for (i=0; i<NBLOCKS; i++)
	nth_block(current.decs, i) = nth_block(stack[stack_pointer].decs, i);

//printf("SP = %li\n", stack_pointer);
//print_monoid(&current);
      iblock = current.conductor >> 4;
      decal = current.conductor & 0xF;
      block = nth_block(current.decs, iblock) & mask16[decal];
      mask  = _mm_movemask_epi8((__m128i) (block == block2));
      if (current.genus < MAX_GENUS - 1)
	{
	  unsigned long int nbr = 0;
	  do
	    {
	      gen = (iblock << 4) - 1;
	      while (mask)
		{
		  shift = __bsfd (mask) + 1;
		  gen += shift;
		  mask >>= shift;
		  remove_generator(&current, &(stack[stack_pointer++]), gen);
		  nbr++;
		}
	      iblock++;
	      block = nth_block(current.decs, iblock);
	      mask  = _mm_movemask_epi8((__m128i) (block == block2));
	    }
	  while (iblock <= (current.conductor+current.min+15) >> 4);
	  results[current.genus]+=nbr;
	}
      else
	{
	  unsigned char nbr = _mm_popcnt_u32(mask);
	  for (iblock++; iblock <= (current.conductor+current.min+15) >> 4; iblock++)
	    {
	      block = nth_block(current.decs, iblock);
	      nbr += _mm_popcnt_u32(_mm_movemask_epi8((__m128i) (block == block2)));
	    }
	  results[current.genus]+=nbr;
	}
    }
  printf("\n============================\n\n");
  print_sizes();
  return EXIT_SUCCESS;
}

