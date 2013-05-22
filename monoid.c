#include <stdio.h>
#include <assert.h>
#include "monoid.h"

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

void print_monoid(monoid *pm)
{
  unsigned int i;
  printf("min = %lu, cond = %lu, genus = %lu, decs = ",
	 pm->min, pm->conductor, pm->genus);
  for (i=0; i<SIZE; i++) printf("%u ", pm->decs[i]);
  printf("\n");
}


void print_epi8(epi8 bl)
{
  unsigned int i;
  for (i=0; i<16; i++) printf("%u ", ((unsigned char*)&bl)[i]);
  printf("\n");
}


inline void copy_decs(nb_decompositions *dst, nb_decompositions *src)
{
  unsigned long int i;
  for (i=0; i<NBLOCKS; i++) nth_block(dst, i) = nth_block(src, i);
}


inline void remove_generator(monoid *__restrict__ src,
		      monoid *__restrict__ dst,
		      unsigned long int gen)
{
  unsigned long int start_block, decal;
  epi8 block;

  assert(src->decs[gen] == 2);

  dst->conductor = gen + 1;
  dst->genus = src->genus + 1;
  dst->min = gen == src->min ? dst->conductor : src->min;

  copy_decs(&dst->decs, &src->decs);

  start_block = gen >> 4;
  decal = gen & 0xF;
  // Shift block by decal uchar
  block = (epi8) _mm_shuffle_epi8((__m128i) nth_block(src->decs, 0),
				  (__m128i) shift16[decal]);
  nth_block(dst->decs, start_block) -= ((block != zero) & block2);

#if NBLOCKS >= 5
#warning "Using unrolled loop version"

#define CASE_UNROLL(i_loop)			\
  case i_loop : \
      nth_block(dst->decs, i_loop+1) -= ((load_epi8(srcblock) != zero) & block2); \
      srcblock += 16

  {
    unsigned char *srcblock = src->decs + 16 - decal;
  switch(start_block)
    {
      CASE_UNROLL(0);
      CASE_UNROLL(1);
      CASE_UNROLL(2);
      CASE_UNROLL(3);
#if NBLOCKS > 5
      CASE_UNROLL(4);
#endif
#if NBLOCKS > 6
      CASE_UNROLL(5);
#endif
#if NBLOCKS > 7
      CASE_UNROLL(6);
#endif
#if NBLOCKS > 8
      CASE_UNROLL(7);
#endif
#if NBLOCKS > 9
      CASE_UNROLL(8);
#endif
#if NBLOCKS > 10
      CASE_UNROLL(9);
#endif
#if NBLOCKS > 11
      CASE_UNROLL(10);
#endif
#if NBLOCKS > 12
      CASE_UNROLL(11);
#endif
#if NBLOCKS > 13
      CASE_UNROLL(12);
#endif
#if NBLOCK > 14
#error "Too many blocks"
#endif
    }
  }
#else
  #warning "Loop not unrolled"
  unsigned long int i;
  for (i=start_block+1; i<NBLOCKS; i++)
    {
      // The following won't work due to a bug in GCC 4.7.1
      // block = *((epi8*)(src->decs + ((i-start_block)<<4) - decal));
      block = load_epi8(src->decs + ((i-start_block)<<4) - decal);
      nth_block(dst->decs, i) -= ((block != zero) & block2);
    }
#endif
  if (2*gen<SIZE) dst->decs[2*gen]++;

  assert(dst->decs[dst->conductor-1] == 0);
}
