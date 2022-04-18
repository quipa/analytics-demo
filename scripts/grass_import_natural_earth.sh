#!/usr/bin/env bash

# Import 'Natural Earth' vectors into GRASS GIS

g.mapset mapset=FFI

for data in "${@:2}"
do
    name=$(basename -s .shp $data)
    v.import --overwrite input=$data output=$name
done
