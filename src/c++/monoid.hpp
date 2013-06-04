#ifndef MONOID_H
#define MONOID_H

#include <iostream>

using namespace std;
typedef unsigned char epi8 __attribute__ ((vector_size (16)));

#define MAX_GENUS 40
#define SIZE_BOUND (3*(MAX_GENUS-1))
#define NBLOCKS ((SIZE_BOUND+15) >> 4)
#define SIZE (NBLOCKS << 4)

#define NOINLINE
// #define NOINLINE   __attribute__ ((noinline))
// #define inline

typedef unsigned char nb_decompositions[SIZE] __attribute__ ((aligned (16)));
typedef unsigned long long int result[MAX_GENUS];

struct monoid
{
  nb_decompositions decs;
  unsigned long int conductor, min, genus;
};

struct generator_iter
{
  unsigned long int iblock, mask, gen, bound;
};

void init_full_N(monoid *pm);
monoid *alloc_monoid(void);
void print_monoid(monoid *);
void print_epi8(epi8);
inline void copy_decs(nb_decompositions *src, nb_decompositions *dst) NOINLINE;
void remove_generator(monoid *__restrict__, monoid *__restrict__, unsigned long int);


inline void init_all_generator_iter(monoid *pm, generator_iter *scan) NOINLINE;
inline void init_children_generator_iter(monoid *pm, generator_iter *scan) NOINLINE;
inline unsigned long int next_generator_iter(monoid *pm, generator_iter *scan) NOINLINE;
inline unsigned char count_generator_iter(monoid *pm, generator_iter *scan) NOINLINE;

void walk_children_stack(monoid stack[], unsigned long int bound, result results);

#endif
