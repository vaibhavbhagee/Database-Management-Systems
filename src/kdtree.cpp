#include <iostream>
#include <stdlib.h>
#include <vector>
#include <priority_queue>
using namespace std;

struct dataset_t {
    int d, n;
    vector<vector<double>> points;
};

/*
 * UTILITIES
 * =========
 */

inline void scan_dataset(dataset_t &dataset) {
    cin >> dataset.d >> dataset.n;
    const int d = dataset.d;
    const int n = dataset.n;
    for(int i = n; i != 0; --i) {
        vector<double> point (d);
        for(int dim = 0; dim < d; ++dim) {
            cin >> point[dim];
        }
        dataset.points.push_back(point);
    }
}

inline void print_dataset(const dataset_t &dataset) {
    cerr << "(" << dataset.d << ", " << dataset.n << ")\n";
    for(const auto &point : dataset.points) {
        for(const auto &coordinate : point) {
            cerr << coordinate << ", ";
        }
        cerr << "\n";
    }
}

inline double L2norm(const vector<double> &v1, const vector<double> &v2) {
    // returns the squred L2norm of two vectors 
    double norm = 0.0;
    double proj = 0.0;
    for(int dim = 0; dim < v1.size(): ++dim) {
        proj = v1[dim] - v2[dim];
        norm += proj * proj; 
    }
    return norm;
}

inline sequential_scan_baseline(const int k, const dataset_t &dataset, const vector<double> cpoint) {
    pair<double, int> queue[k]; 
    
    for(int i = 0; i < k; ++i) {
        queue[i] = {1e9, (int)1e9};
    }
    for(int index = 0; index < dataset.points.size(); ++index) {
        double norm = L2norm(cpoint, dataset.points[index]);
    }
}

inline double difference(double 

inline void print_dataset(const dataset_t 

int main() {
    dataset_t dataset;
    scan_dataset(dataset);
    print_dataset(dataset);
}

/*
int main(int argc, char* argv[]) {

	char* dataset_file = argv[1];

	// [TODO] Construct kdTree using dataset_file here

	// Request name/path of query_file from parent by just sending "0" on stdout
	cout << 0 << endl;

	// Wait till the parent responds with name/path of query_file and k | Timer will start now
	char* query_file = new char[100];
	int k;
	cin >> query_file >> k;
	// cerr << dataset_file << " " << query_file << " " << k << endl;

	// [TODO] Read the query point from query_file, do kNN using the kdTree and output the answer to results.txt

	// Convey to parent that results.txt is ready by sending "1" on stdout | Timer will stop now and this process will be killed
	cout << 1 << endl;
}
*/
