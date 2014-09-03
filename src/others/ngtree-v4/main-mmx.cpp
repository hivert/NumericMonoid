#include <iostream>
#include "stack.hpp"
#include <string.h>
#include <cstdlib>

using namespace std;

int main(int argc,char** argv){
  cout<<"Computing until genus "<<GMAX<<endl;
  Stack stack;
  int i;
  init(*stack.data[0]);
  stack.size=1;

  //Init mmx
  __asm__("movq $0x0101010101010101,%rax \n"
	  "movq %rax,%mm2 \n"
	  "movq $0x0000000000000000,%rax \n" 
	  "movq %rax,%mm3 \n");
  byte g,m,y,x,s,t;
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
	  nsg->m=(x==m)?x+1:m;
	  nsg->g=g;
	  __asm__(//"mms \n"
	  "movq %0,%%rax \n"            //&tab[1] --> roax
	  "movq %1,%%rdx \n"            //&ntab[x+1] --> rdx
	  "movb %2,%%cl \n"             //size-x-1 --> cl
	  "LOOP_MMX: \n"                //start of the loop using mmx operation
	  "movq %%mm3,%%mm0 \n"         //0x00|00|00|00|00|00|00|00 --> mm0
	  "pcmpeqb (%%rax),%%mm0 \n"    //test per byte if *rax==0 
	                                //if true the corresping byte in mm0 is 0xFF else is 0x00 
	  "pandn %%mm2,%%mm0 \n"        //0x01|01|01|01|01|01|01|01 and (not mm0)--> mm0
	  "movq (%%rdx),%%mm1 \n"       //*rdx --> mm1
	  "psubb %%mm0,%%mm1 \n"        //mm1-mm0 --> mm1
	                                //if we put *rax=B0|B1|... and *rdx=C0|C1|... then
	                                //mm1=D0|D1|... where D0=C0 if B0==0 and D0=C0-1 if B0!=0
	  "movq %%mm1,(%%rdx) \n"       //mm1 -> *rdx
	  "add $8,%%rax \n"             //rax+=8
	  "add $8,%%rdx \n"             //rdx+=8
	  "sub $8,%%cl\n"               //cl-=8
	  "cmp $8,%%cl\n"               //compare cl with 8
	  "ja LOOP_MMX\n"               //if cl>=8 goto LOOP_MMX there is enought space to use mmx register
	  "REM_LOOP: \n"                //start of the loop using byte operation
	  "cmpb $0,(%%rax) \n"          //compare *rax with 0
	  "jz REM_END_LOOP \n"          //if *rax==0 nothing to do and fo to REM_END_LOOP
	  "decb (%%rdx) \n"             //else (*rdx)--
	  "REM_END_LOOP: \n"              
	  "incq %%rax \n"               //rax++
	  "incq %%rdx \n"               //rdx++   
	  "decb %%cl\n"                 //cl--
	  "jnz REM_LOOP\n"              //if cl!=0 goto REM_LOOP
	  :
	  :"g"(&data[1]),"g"(&ndata[x+1]),"g"((byte)(SIZE-x-1))
	  :"rax","cl","rdx","mm0","mm1");

	}
      }
      ng[g]+=t;
    } 
  }
  for(i=0;i<=GMAX;++i){
    cout<<i<<" -> "<<ng[i]<<endl;
  }
  
}
