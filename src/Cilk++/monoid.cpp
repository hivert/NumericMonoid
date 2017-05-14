#include <iostream>
#include "monoid.hpp"

bool monoid_equal(monoid m1, monoid m2) {
  if (m1.conductor != m2.conductor) return false;
  if (m1.min != m2.min) return false;
  if (m1.genus != m2.genus) return false;

  for (auto i = 0; i < SIZE; i++) {
    if (m1.decs[i] != m2.decs[i]) return false;
  }

  return true;
}


void init_full_N(monoid &m)
{
  epi8 block ={1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8};
  for(auto i=0; i<NBLOCKS; i++){
    m.blocks[i] = block;
    block = block + 8;
  }
  m.genus = 0;
  m.conductor = 1;
  m.min = 1;
}

void print_monoid(const monoid &m)
{
  unsigned int i;
  std::cout<<"min = "<<m.min<<", cond = "<<m.conductor<<", genus = "<<m.genus<<", decs = ";
  for (i=0; i<SIZE; i++) std::cout<<((int) m.decs[i])<<' ';
  std::cout<<std::endl;
}

void print_epi8(epi8 bl)
{
  unsigned int i;
  for (i=0; i<16; i++) std::cout<<((uint8_t*)&bl)[i]<<' ';
  std::cout<<std::endl;
}
