#ifndef MONOID_HPP
#define MONOID_HPP

#include <iostream>

using namespace std;

#define MAX_GENUS 40
#define SIZE_BOUND (3*(MAX_GENUS-1))
#define NBLOCKS ((SIZE_BOUND+15) >> 4)
#define SIZE (NBLOCKS << 4)

#include <x86intrin.h>

typedef unsigned char epi8 __attribute__ ((vector_size (16)));
typedef unsigned char dec_numbers[SIZE] __attribute__ ((aligned (16)));
typedef epi8 dec_blocks[NBLOCKS];

/*
Note: for some reason the code using gcc vector variables is 2-3% faster than
the code using gcc intrinsic instructions.
Here are the results of two runs:
data_mmx =  [9.757, 9.774, 9.757, 9.761, 9.811, 9.819, 9.765, 9.888, 9.774, 9.771]
data_epi8 = [9.592, 9.535, 9.657, 9.468, 9.460, 9.679, 9.458, 9.461, 9.629, 9.474]
*/

extern inline epi8 load_unaligned_epi8(const unsigned char *t)
{ return (epi8) _mm_loadu_si128((__m128i *) (t)); };

extern inline epi8 shuffle_epi8(epi8 b, epi8 sh)
{ return (epi8) _mm_shuffle_epi8((__m128i) b, (__m128i) sh);}

extern inline int movemask_epi8(epi8 b)
{ return _mm_movemask_epi8((__m128i) b);};

const epi8 zero   = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
const epi8 block1 = zero + 1;
const unsigned char m1 = 255;
const epi8 shift16[16] =
  { { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15},
    {m1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14},
    {m1,m1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13},
    {m1,m1,m1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12},
    {m1,m1,m1,m1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11},
    {m1,m1,m1,m1,m1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10},
    {m1,m1,m1,m1,m1,m1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9},
    {m1,m1,m1,m1,m1,m1,m1, 0, 1, 2, 3, 4, 5, 6, 7, 8},
    {m1,m1,m1,m1,m1,m1,m1,m1, 0, 1, 2, 3, 4, 5, 6, 7},
    {m1,m1,m1,m1,m1,m1,m1,m1,m1, 0, 1, 2, 3, 4, 5, 6},
    {m1,m1,m1,m1,m1,m1,m1,m1,m1,m1, 0, 1, 2, 3, 4, 5},
    {m1,m1,m1,m1,m1,m1,m1,m1,m1,m1,m1, 0, 1, 2, 3, 4},
    {m1,m1,m1,m1,m1,m1,m1,m1,m1,m1,m1,m1, 0, 1, 2, 3},
    {m1,m1,m1,m1,m1,m1,m1,m1,m1,m1,m1,m1,m1, 0, 1, 2},
    {m1,m1,m1,m1,m1,m1,m1,m1,m1,m1,m1,m1,m1,m1, 0, 1},
    {m1,m1,m1,m1,m1,m1,m1,m1,m1,m1,m1,m1,m1,m1,m1, 0} };
const epi8 mask16[16] =
  { {m1,m1,m1,m1,m1,m1,m1,m1,m1,m1,m1,m1,m1,m1,m1,m1},
    { 0,m1,m1,m1,m1,m1,m1,m1,m1,m1,m1,m1,m1,m1,m1,m1},
    { 0, 0,m1,m1,m1,m1,m1,m1,m1,m1,m1,m1,m1,m1,m1,m1},
    { 0, 0, 0,m1,m1,m1,m1,m1,m1,m1,m1,m1,m1,m1,m1,m1},
    { 0, 0, 0, 0,m1,m1,m1,m1,m1,m1,m1,m1,m1,m1,m1,m1},
    { 0, 0, 0, 0, 0,m1,m1,m1,m1,m1,m1,m1,m1,m1,m1,m1},
    { 0, 0, 0, 0, 0, 0,m1,m1,m1,m1,m1,m1,m1,m1,m1,m1},
    { 0, 0, 0, 0, 0, 0, 0,m1,m1,m1,m1,m1,m1,m1,m1,m1},
    { 0, 0, 0, 0, 0, 0, 0, 0,m1,m1,m1,m1,m1,m1,m1,m1},
    { 0, 0, 0, 0, 0, 0, 0, 0, 0,m1,m1,m1,m1,m1,m1,m1},
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,m1,m1,m1,m1,m1,m1},
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,m1,m1,m1,m1,m1},
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,m1,m1,m1,m1},
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,m1,m1,m1},
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,m1,m1},
    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,m1} };

struct monoid
{
  union {
    dec_numbers decs;
    dec_blocks blocks;
  };
  unsigned long int conductor, min, genus;
};

void init_full_N(monoid &);
void print_monoid(const monoid &);
void print_epi8(epi8);
inline void copy_blocks(      dec_blocks &__restrict__ dst,
			const dec_blocks &__restrict__ src) __attribute__((always_inline));
