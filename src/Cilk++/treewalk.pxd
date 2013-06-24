from monoid cimport *
from libcpp.list cimport list as stl_list

cdef extern from "cilk/reducer_list.h" namespace "cilk":
    cdef cppclass reducer_list_append[T]:
        reducer_list_append() nogil except +
        reducer_list_append(stl_list[T] &) nogil except +
        stl_list[T] get_value() nogil
        stl_list[T] &get_reference() nogil
        void set_value(stl_list[T] &) nogil
        void push_back(T) nogil


cdef extern from "treewalk.hpp":
    ctypedef unsigned long int results_type[cMAX_GENUS]
    void walk_children_stack(monoid m, results_type &res) nogil
    void walk_children_stack(monoid m, ind_t bound, results_type &res) nogil

    cdef cppclass ResultsReducer:
        ResultsReducer()  nogil except +
        unsigned long int & operator[](ind_t i) nogil
        results_type &get_array() nogil
        void reset() nogil

    ResultsReducer cilk_results
    reducer_list_append[monoid] cilk_list_results
    void walk_children(const monoid &m) nogil
    void walk_children(const monoid &m, ind_t bound) nogil
    void list_children(const monoid &m, ind_t bound) nogil

