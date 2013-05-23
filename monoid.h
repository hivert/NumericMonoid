typedef unsigned char epi8 __attribute__ ((vector_size (16)));

#define MAX_GENUS 40
#define SIZE_BOUND (3*(MAX_GENUS-1))
#define NBLOCKS ((SIZE_BOUND+15) >> 4)
#define SIZE (NBLOCKS << 4)

#define NOINLINE
// #define NOINLINE   __attribute__ ((noinline))
// #define inline

typedef unsigned char nb_decompositions[SIZE] __attribute__ ((aligned (16)));
typedef struct {
  nb_decompositions decs;
  unsigned long int conductor, min, genus;
} monoid;

typedef unsigned long long int result[MAX_GENUS];

void init_full_N(monoid *pm);
monoid *alloc_monoid();
void print_monoid(monoid *);
void print_epi8(epi8);
inline void copy_decs(nb_decompositions *src, nb_decompositions *dst) NOINLINE;
inline void remove_generator(monoid *__restrict__, monoid *__restrict__, unsigned long int) NOINLINE;

typedef struct
{
  unsigned long int iblock, mask, gen, bound;
} monoid_generator_scan;

inline void init_all_generator_scan(monoid *pm, monoid_generator_scan *scan) NOINLINE;
inline void init_children_generator_scan(monoid *pm, monoid_generator_scan *scan) NOINLINE;
inline unsigned long int next_generator_scan(monoid *pm, monoid_generator_scan *scan) NOINLINE;
inline unsigned char count_generator_scan(monoid *pm, monoid_generator_scan *scan) NOINLINE;

inline void walk_children_stack(monoid stack[], result results) NOINLINE;
