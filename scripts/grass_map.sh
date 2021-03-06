#!/usr/bin/env bash

# Generate map for Geometric Median Similarity

TITLE="Species Distribution Model: Megaxenops parnaguae"
LEGEND_LABEL='Geometric Median Similarity'
FONT='Liberation Sans:Regular'

g.mapset mapset=FFI

# Setup GRASS region for mapping
g.region --overwrite n=-0 s=-25 e=-33 w=-55 align=bio_1 save=map_area
    
# Setup image output
d.mon cairo out=maps/gms_map.png width=800 height=800 --overwrite

# Remove all frames and erase monitor
d.frame -e

# Modify GMS model output colour table
r.colors -e map=gms_l1 color=blues # -e histogram equalisation

# Place title text
d.text text="$TITLE" at=50,95 \
    align=cc size=4.5 font="$FONT" color=black

# Place raster legend
d.legend raster=gms_l1 at=5,7,10,90 \
    range=0.75,1.0 \
    title="$LEGEND_LABEL" title_fontsize=25 fontsize=25 font="$FONT" \

# Setup map frame
d.frame -c frame=first at=15,90,10,90

# Add Brazilian state boundaries
d.vect map=ne_10m_admin_1_states_provinces

# Add GMS model output
d.rast --o map=gms_l1

# Add Brazilian states overlay (project area)
d.vect map=project_area fill_color=none

# Add map features (grid, north arrow)
d.grid -c size=10 fontsize=10 text_color=black
d.northarrow at=85,88

# Release monitor
d.mon -r

# Restore project area GRASS region
g.region region=project_area

