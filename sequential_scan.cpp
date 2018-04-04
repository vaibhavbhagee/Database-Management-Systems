#include <bits/stdc++.h>
using namespace std;

struct dataset_t {
    int n;
    int d;
    vector<vector<double>> points;
};

void read_dataset(dataset_t &dataset, string filename) {
    ifstream fin(filename);
    fin >> dataset.d >> dataset.n;
    dataset.points.clear();
    const int n = dataset.n;
    const int d = dataset.d;
    dataset.points.resize(n, vector<double>(d, 0));
    for(int i = 0; i < n; ++i) {
        for(int j = 0; j < d; ++j) {
            fin >> dataset.points[i][j];
        }
    }
}

void print_dataset(const dataset_t &dataset) {
    const int n = dataset.n;
    const int d = dataset.d;
    for(int i = 0; i < n; ++i) {
        for(int j = 0; j < d; ++j) {
            cout << dataset.points[i][j] << " ";
        }
        cout << "\n";
    }
}

inline double square_dist(const int d, const vector<double> &pt1, const vector<double> &pt2) {
    double answer = 0;
    for(int i = d-1; i > 0; --i) {
        double diff = pt1[i] - pt2[i];
        answer += diff * diff;
    }
    return answer;
}

void sequential_scan(const dataset_t &dataset, const vector<double> &point, const int k) {
    // point: query_point is a double vector of dimension d
    // dataset: the da
    const int n = dataset.n;
    const int d = dataset.d;
    // maintains the largest points that are possible. 
    // always pop the largest point if the number of points exceeds k
    priority_queue<pair<double, int> > q;
    for(int i = 0; i < n; ++i) {
        double dst = square_dist(d, dataset.points[i], point);
        q.push({dst, i});
        if(q.size() > (unsigned int)k) {
            q.pop();
        }
    }
}

int main() {
    dataset_t dataset;
    read_dataset(dataset, "datasets/points.txt");
    print_dataset(dataset);
}
