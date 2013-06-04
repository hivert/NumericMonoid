#include <reducer_opadd.h>
#include <holder.h>
#include <iostream>

using namespace std;
typedef unsigned char epi8 __attribute__ ((vector_size (16)));

#define MAX_GENUS 40
#define SIZE_BOUND (3*(MAX_GENUS-1))
#define NBLOCKS ((SIZE_BOUND+15) >> 4)
#define SIZE (NBLOCKS << 4)


typedef unsigned char nb_decompositions[SIZE] __attribute__ ((aligned (16)));
typedef unsigned long long int result[MAX_GENUS];

struct monoid
{
  nb_decompositions decs;
  unsigned long int conductor, min, genus;
};

void init_full_N(monoid &);
void print_monoid(const monoid &);
void print_epi8(epi8);
inline void copy_decs(      nb_decompositions &__restrict__ dst,
		      const nb_decompositions &__restrict__ src);
inline monoid remove_generator(const monoid &__restrict__, unsigned long int);


const unsigned long int target_genus = MAX_GENUS;


////////////////////////////////////////////


#include <stdio.h>
#include <assert.h>
#include <x86intrin.h>

#define nth_block(st, i) (((epi8 *) st)[i])
#define load_epi8(t) ((epi8) _mm_loadu_si128((__m128i *) (t)))
#define store_epi8(t, v) (_mm_store_si128((__m128i *) (t), (__m128i) (v)))
#define storeu_epi8(t, v) (_mm_storeu_si128((__m128i *) (t), (__m128i) (v)))
#define update_epi8(d,s) (d)=(epi8) _mm_sub_epi8((__m128i) (d),  _mm_andnot_si128(_mm_cmpeq_epi8((__m128i) (s), (__m128i)zero),(__m128i) block1));



const epi8 zero   = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
const epi8 block1 = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1};
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

class generator_iter
{
  const monoid &m;
  unsigned long int iblock, mask, gen, bound;

  generator_iter(const monoid &mon) : m(mon), bound((mon.conductor+mon.min+15) >> 4) {};

    public:
  static inline generator_iter all(const monoid &m)
  {
    epi8 block;
    generator_iter it(m);
    it.iblock = 0;
    block = nth_block(m.decs, 0);
    ((unsigned char*)(&block))[0]=0; // 0 is not a generator
    it.mask  = _mm_movemask_epi8((__m128i) _mm_cmpeq_epi8((__m128i) block, (__m128i) block1));
    it.gen = - 1;
    it.iblock++;
    return it;
  };

  static inline generator_iter children(const monoid &m)
  {
    generator_iter it(m);
    epi8 block;
    it.iblock = m.conductor >> 4;
    block = nth_block(m.decs, it.iblock) & mask16[m.conductor & 0xF];
    it.mask  = _mm_movemask_epi8(_mm_cmpeq_epi8((__m128i) block, (__m128i) block1));
    it.gen = (it.iblock << 4) - 1;
    it.iblock++;
    return it;
  };

  inline generator_iter next()
  {
    unsigned long int shift;
    epi8 block;

    while (!mask)
      {
	if (iblock > bound) return *this;
	gen = (iblock << 4) - 1;
	block = nth_block(m.decs, iblock);
	mask  = _mm_movemask_epi8(_mm_cmpeq_epi8((__m128i) block, (__m128i) block1));
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
	block = nth_block(m.decs, iblock);
	nbr += _mm_popcnt_u32(_mm_movemask_epi8(_mm_cmpeq_epi8((__m128i) block, (__m128i) block1)));
      }
    return nbr;
  };

  inline bool const is_finished() { return  (iblock > bound); };
  inline unsigned long int const get_gen() {return gen;}
};

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


inline void copy_decs(      nb_decompositions &__restrict__ dst,
		      const nb_decompositions &__restrict__ src)
{
  unsigned long int i;
  for (i=0; i<NBLOCKS; i++) nth_block(&dst, i) = nth_block(&src, i);
}


