from multiprocessing.managers import BaseManager
import secret

class QueueManager(BaseManager): pass

QueueManager.register('get_data')
QueueManager.register('get_results')
m = QueueManager(address=(secret.master_ip,
                          secret.com_port),
                 authkey=secret.password)
m.connect()
data = m.get_data()
results = m.get_results()

def work():
    import numeric_monoid
    print "Waiting for some job..."
    x = data.get()
    while x != None:
        mon, genus = x
        print "Computing... %s upto genus=%s"%(mon, genus)
        results.put(mon.walk_children(genus))
        print "Waiting for some job..."
        x = data.get()
    print "Shutdown"
