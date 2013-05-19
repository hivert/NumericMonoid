#include <x86intrin.h>

typedef unsigned char epi8 __attribute__ ((vector_size (16)));
epi8 zero, block2, shift16[16], mask16[16];

#define nth_block(st, i) (((epi8 *) st)[i])
#define load_epi8(t) ((epi8) _mm_loadu_si128((__m128i *) (t)))
#define store_epi8(t, v) (_mm_store_si128((__m128i *) (t), (__m128i) (v)))
#define storeu_epi8(t, v) (_mm_storeu_si128((__m128i *) (t), (__m128i) (v)))

#define MAX_GENUS 40
#define SIZE_BOUND (3*(MAX_GENUS-1))
#define NBLOCKS ((SIZE_BOUND+15) >> 4)
#define SIZE (NBLOCKS << 4)


typedef unsigned char nb_decompositions[SIZE] __attribute__ ((aligned (16)));
typedef struct {
  nb_decompositions decs;
  unsigned long int conductor, min, genus;
} monoid;

typedef unsigned long long int result[MAX_GENUS];

result *results_proc_local;

void print_monoid(monoid *);
void print_epi8(epi8);
inline void copy_decs(nb_decompositions *src, nb_decompositions *dst);
inline void remove_generator(monoid *__restrict__, monoid *__restrict__, unsigned long int);
