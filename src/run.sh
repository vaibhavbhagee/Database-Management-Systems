#!/bin/bash
make compile
./sscan.out $1
cat results.txt
make clean
