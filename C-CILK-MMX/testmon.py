from mon import Monoid, MAX_SIZE, Full
m = Monoid()
print m
mm = m.remove_generator(1)
print mm
print mm.count_children()
print mm.children()

mm = mm.remove_generator(3)
print mm
print mm.generators()
print mm.count_children()

print mm.children()

print MAX_SIZE

print len(Full.nth_generation(15))

print mm.elements()

import moncilk
r = moncilk.callcilk(m)
print r