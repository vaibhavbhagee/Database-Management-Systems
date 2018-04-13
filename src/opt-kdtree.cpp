//
//  main.cpp
//  kd-tree2
//
//  Created by Praveen P Kulkarni on 13/04/18.
//  Copyright © 2018 Praveen P Kulkarni. All rights reserved.
//
#include <algorithm>
#include <fstream>
#include <iostream>
#include <numeric>
#include <queue>
#include <vector>
#include <cassert>
using namespace std;

const string BASE_DIR = "/Users/Praveen/Desktop/Praveen/iitd/semester8/dbms/assignments/durant/";
const string QUERY_FILE = BASE_DIR + "datasets/query2.txt";
const string DATA_FILE = BASE_DIR + "datasets/dataset.n.10000.d.3.txt";

struct stacknode_t {
    vector<int> index;
    int depth;
    int parent;
    bool leftchild;
};

struct treenode_t {
    vector<vector<double>> points;
    vector<int> index;
    vector<pair<double, double>> left_hrect;
    vector<pair<double, double>> right_hrect;
    int leftnode;
    int rightnode;
};

int ndim;
int ndata;

// read the uniformly distributed points from a file
void read_points(vector<vector<double>> &points, const string filename) {
    ifstream fin(filename);
    fin >> ndim >> ndata;
    points.clear();
    points.resize(ndata, vector<double>(ndim, 0));
    for(int i = 0; i < ndata; ++i) {
        for(int j = 0; j < ndim; ++j) {
            fin >> points[i][j];
        }
    }
    fin.close();
}

// calculate the squared-L2 distance between two points
inline double square_dist(const vector<double> &pt1, const vector<double> &pt2) {
    double answer = 0;
    for(int i = 0; i < ndim; ++i) {
        double diff = pt1[i] - pt2[i];
        answer += diff * diff;
    }
    return answer;
}

// read the query file consisting of a single point
void read_query_file(vector<double> &querypoint, const string query_file) {
    querypoint.clear();
    querypoint.resize(ndim, 0);
    ifstream fin(query_file);
    int d; fin >> d;
    for(int i = 0; i < ndim; ++i) {
        fin >> querypoint[i];
    }
    fin.close();
}

inline void write_knn(const vector<vector<double>> &points,
                      priority_queue<pair<double, int>> &q) {
    ofstream fout("results.txt");
    vector<int> order;
    while(not q.empty()) {
        order.push_back(q.top().second);
        q.pop();
    }
    for(int i = (int)order.size() - 1; i >= 0; --i) {
        int index = order[i];
        for(double elem: points[index]) {
            fout << elem << " ";
        }
        fout << "\n";
    }
}

// perform sequential scan to find the knn
inline void sequential_scan(priority_queue<pair<double, int>> &q,
                            const vector<vector<double>> &points,
                            const vector<double> &point,
                            const int k) {
    for(int i = 0; i < ndata; ++i) {
        double dst = square_dist(points[i], point);
        q.push({dst, i});
        if(q.size() > (unsigned int)k) {
            q.pop();
        }
    }
}

inline bool compare_lexi(const vector<double> &v1,
                         const vector<double> &v2) {
    for(int i = 0; i < ndim; ++i) {
        if(v1[i] < v2[i]) return true;
        if(v1[i] > v2[i]) return false;
    }
    return false;
}


