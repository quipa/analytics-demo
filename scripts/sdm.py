#!/usr/bin/env python3

"""MAXDM species distribution models for 'Megaxenops paranaguae'

Fits MAXDM Geometric Median Similarity (GMS) and K Nearest Neighbour Similarity models to 'Megaxenops paranaguae' ocurrences using worldclim data for project area.

GMS is similar to BIOCLIM, but uses geometric median.
KNNS is similar to DOMAIN when k = 1.
"""
# TODO separate/refactor garray/xarray load and write code

import grass.script as gscript
from grass.script import array as garray
import pandas as pd
import xarray as xr

from tools import maxdm

gscript.run_command("g.mapset", mapset="FFI")

# Create xarray.Dataset from project raster maps
maps = [f'bio_{i}' for i in range(1, 20)] + ['elev', 'occ']
dims = ('x','y')

ds = xr.Dataset({m: (dims, garray.array(mapname=m)) for m in maps})

# Convert to format compatible with estimators
df = ds.to_dataframe()
df_var = df.drop(columns=['occ'])   # variables dataframe
df_occ = df['occ']                  # occurences dataframe


# GMS - Geometric Median Similarity

## Fit GMS model
gms = maxdm.GMS()
gms.fit(df_var, df_occ)

## Predict species distribution with GMS model
df_gms = gms.predict(df_var)

## Convert back to write into GRASS GIS
ds_gms = xr.Dataset.from_dataframe(df_gms)
ga_gms = garray.array()
ga_gms[:,:] = ds_gms.sim
ga_gms.write(mapname='gms_l1', overwrite=True)


# KNNS - K Nearest Neighbour Similarity

## Fit k  model
k = 1
knns = maxdm.KNNS(k=k)
knns.fit(df_var, df_occ)

## Predict species distribution with KNNS model
df_knns = knns.predict(df_var)

## Convert back to write into GRASS GIS
ds_knns = xr.Dataset.from_dataframe(df_knns)
ga_knns = garray.array()
ga_knns[:,:] = ds_knns.sim
ga_knns.write(mapname=f'knns_l1_{k}', overwrite=True)


