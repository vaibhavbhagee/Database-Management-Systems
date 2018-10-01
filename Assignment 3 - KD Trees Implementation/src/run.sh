#!/bin/bash
make compile
./a.out $1
cat results.txt
make clean
