#!/usr/bin/env bash

# Import worldclim variables into GRASS GIS

g.mapset mapset=FFI

for data in "${@:2}"
do
    name=$(basename -s .tif $data | cut -c 12-)
    r.import --overwrite input=$data output=$name
done
