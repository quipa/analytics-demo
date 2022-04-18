#!/usr/bin/env bash

# Import GBIF csv ocurrence data

g.mapset mapset=FFI

for data in "${@:2}"
do
    name=$(basename -s .csv $data)
    # TODO specify column names/types
    # To view column names use 'v.info -h'
    v.in.ascii --overwrite input=$data output=$name separator=tab skip=1 y=22 x=23
    
    # OLD
    # Add presence column, this will be used for raster conversion
    # v.db.addcolumn map=$name columns="presence int"
    # v.db.update map=$name column=presence value=1   
done