inline void remove_generator(monoid &__restrict__ dst,
		      const monoid &__restrict__ src,
		      unsigned long int gen) __attribute__((always_inline));
inline monoid remove_generator(const monoid &src, unsigned long int gen);


const unsigned long int target_genus = MAX_GENUS;


class generator_iter
{
private:
  const monoid &m;
  unsigned long int iblock, mask, gen, bound;

  inline generator_iter(const monoid &mon) : m(mon), bound((mon.conductor+mon.min+15) >> 4) {};

public:
  static inline generator_iter all_count(const monoid &m)
  {
    epi8 block;
    generator_iter it(m);
    it.iblock = 0;
    block = m.blocks[0];
    it.mask  = movemask_epi8(block == block1);
    it.mask &= 0xFE; // 0 is not a generator
    it.gen = - 1;
    it.iblock++;
    return it;
  };

  static inline generator_iter children_count(const monoid &m)
  {
    generator_iter it(m);
    epi8 block;
    it.iblock = m.conductor >> 4;
    block = m.blocks[it.iblock] & mask16[m.conductor & 0xF];
    it.mask  = movemask_epi8(block == block1);
    it.gen = (it.iblock << 4) - 1;
    it.iblock++;
    return it;
  };

  static inline generator_iter all(const monoid &m)
  { return ++generator_iter::all_count(m); };
  static inline generator_iter children(const monoid &m)
  { return ++generator_iter::children_count(m); };

  inline generator_iter operator++()
  {
    unsigned long int shift;
    epi8 block;

    while (!mask)
      {
	if (iblock > bound) return *this;
	gen = (iblock << 4) - 1;
	block = m.blocks[iblock];
	mask  = movemask_epi8(block == block1);
	iblock++;
      }
    shift = __bsfd (mask) + 1;
    gen += shift;
    mask >>= shift;
    return *this;
  };

  inline unsigned char count()
  {
    epi8 block;
    unsigned char nbr = _mm_popcnt_u32(mask);
    for (/* nothing */ ; iblock <= bound; iblock++)
      {
	block = m.blocks[iblock];
	nbr += _mm_popcnt_u32(movemask_epi8(block == block1));
      }
    return nbr;
  };

  inline bool is_finished() const { return  (iblock > bound); };
  inline unsigned long int get_gen() const {return gen; };
};

#include <assert.h>

void print_monoid(const monoid &m)
{
  unsigned int i;
  cout<<"min = "<<m.min<<", cond = "<<m.conductor<<", genus = "<<m.genus<<", decs = ";
  for (i=0; i<SIZE; i++) cout<<((int) m.decs[i])<<' ';
  cout<<endl;
}


void print_epi8(epi8 bl)
{
  unsigned int i;
  for (i=0; i<16; i++) cout<<((unsigned char*)&bl)[i]<<' ';
  cout<<endl;
}


inline void copy_blocks(dec_blocks &dst, dec_blocks const &src)
{
  unsigned long int i;
  for (i=0; i<NBLOCKS; i++) dst[i] = src[i];
}


void remove_generator(monoid &__restrict__ dst,
		      const monoid &__restrict__ src,
		      unsigned long int gen)
{
  unsigned long int start_block, decal;
  epi8 block;

  assert(src.decs[gen] == 1);

  dst.conductor = gen + 1;
  dst.genus = src.genus + 1;
  dst.min = (gen == src.min) ? dst.conductor : src.min;

  copy_blocks(dst.blocks, src.blocks);

  start_block = gen >> 4;
  decal = gen & 0xF;
  // Shift block by decal uchar
  block = shuffle_epi8(src.blocks[0], shift16[decal]);
  dst.blocks[start_block] -= ((block != zero) & block1);
#if NBLOCKS >= 5

#define CASE_UNROLL(i_loop)			\
  case i_loop : \
    dst.blocks[i_loop+1] -= (load_unaligned_epi8(srcblock) != zero) & block1; \
    srcblock += 16

  {
    const unsigned char *srcblock = src.decs + 16 - decal;
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
#if NBLOCKS > 14
      CASE_UNROLL(13);
#endif
#if NBLOCKS > 15
      CASE_UNROLL(14);
#endif
#if NBLOCKS > 16
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
      // block = *((epi8*)(src.decs + ((i-start_block)<<4) - decal));
      block = load_unaligned_epi8(src.decs + ((i-start_block)<<4) - decal);
      dst.blocks[i] -= ((block != zero) & block1);
    }
#endif

  assert(dst.decs[dst.conductor-1] == 0);
}

inline monoid remove_generator(const monoid &src, unsigned long int gen)
{
  monoid dst;
  remove_generator(dst, src, gen);
  return dst;
}

void init_full_N(monoid &m)
{
  unsigned long int i;
  epi8 block ={1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8};
  for(i=0; i<NBLOCKS; i++){
    m.blocks[i] = block;
    block = block + 8;
  }
  m.genus = 0;
  m.conductor = 1;
  m.min = 1;
}

#endif
