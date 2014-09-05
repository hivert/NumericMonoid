#include <time.h>
#include <iostream>
#include <list>
#include <stdlib.h>
#include <string.h>

using namespace std;

typedef unsigned char uchar; 
typedef unsigned short int usint;
typedef unsigned long long integer;

usint size;

class SemiGroup{
public:
  uchar* tab;
  uchar c,g,m;
  SemiGroup();
  SemiGroup(const SemiGroup& S,uchar x);
  ~SemiGroup();
};

SemiGroup::SemiGroup(){
  c=m=1;
  g=0;
  tab=new uchar[size];
  for(int i=0;i<size;++i) tab[i]=i/2+1;
}

SemiGroup::~SemiGroup(){
  delete[] tab;
}

SemiGroup::SemiGroup(const SemiGroup& S,uchar x){
  usint i;
  g=S.g+1;
  c=x+1;
  m=(x==S.m)?m=S.m+1:S.m;
  uchar v;
  tab=new uchar[size];
  memcpy(tab,S.tab,size);
  tab[x]=0;
  for(i=x+1;i<size;++i){
    if(S.tab[i-x]>0) --tab[i];
  }
}

int main(int argc,char** argv){
  if(argc!=2){
    cout<<"You must sepcify uniquely the genus"<<endl;
    return -1;
  }
  int g,i,G;
  uchar c,m,x;
  SemiGroup *S,*Sx;
  list<SemiGroup*> st;
  G=atoi(argv[1]);
  size=3*G;
  integer ng[G+1];
  for(i=0;i<=G;++i) ng[i]=0;
  st.push_back(new SemiGroup);
  ng[0]=1;
  while(not st.empty()){
    S=st.back();
    st.pop_back();
    if(S->g<G){
      c=S->c;
      m=S->m;
      for(x=c;x<c+m;++x){
	if(S->tab[x]==1){
	  Sx=new SemiGroup(*S,x);
	  ng[Sx->g]++;
	  st.push_back(Sx);
	}
      }
    }
    delete S;
  }
  /*for(i=0;i<=G;++i){
    cout<<i<<"->"<<ng[i]<<endl;
    }*/
  cout<<1.0*long(clock())/CLOCKS_PER_SEC<<endl;
}
