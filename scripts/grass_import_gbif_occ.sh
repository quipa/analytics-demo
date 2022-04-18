#!/usr/bin/env bash

# Import GBIF csv ocurrence data

g.mapset mapset=FFI

for data in "${@:2}"
do
    name=$(basename -s .csv $data)
    # TODO specify column names/types
    # To view column names use 'v.info -h'
    v.in.ascii --overwrite input=$data output=$name separator=tab skip=1 y=22 x=23
    
done
