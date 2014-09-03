#ifndef STACK_HPP
#define STACK_HPP
#include "semigroup.hpp"

class Stack{
public:
  SemiGroup *cache;
  SemiGroup* data[STACK_CAPACITY];
  ulong size;
  SemiGroup* pop();
  SemiGroup* push();
  Stack();
};

inline Stack::Stack(){
  cache=new SemiGroup;
  for(uint i=0;i<STACK_CAPACITY;++i){
    data[i]=new SemiGroup;
  }
}

inline SemiGroup* Stack::push(){
  return data[size++];
}


inline SemiGroup* Stack::pop(){
  SemiGroup* temp=data[--size];
  data[size]=cache;
  return cache=temp;
}

#endif
