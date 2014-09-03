#include <iostream>
#include "stack.hpp"
#include <string.h>

using namespace std;


int main(){
  ulong c1[2]={0x0101010101010101,0x0101010101010101};
  ulong c2[2]={0,0};
  __asm__("movq %0,%%rax \n"
	  "movaps (%%rax),%%xmm2 \n"
	  "movq %1,%%rax \n"
	  "movaps (%%rax),%%xmm3 \n"
	  :
	  :"g"(c1),"g"(c2)
	  :"rax","xmm2","xmm3");
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
 __asm__(//"mms \n"
	  "movq %0,%%rax \n"            //&tab[1] --> rax
	  "movq %1,%%rdx \n"            //&ntab[x+1] --> rdx
	  "movb %2,%%cl \n"             //size-x-1 --> cl
	  "cmp $16,%%cl \n"             //compare cl with 16
	  "jna REM_LOOP \n"             //if cl<16 goto REM_LOOP
	  "LOOP_SSE: \n"                //start of the loop using SSE operation
	  "movups %%xmm3,%%xmm0 \n"     //0x00|...|00 --> xmm0"
	  "movupd (%%rax),%%xmm4 \n"
	  "pcmpeqb %%xmm4,%%xmm0 \n"    //test per byte if *rax==0 
	                                //if true the corresping byte in xmm0 is 0xFF else is 0x00 
	  "pandn %%xmm2,%%xmm0 \n"      //0x01|...|01 and (not mm0)--> mm0
	  "movupd (%%rdx),%%xmm1 \n"
	  "psubb %%xmm0,%%xmm1 \n"      //xmm1-xmm0 --> xmm1
	                                //if we put *rax=B0|B1|... and *rdx=C0|C1|... then
	                                //xmm1=D0|D1|... where Di=Ci if Bi==0 and Di=Ci-1 if Bi!=0
	  "movupd %%xmm1,(%%rdx) \n"      //xmm1 -> *rdx
	  "add $16,%%rax \n"            //rax+=16
	  "add $16,%%rdx \n"            //rdx+=16
	  "sub $16,%%cl\n"              //cl-=16
	  "cmp $16,%%cl\n"              //compare cl with 16
	  "ja LOOP_SSE\n"               //if cl>=16 goto LOOP_SSE there is enought space to use SSE register
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
	  :"rax","cl","rdx","mm0","mm1"
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
