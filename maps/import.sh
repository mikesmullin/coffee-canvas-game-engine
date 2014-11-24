#!/usr/bin/env bash

rm -rf ../src/public/models/$1/
mkdir -p ../src/public/models/$1/
./collada2gltf -d -f $1.dae -o ../src/public/models/$1/$1
