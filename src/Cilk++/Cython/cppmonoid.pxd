from libc.stdint cimport uint8_t, uint_fast64_t

cdef extern from "cmonoid.h":
    enum: MAX_GENUS
    enum: SIZE
    ctypedef uint_fast64_t ind_t
    ctypedef uint8_t dec_numbers[SIZE]
    cdef cppclass monoid:
        dec_numbers decs
        ind_t conductor, min, genus

    void init_full_N(monoid &pm)
    void print_monoid(monoid &)
    inline void remove_generator(monoid &dst, monoid &src, ind_t)

    enum generator_type "generator_iter::generator_type":
        ALL      "generator_iter::ALL"
        CHILDREN "generator_iter::CHILDREN"

    cdef cppclass generator_iter:
        generator_iter(const monoid &mon, generator_type tp)
        bint move_next()
        uint8_t count()
        ind_t get_gen() const

from libcpp.list cimport list as stl_list

cdef extern from "../treewalk.hpp":
    ctypedef unsigned long int results_type[MAX_GENUS]
    void walk_children_stack(monoid m, results_type &res)
    void walk_children_stack(monoid m, ind_t bound, results_type &res)

    cdef cppclass ResultsReducer:
        unsigned long int & operator[](int i)
        results_type &get_array()
        void reset()

    cdef cppclass ListReducer "cilk::reducer_list_append<monoid>":
        stl_list[monoid] get_value()
        stl_list[monoid] &get_reference()
    ResultsReducer cilk_results
    ListReducer cilk_list_results
    void walk_children(const monoid &m)
    void walk_children(const monoid &m, ind_t bound)
    void list_children(const monoid &m, ind_t bound)

