#include <iostream>
#include "stack.hpp"
#include <string.h>

using namespace std;


int main(){
  Stack stack;
  init(*stack.data[0]);
  stack.size=1;
  byte i,g,m,x,s,t;
  ulong ng[GMAX+1];
  for(i=0;i<=GMAX;++i) ng[i]=0;
  ng[1]=1;
  byte *data,*ndata;
  SemiGroup *sg,*nsg;
  while(stack.size>0){
    sg=stack.pop(); 
    g=sg->g;
    if(g<GMAX){
      ++g;
      t=0;
      data=sg->data;
      s=(x=sg->c)+(m=sg->m);
      for(;x<s;++x){
	if(data[x]==1){
	  ++t;
	  nsg=stack.push();
	  ndata=nsg->data;
	  memcpy(ndata,data,SIZE);
	  ndata[x]=0;
	  nsg->c=x+1;
	   __asm__ ("movq %0,%%rax \n"           //&tab[1]--> rax
	  "movq %1,%%rdx \n"           //&ntab[x+1] --> rdx
	  "mov %2,%%cl \n"             //size-x-1->cl
	  "LOOP: \n"                   //start of the loop
	  "cmpb $0,(%%rax) \n"         //compare *rax with 0 ?
	  "jz END_LOOP \n"             //if *rax==0 goto REM_END_LOOP
	  "decb (%%rdx) \n"            //else (*rdx)--;
	  "END_LOOP: \n"           
	  "incq %%rax \n"              //rax++
	  "incq %%rdx \n"              //rdx++
	  "decb %%cl\n"                //cl--
	  "jnz LOOP\n"                 //if cl!=0 goto REM_LOOP
	  :
	  :"g"(&data[1]),"g"(&ndata[x+1]),"g"(byte(SIZE-x-1))
	  :"rax","cl","rdx"
	  );
	  nsg->m=(x==m)?x+1:m;
	  nsg->g=g;
	}
      }
      ng[g]+=t;
    } 
  }
  for(i=0;i<=GMAX;++i){
    cout<<i<<" -> "<<ng[i]<<endl;
  }
  
}
