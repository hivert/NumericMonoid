from multiprocessing.managers import BaseManager
import secret
print secret.com_port

class QueueManager(BaseManager): pass

import Queue
data = Queue.Queue()
results = Queue.Queue()
QueueManager.register('get_data', callable = lambda: data)
QueueManager.register('get_results', callable = lambda: results)
m = QueueManager(address=('', # I'm the master
                          secret.com_port),
                 authkey=secret.password)
s = m.get_server()
print "Lauching communication server..."
s.serve_forever()
