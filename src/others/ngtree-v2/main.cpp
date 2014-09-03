#include <iostream>
#include <list>
#include <stdlib.h>

using namespace std;

typedef unsigned char uchar; 
typedef unsigned short int usint;
typedef unsigned long long integer;

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
  tab=new uchar[c+m];
  tab[0]=2;
  tab[1]=1;
}

SemiGroup::~SemiGroup(){
  delete[] tab;
}

SemiGroup::SemiGroup(const SemiGroup& S,uchar x){
  usint i,j;
  uchar nb_irr=0;
  uchar s=S.m+S.c;
  g=S.g+1;
  c=x+1;
  m=(x==S.m)?m=S.m+1:S.m;
  uchar irr[m];
  uchar v;
  tab=new uchar[c+m];
  for(i=0;i<x;++i){
    v=S.tab[i];
    tab[i]=v;
    if(v==1){
      irr[nb_irr++]=i;
    }
  }
  tab[x]=0;
  for(i=x+1;i<c+m;++i){
    v=(i<s)?S.tab[i]:2;
    if(v==1){
      tab[i]=1;
      irr[nb_irr++]=i;
    }
    else{
      for(j=0;j<nb_irr;++j){
	if(tab[i-irr[j]]!=0) break;
      }
      if(j==nb_irr){
	tab[i]=1;
	irr[nb_irr++]=i;
      }
      else tab[i]=2;
    }
  }
}

int main(int argc,char** argv){
  if(argc!=2){
    cout<<"You must sepcify uniquley the genus"<<endl;
    return -1;
  }
  int g,i,G;
  uchar c,m,x;
  SemiGroup *S,*Sx;
  list<SemiGroup*> st;
  G=atoi(argv[1]);
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
}