void kdtree(vector<treenode_t> &tree, const vector<vector<double>> &points, const int LEAF_SIZE = 7) {
    tree.clear();
    vector<stacknode_t> stack;
    vector<pair<double, double>> hrect(ndim, {0, 1});
    for(const auto &pt: points) {
        for(int dim = 0; dim < ndim; ++dim) {
            hrect[dim].first = min(hrect[dim].first, pt[dim]);
            hrect[dim].second = max(hrect[dim].second, pt[dim]);
        }
    }
    // Assume that they are already lexicographically sorted.
    int sort_dim = 0;
    const double split_value = points[ndata / 2][sort_dim];
    
    // left_hrect, right_hrect
    vector<pair<double, double>> left_hrect(hrect);
    vector<pair<double, double>> right_hrect(hrect);
    left_hrect[sort_dim].second = split_value;
    right_hrect[sort_dim].first = split_value;
    assert(left_hrect.size() == ndim);
    assert(right_hrect.size() == ndim);

    // left and right indexes
    vector<int> left_index(ndata / 2);
    vector<int> right_index(ndata - (ndata/2));
    iota(left_index.begin(), left_index.end(), 0);
    iota(right_index.begin(), right_index.end(), ndata/2);
    
    // dfs step: append to stack and tree
    stack.push_back({left_index, 1, 0, true});
    stack.push_back({right_index, 1, 0, false});
    
    // create root node
    tree.push_back({vector<vector<double>> (), vector<int>(), left_hrect, right_hrect, -1, -1});
    
    while(stack.size() > 0) {
        vector<int> index = stack.back().index;
        const int depth = stack.back().depth;
        const int parent = stack.back().parent;
        const int leftchild = stack.back().leftchild;
        const int ndata = (int)(index.size());
        stack.pop_back();

        // append this child to the parent node in the tree
        (leftchild ? tree[parent].leftnode : tree[parent].rightnode) = (int)(tree.size());
        
        // if there are less number of points then make it a leaf node.
        // leaf nodes store the points locally for faster lookup.
        if(ndata < LEAF_SIZE) {
            vector<vector<double>> cpoints;
            for(int pt_idx: index) {
                cpoints.push_back(points[pt_idx]);
            }
            tree.push_back({
                cpoints,                            // points
                index,                              // index
                vector<pair<double, double>> (),    // l_hrect is empty
                vector<pair<double, double>> (),    // r_hrect is empty
                -1,                                 // leftnode doesn't exist
                -1                                  // rightnode doesn't exist
            });
        } else {
            // if there are many points, then you have an internal node
            // internal nodes will NOT store the points
            // just choose a dimension, sort the indexes, and then just go on
            const int splitdim = depth % ndim;
            sort(index.begin(),
                 index.end(),
                 [splitdim, points](const int idx1, const int idx2) {
                     return points[idx1][splitdim] < points[idx2][splitdim];
                 }
            );
            const vector<int> left_index(index.begin(), index.begin() + (ndata/2));
            const vector<int> right_index(index.begin() + (ndata/2), index.end());

            stack.push_back({left_index, depth+1, (int)tree.size(), true});
            stack.push_back({right_index, depth+1, (int)tree.size(), false});
            const double split_value = points[index[ndata / 2]][splitdim];
            
            // update the bounding hyper-rectangles for the children
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

            // internal nodes don't have indices or children.
            // they only keep track of the children's bounding boxes.
            assert(left_hrect.size() == ndim);
            assert(right_hrect.size() == ndim);
            tree.push_back({
                vector<vector<double>> (),
                vector<int> (),
                left_hrect,
                right_hrect,
                -1,
                -1
            });
        }
    }
}

inline void quadratic_knn_search(priority_queue<pair<double, int>> &knn,
                                 const vector<double> &querypoint,
                                 const vector<vector<double>> &points,
                                 const vector<int> &index,
                                 const int k) {
    const int ndata = (int)points.size();
    for(int i = 0; i < ndata; ++i) {
        knn.push({square_dist(querypoint, points[i]), index[i]});
        if(knn.size() > k) {
            knn.pop();
        }
    }
}

inline bool intersect(const double r2,
                      const vector<pair<double, double>> &hrect,
                    const vector<double> &centroid) {
    assert(ndim == centroid.size());
    assert(ndim == hrect.size());
    double dist2 = 0.0;
    for(int idx = 0; idx < ndim; ++idx) {
        const double diff1 = hrect[idx].first - centroid[idx];
        const double diff2 = centroid[idx] - hrect[idx].second;
        const double diff = max(0.0, max(diff1, diff2));
        dist2 += diff * diff;
    }
    return (dist2 < r2);
}

// recursive function to search inside the kd-tree.
void rec_search_kdtree(const vector<treenode_t> &tree,
                       const treenode_t &tnode,
                       const vector<double> &querypoint,
                       priority_queue<pair<double, int>> &knn,
                       const int k) {
    assert(knn.size() <= k);
    if(not tnode.points.empty()) {
        quadratic_knn_search(knn, querypoint, tnode.points, tnode.index, k);
        return;
    }
    const double dist = knn.empty() ? 1e9 : knn.top().first;
    if(intersect(dist, tnode.left_hrect, querypoint)) {
        rec_search_kdtree(tree, tree[tnode.leftnode], querypoint, knn, k);
    }
    const double dist1 = knn.empty() ? 1e9 : knn.top().first;
    if(intersect(dist1, tnode.right_hrect, querypoint)) {
        rec_search_kdtree(tree, tree[tnode.rightnode], querypoint, knn, k);
    }
    assert(knn.size() <= k);
}

int main(int argc, char *argv[]) {
    // control variables
    bool use_kdtree = false;
    
    // init variables
    int k;
    vector<vector<double>> points;
    vector<double> query_point;
    string query_file;
    vector<treenode_t> tree;
    priority_queue<pair<double, int>> knn;
    string dataset_file = (string)(argv[1]);
    // read dataset and then flush 0 to STDOUT
    clock_t time_start = clock();
        read_points(points, dataset_file);
        sort(points.begin(), points.end(), compare_lexi);
        kdtree(tree, points);
    clock_t time_end = clock();
    cerr << "time  = " << double(time_end - time_start) / CLOCKS_PER_SEC << endl;
    cout << 0 << endl;

    // read the queryfile from STDIN
    cin >> query_file >> k;
    read_query_file(query_point, query_file);
    
    // perform the knn-search
    if(use_kdtree) {
        rec_search_kdtree(tree, tree[0], query_point, knn, k);
    } else {
        sequential_scan(knn, points, query_point, k);
    }
    
    write_knn(points, knn);
    
    // write 1 to STDOUT
    cout << 1 << endl;
}
