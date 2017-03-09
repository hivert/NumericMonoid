#include <iostream>
#include <vector>
#include <string>

#include <cilk/cilk.h>
#include <cilk/cilk_api.h>
#include <cilk/reducer_opadd.h>

using namespace std;

cilk::reducer< cilk::op_add<int> > res(0);

void walk(vector<int> v, int bnd, unsigned size)
{
  if (v.size() == size) ++(*res);
  else
    for (int i=0; i<bnd; i++) {
      vector<int> vnew(v);
      vnew.push_back(i);
      cilk_spawn walk(vnew, bnd, size);
    }
}

int main(int argc, char **argv)
{
   string nproc = "0";

  if (argc == 3 and string(argv[1]) == "-n") nproc = argv[2];
  if (__cilkrts_set_param("nworkers", nproc.c_str() ) != __CILKRTS_SET_PARAM_SUCCESS)
    cerr << "Failed to set the number of Cilk workers" << endl;
  vector<int> v{};
  walk(v, 5, 5);
  cout << res.get_value() << endl;
}
