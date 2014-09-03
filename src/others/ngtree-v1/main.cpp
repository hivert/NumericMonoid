#include <iostream>
#include <list>
#include <stdlib.h>

using namespace std;

typedef unsigned char uchar; 
typedef unsigned short int usint;

class SemiGroup{
public:
  uchar* tab;
  uchar c,m;
  SemiGroup();
  SemiGroup(const SemiGroup& S,uchar x);
  ~SemiGroup();

};

SemiGroup::SemiGroup(){
  c=m=1;
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
  int g,G;
  uchar c,m,x;
  SemiGroup *S,*Sx;
  list<SemiGroup*> lg;
  list<SemiGroup*> next;
  list<SemiGroup*>::iterator it;
  G=atoi(argv[1]);
  lg.push_back(new SemiGroup);
  for(g=1;g<=G;++g){
    for(it=lg.begin();it!=lg.end();++it){
      S=*it;
      c=S->c;
      m=S->m;
      for(x=c;x<c+m;++x){
	if(S->tab[x]==1){
	  Sx=new SemiGroup(*S,x);
	  next.push_back(Sx);
	}
      }
      delete S;
    }
    //cout<<g<<" -> "<<next.size()<<endl;
    lg.clear();
    lg.swap(next);
  }
}
