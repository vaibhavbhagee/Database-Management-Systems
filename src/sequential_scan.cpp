#include <fstream>
#include <iostream>
#include <queue>
#include <vector>
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
    fin.close();
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
    for(int i = d-1; i >= 0; --i) {
        double diff = pt1[i] - pt2[i];
        answer += diff * diff;
    }
    return answer;
}

inline void read_query_file(vector<double> &query_point, const string query_file) {
    int d;
    ifstream fin(query_file);
    fin >> d;
    query_point.clear();
    query_point.resize(d, 0);
    for(int i = 0; i < d; ++i) {
        fin >> query_point[i];
    }
    fin.close();
}

void sequential_scan(const dataset_t &dataset, const vector<double> &point, const int k) {
    // point: query_point is a double vector of dimension d
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
    ofstream fout("results.txt");
    vector<int> order;
    while(not q.empty()) {
        order.push_back(q.top().second);
        q.pop();
    }
    for(int i = order.size() - 1; i >= 0; --i) {
        int index = order[i];
        for(double elem: dataset.points[index]) {
            fout << elem << " ";
        }
        fout << "\n";
    }
}

inline void print_query_point(const vector<double> query_point) {
    for(int i = 0; i < (int)query_point.size(); ++i) {
        cerr << query_point[i] << " ";
    }
    cerr << "\n";
}

int main(int argc, char *argv[]) {
    int k;
    dataset_t dataset;
    vector<double> query_point;
    string query_file;

    // read dataset and then flush 0 to STDOUT
    string dataset_file = argv[1];
    read_dataset(dataset, dataset_file);
    cout << 0 << endl;

    // read queryfile name and k
    cin >> query_file >> k;
    read_query_file(query_point, query_file);

    // write the results to results.txt and flush 1
    sequential_scan(dataset, query_point, k);
    cout << 1 << endl;
}
