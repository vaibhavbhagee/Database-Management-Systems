import random

class Dataset():
    def __init__(self, n=100, d=20, outfile='datasets/points.txt'):
        self.outfile = outfile
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
    dataset = Dataset(n=10, d=3)
    dataset.write()
