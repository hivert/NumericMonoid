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
