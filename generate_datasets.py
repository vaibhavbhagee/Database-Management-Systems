import random
import os.path

class Dataset():
    def __init__(self, n=100, d=20, directory='datasets/'):
        self.outfile = os.path.join(directory, 'dataset.n.{}.d.{}.txt'.format(n, d))
        self.n = n
        self.d = d
        assert 1 <= self.n <= 1000000
        assert 1 <= self.d <= 20

    def write(self):
        points = [' '.join([str(random.random()) for dim in range(self.d)])
                  for pt in range(self.n)]
        with open(self.outfile, 'w') as fout:
            print('{} {}'.format(self.d, self.n), file=fout)
            for point in points:
                print(point, file=fout)

if __name__ == '__main__':
    for n in [10, 100, 1000, 10000, 1000000]:
        for d in [2, 3, 5, 10, 15, 20]:
            dataset = Dataset(n=n, d=d)
            dataset.write()
            print(dataset.outfile)