inline void remove_generator(monoid &__restrict__ dst,
			     const monoid &__restrict__ src,
			     unsigned long int gen)
{
  unsigned long int start_block, decal;
  epi8 block;

  assert(src.decs[gen] == 1);

  dst.conductor = gen + 1;
  dst.genus = src.genus + 1;
  dst.min = (gen == src.min) ? dst.conductor : src.min;

  copy_decs(dst.decs, src.decs);

  start_block = gen >> 4;
  decal = gen & 0xF;
  // Shift block by decal uchar
  block = (epi8) _mm_shuffle_epi8((__m128i) nth_block(src.decs, 0),
				  (__m128i) shift16[decal]);
  update_epi8(nth_block(dst.decs,start_block),block)
#if NBLOCKS >= 5

#define CASE_UNROLL(i_loop)			\
  case i_loop : \
      update_epi8(nth_block(dst.decs, i_loop+1),load_epi8(srcblock)); \
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
      block = load_epi8(src.decs + ((i-start_block)<<4) - decal);
      update_epi8(nth_block(dst.decs,i),block);
    }
#endif

  assert(dst.decs[dst.conductor-1] == 0);
}

inline monoid remove_generator(const monoid &__restrict__ src, unsigned long int gen)
{
  monoid dst;
  remove_generator(dst, src, gen);
  return dst;
}

void init_full_N(monoid &m)
{
  unsigned long int i;
  epi8 block ={1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8};
  epi8 block8={8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8};
  for(i=0; i<NBLOCKS; i++){
    nth_block(m.decs, i) = block;
    block=(epi8) _mm_add_epi8( (__m128i) block, (__m128i) block8);
  }
  m.genus = 0;
  m.conductor = 1;
  m.min = 1;
}


cilk::reducer_opadd<unsigned long int> cilk_result[target_genus];

inline void walk_children_stack(const monoid &m, unsigned long int bound)
{
  unsigned long int stack_pointer = 1, nbr;
  monoid current, stack[100];

  stack[0] = m;
  while (stack_pointer)
    {
      --stack_pointer;
      if (stack[stack_pointer].genus < bound - 1)
	{
	  nbr = 0;

	  current.genus = stack[stack_pointer].genus;
	  current.conductor = stack[stack_pointer].conductor;
	  current.min = stack[stack_pointer].min;
	  copy_decs(current.decs, stack[stack_pointer].decs);

	  for (auto it = generator_iter::children(current).next();
	       not it.is_finished();
	       it.next())
	    {
	      remove_generator(stack[stack_pointer++], current, it.get_gen());
	      nbr++;
	    }
	  cilk_result[current.genus] += nbr;
	}
      else
	{
	  cilk_result[stack[stack_pointer].genus] +=
	    generator_iter::children(stack[stack_pointer]).count();
	}
    }
}


////////////////////////////////////////////

void walk_children(const monoid &m)
{
  unsigned long int nbr = 0;

  if (m.genus < target_genus - 10)
    {
      for (auto it = generator_iter::children(m).next();
	   not it.is_finished();
	   it.next())
	{
	  cilk_spawn walk_children(remove_generator(m, it.get_gen()));
	  nbr++;
	}
      cilk_result[m.genus] += nbr;
     }
  else
    walk_children_stack(m, target_genus);
}


int main(void)
{
  monoid N, N1;

  std::cout << "Computing number of numeric monoids for genus <= "
	    << target_genus << std::endl;
  init_full_N(N);
  N1 = remove_generator(N, 1);
  cilk_result[0]++;

  cilk_spawn walk_children(N1);
  cilk_sync;

  std::cout << std::endl << "============================" << std::endl << std::endl;
  for (unsigned int i=0; i<target_genus; i++)
    std::cout << cilk_result[i].get_value() << " ";
  std::cout << std::endl;
  return EXIT_SUCCESS;
}

