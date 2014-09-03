#ifndef TYPES_HPP
#define TYPES_HPP

#include <iostream>

using namespace std;

typedef short int sint;
typedef unsigned char uchar;
typedef unsigned char byte;
typedef unsigned short int usint;
typedef unsigned int uint;
typedef unsigned long ulong;

inline ostream& operator<<(ostream& os,byte b){
  os<<(usint)b;
  return os;
}

#endif
