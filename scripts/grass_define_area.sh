#!/usr/bin/env bash

# Define project area

## Set FFI mapset
g.mapset mapset=FFI

## Create project area (based on BirdLife 

selection="
(iso_3166_2 = 'BR-PI') OR
(iso_3166_2 = 'BR-CE') OR
(iso_3166_2 = 'BR-RN') OR
(iso_3166_2 = 'BR-PB') OR
(iso_3166_2 = 'BR-PE') OR
(iso_3166_2 = 'BR-AL') OR
(iso_3166_2 = 'BR-SE') OR
(iso_3166_2 = 'BR-BA') OR
(iso_3166_2 = 'BR-MG') OR
(iso_3166_2 = 'BR-GO') OR
(iso_3166_2 = 'BR-DF')"

v.extract --overwrite input=ne_10m_admin_1_states_provinces@FFI where="$selection" output=project_area@FFI

## Set region to project area with worldclim cell resolution and bounds
g.region --overwrite vector=project_area@FFI align=bio_1@FFI save=project_area      

## Mask raster data with project area
r.mask --overwrite vector=project_area@FFI                                        
