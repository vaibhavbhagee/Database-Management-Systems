#include <algorithm>
#include <fstream>
#include <iostream>
#include <queue>
#include <vector>
using namespace std;

const int LEAF_SIZE = 10;

struct dataset_t { int n;
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
            cerr << dataset.points[i][j] << " ";
        }
        cerr << "\n";
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

bool compare(const vector<double> &v1, const vector<double> &v2) {
    const int d = v1.size();
    for(int i = 0; i < d; ++i) {
        if(v1[i] < v2[i]) return true;
        if(v1[i] > v2[i]) return false;
    }
    return false;
}


bool intersect(
        const double r2,
        const vector<pair<double, double>> &hrect, 
        const vector<double> &centroid) {
    const int d = hrect.size();
    double dist2 = 0.0;
    for(int idx = 0; idx < d; ++idx) {
        double diff1 = hrect[idx].first - centroid[idx];
        double diff2 = centroid[idx] - hrect[idx].second;
        if(diff1 >= 0) {
            dist2 += diff1 * diff1;
        } else if (diff2 >= 0) {
            dist2 += diff2 * diff2;
        }
    }
    return (dist2 < r2);
}

struct stacknode_t {
    vector<vector<double>> points;
    int depth;
    int parent;
    bool leftchild;
};

struct treenode_t {
    vector<vector<double>> points;
    vector<pair<double, double>> left_hrect;
    vector<pair<double, double>> right_hrect;
    int leftnode;
    int rightnode;
};

void kdtree(vector<treenode_t> &tree, vector<vector<double>> &points) {
    tree.clear();
    vector<stacknode_t> stack;
    const int ndata = points.size();
    const int ndim = points[0].size();
    vector<pair<double, double>> hrect(ndim, {0, 1});
    for(const auto &pt: points) {
        for(int dim = 0; dim < ndim; ++dim) {
            hrect[dim].first = min(hrect[dim].first, pt[dim]);
            hrect[dim].second = max(hrect[dim].second, pt[dim]);
        }
    }
    int sort_dim = 0;
    sort(points.begin(),
         points.end(),
         [sort_dim](const vector<double> &v1, const vector<double> &v2) {
            return v1[sort_dim] < v2[sort_dim];
    });
    const double split_value = points[ndata / 2][sort_dim];
    
    vector<pair<double, double>> left_hrect(hrect); 
    vector<pair<double, double>> right_hrect(hrect);
    left_hrect[sort_dim].second = split_value;
    right_hrect[sort_dim].first = split_value;

    vector<vector<double>> left_points, right_points;
    for(int pt_idx = 0; pt_idx < ndata; ++pt_idx) {
        if(pt_idx * 2 < ndata) {
            left_points.push_back(points[pt_idx]);
        } else {
            right_points.push_back(points[pt_idx]);
        }
    }
    stack.push_back({left_points, 1, 0, true}); 
    stack.push_back({right_points, 1, 0, false});

    while(stack.size() > 0) {
        int nodeptr = tree.size();
        auto cpoints = stack.back().points;
        const int depth = stack.back().depth;
        const int parent = stack.back().parent;
        const int leftchild = stack.back().leftchild;
        const int ndata = cpoints.size();
        stack.pop_back();

        (leftchild ? tree[parent].leftnode : tree[parent].rightnode) = nodeptr;

        if(ndata < LEAF_SIZE) {
            // if it is a leaf then
            tree.push_back({
                cpoints,                            // points
                vector<pair<double, double>> (),    // lrect is empty
                vector<pair<double, double>> (),    // rrect is empty
                -1,                                 // leftnode doesn't exist
                -1});                               // rightnode doesn't exist
        } else {
            const int splitdim = depth % ndim;
            sort(
                cpoints.begin(),
                cpoints.end(), 
                [splitdim](const vector<double> &v1, const vector<double> &v2) {
                    return v1[splitdim] < v2[splitdim];
                }
            );
            vector<vector<double>> left_points, right_points;
            for(int pt_idx = 0; pt_idx < ndata; ++pt_idx) {
                if(pt_idx * 2 < ndata) {
                    left_points.push_back(cpoints[pt_idx]);
                } else {
                    right_points.push_back(cpoints[pt_idx]);
                }
            }
            stack.push_back({left_points, depth+1, nodeptr, true}); 
            stack.push_back({right_points, depth+1, nodeptr, false});
            const double split_value = cpoints[ndata / 2][splitdim];
            vector<pair<double, double>> left_hrect, right_hrect;
            if(leftchild) {
                left_hrect = tree[parent].left_hrect;
                right_hrect = tree[parent].left_hrect;
            } else {
                left_hrect = tree[parent].right_hrect;
                right_hrect = tree[parent].right_hrect;
            }
            left_hrect[splitdim].second = split_value;
            right_hrect[splitdim].first = split_value;
            tree.push_back({
                vector<vector<double>> (),
                left_hrect,
                right_hrect,
                -1,
                -1
            });
        }
    }
}


int main(int argc, char *argv[]) {
    int k;
    dataset_t dataset;
    vector<double> query_point;
    string query_file;

    // read dataset and then flush 0 to STDOUT
    string dataset_file = argv[1];
    read_dataset(dataset, dataset_file);
    sort(dataset.points.begin(), dataset.points.end(), compare);

    vector<treenode_t> tree;
    kdtree(tree, dataset.points);
    // print_dataset(dataset);
    cout << 0 << endl;

    // read queryfile name and k
    cin >> query_file >> k;
    read_query_file(query_point, query_file);

    // write the results to results.txt and flush 1
    sequential_scan(dataset, query_point, k);
    cout << 1 << endl;
}
