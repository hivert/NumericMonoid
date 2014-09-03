#ifndef SEMIGROUP_HPP
#define SEMIGROUP_HPP
#include "config.hpp"
#include "types.hpp"

struct SemiGroup{
  byte c,m,g;
  byte data[SIZE];
};

void init(SemiGroup& sg);

void disp(SemiGroup& sg);


inline void init(SemiGroup& sg){
  sg.c=sg.m=2;
  sg.g=1;
  for(byte i=0;i<SIZE;++i) sg.data[i]=i/2;
}

inline SemiGroup* copy(SemiGroup* sg){
  SemiGroup* res=new SemiGroup;
  res->c=sg->c;
  res->m=sg->m;
  res->g=sg->g;
  for(byte i=0;i<SIZE;++i) res->data[i]=sg->data[i];
  return res;
}

inline void disp(SemiGroup& sg){
  bool begin=true;
  cout<<'<';
  for(byte i=0;i<SIZE;++i){
    if(sg.data[i]==1){
      if(not begin) cout<<',';
      else begin=false;
      cout<<i;
    }
  }
  cout<<"> g="<<sg.g<<", m="<<sg.m<<", c="<<sg.c<<endl;
}

inline void full_disp(SemiGroup& sg){
  for(byte i=0;i<SIZE;++i) cout<<sg.data[i]<<' ';
  cout<<": g="<<sg.g<<", m="<<sg.m<<", c="<<sg.c<<endl;
}

#endif
