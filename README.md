Computing the number of Numerical Monoid of a Given Genus
=========================================================

This is a very optimized implementation of algorithm described in

Jean Fromentin and Florent Hivert. 2016. Exploring the tree of numerical semi-
groups. Math. Comput. 85, 301 (2016), 2553–2568.
DOI:https://doi.org/10.1090/mcom/3075

The more up to date code is in directory src/Cilk++/ together with a Sagemath
binding.

Description of the problem
==========================

A *numerical semigroup* is a subset of the set of natural number which
- contains 0
- is stable under addition
- has a finite complement

The elements of the complement are called *gaps*. The number of gaps is
called the *genus*.

The goal is to compute the number n(g) of semigroups of a given genus.

A few conjectures:

- Bras-amoros 2008 : n(g) >= n(g-1) + n(g-2). Still widely open.
- Zhai 2013 n(g) >= n(g-1) asymptotically true, but open for small g.

See http://images.math.cnrs.fr/Semigroupes-numeriques-et-nombre-d-or-II.html (in French) for more explanation.

We also validated Wilf conjecture upto n=60 and invalidated some stronger statements (See Near-misses in Wilf's conjecture, Shalom Eliahou, Jean Fromentin https://arxiv.org/abs/1710.03623v1).

Results
=======

Below is the table of the results (A more computer friendly syntax is at the end of https://github.com/hivert/NumericMonoid/raw/master/src/Sizes



 g | number of semigroups    | g | number of semigroups    | g | number of semigroups    |
---|-------------------------|---|-------------------------|---|-------------------------|
 0 | 1                       |25 | 467224                  |50 | 101090300128            |
 1 | 1                       |26 | 770832                  |51 | 164253200784            |
 2 | 2                       |27 | 1270267                 |52 | 266815155103            |
 3 | 4                       |28 | 2091030                 |53 | 433317458741            |
 4 | 7                       |29 | 3437839                 |54 | 703569992121            |
 5 | 12                      |30 | 5646773                 |55 | 1142140736859           |
 6 | 23                      |31 | 9266788                 |56 | 1853737832107           |
 7 | 39                      |32 | 15195070                |57 | 3008140981820           |
 8 | 67                      |33 | 24896206                |58 | 4880606790010           |
 9 | 118                     |34 | 40761087                |59 | 7917344087695           |
10 | 204                     |35 | 66687201                |60 | 12841603251351          |
11 | 343                     |36 | 109032500               |61 | 20825558002053          |
12 | 592                     |37 | 178158289               |62 | 33768763536686          |
13 | 1001                    |38 | 290939807               |63 | 54749244915730          |
14 | 1693                    |39 | 474851445               |64 | 88754191073328          |
15 | 2857                    |40 | 774614284               |65 | 143863484925550         |
16 | 4806                    |41 | 1262992840              |66 | 233166577125714         |
17 | 8045                    |42 | 2058356522              |67 | 377866907506273         |
18 | 13467                   |43 | 3353191846              |68 | 612309308257800         |
19 | 22464                   |44 | 5460401576              |69 | 992121118414851         |
20 | 37396                   |45 | 8888486816              |70 | 1607394814170158        |
21 | 62194                   |46 | 14463633648             |
22 | 103246                  |47 | 23527845502             |
23 | 170963                  |48 | 38260496374             |
24 | 282828                  |49 | 62200036752             |


























