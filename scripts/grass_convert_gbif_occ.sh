#!/usr/bin/env bash

# Convert GBIF ocurrence data to raster

g.mapset mapset=FFI

input=occ_megaxenops_parnaguae_selected

v.to.rast --overwrite $input output=occ use=val
