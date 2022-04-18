#!/usr/bin/env make -f

# Short names for data and url
EXTERNAL=data/external
INTERNAL=data/internal

WC=$(EXTERNAL)/worldclim
NE=$(EXTERNAL)/natural-earth
GBIF=$(EXTERNAL)/GBIF
GRASS=$(INTERNAL)/grassdata
MAPSET=$(GRASS)/WGS_84/FFI

WC_URL=https://biogeo.ucdavis.edu/data/worldclim/v2.1/base
NE_URL=https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m
GBIF_URL=https://api.gbif.org/v1/occurrence/download/request/0224635-210914110416597.zip

all: setup download process model visualise

# Summaries

short-summary:
	# 1. Setup project
	# 2. Download base data
	# 3. Process data
	# 4. Fit and use model
	# 5. Visualise model results

summary:
	# 1. Setup project
		## 1.1 Create projects folders and make scripts executable
		## 1.2 Install Linux Mint 20.3 packages
		## 1.3 Setup GRASS GIS base, WGS 84, location and mapset
	# 2. Download base data
		## 2.1 Download worldclim data
		## 2.2 Download 'Natural Earth' data
		## 2.3 Download ocurrence data from GBIF
	# 3. Process data
		## 3.1 Select eBird occurence data
		## 3.2 Import raster, vector and csv into GRASS GIS
		## 3.3 Define project area
		## 3.4 Convert occurence data to raster
	# 4. Fit and use model
		## 4.1 Fit and use MAXDM similarity-based models (GMS, KNNS)
	# 5. Visualise model results
		## 5.1 Generate GRASS GIS map


# 1. Setup project
setup: setup-folders setup-packages setup-grass


setup-folders: setup-scripts
	## [TASK] 1.1 Create projects folders and make scripts executable
	mkdir -p $(GRASS)
	
setup-scripts:
	chmod +x scripts/*

setup-packages:
	## [TASK] 1.2 Install Linux Mint 20.3 packages
	sudo apt -q update
	sudo apt -q install grass \
		python3 python3-pandas python3-sklearn python3-xarray \
		bash wget gawk

setup-grass:
	## [TASK] 1.3 Setup GRASS GIS base, WGS 84, location and mapset
	grass -e -c EPSG:4326 $(GRASS)/WGS_84
	grass $(GRASS)/WGS_84/PERMANENT --exec g.mapset -c mapset=FFI

# 2. Download base data
download: worldclim natural-earth gbif-occ


worldclim: \
		$(WC)/wc2.1_2.5m_bio.zip \
		$(WC)/wc2.1_2.5m_elev.zip

$(WC)/wc2.1_%.zip:
	## [TASK] 2.1 Download worldclim data
	./scripts/download.sh $@ $(WC_URL)/$(notdir $@)

natural-earth: $(NE)/ne_10m_admin_1_states_provinces.zip

$(NE)/ne_10m_admin_1_states_provinces.zip:
	## [TASK] 2.2 Download 'Natural Earth' data
	./scripts/download.sh $@ $(NE_URL)/cultural/ne_10m_admin_1_states_provinces.zip


gbif-occ: $(GBIF)/occ_megaxenops_parnaguae.csv

$(GBIF)/occ_megaxenops_parnaguae.csv: $(GBIF)/0224635-210914110416597.zip
$(GBIF)/0224635-210914110416597.zip:
	## [TASK] 2.3 Download ocurrence data from GBIF
	./scripts/download.sh $@ $(GBIF_URL)
	mv $(GBIF)/0224635-210914110416597.csv $(GBIF)/occ_megaxenops_parnaguae.csv


# 3. Process data
process: select-gbif-occ grass-process


select-gbif-occ: $(INTERNAL)/occ_megaxenops_parnaguae_selected.csv

$(INTERNAL)/occ_megaxenops_parnaguae_selected.csv: $(GBIF)/occ_megaxenops_parnaguae.csv
	## [TASK] 3.1 Select eBird occurence data
	@echo $^
	awk -F '\t' 'NR == 1 || $$38 == "EBIRD"' $^ > $@

grass-process:\
		grass-select-mapset \
		grass-import \
		grass-define-area \
		grass-convert-gbif-occ

grass-select-mapset:
	grass $(MAPSET) --exec true

grass-import:\
		grass-import-print \
		grass-import-worldclim \
		grass-import-natural-earth \
		grass-import-gbif-occ

grass-import-print:
	## [TASK] 3.2 Import raster, vector and csv into GRASS GIS

grass-import-worldclim: worldclim \
		$(WC)/wc2.1_2.5m_bio_1.tif \
		$(WC)/wc2.1_2.5m_bio_2.tif \
		$(WC)/wc2.1_2.5m_bio_3.tif \
		$(WC)/wc2.1_2.5m_bio_4.tif \
		$(WC)/wc2.1_2.5m_bio_5.tif \
		$(WC)/wc2.1_2.5m_bio_6.tif \
		$(WC)/wc2.1_2.5m_bio_7.tif \
		$(WC)/wc2.1_2.5m_bio_8.tif \
		$(WC)/wc2.1_2.5m_bio_9.tif \
		$(WC)/wc2.1_2.5m_bio_10.tif \
		$(WC)/wc2.1_2.5m_bio_11.tif \
		$(WC)/wc2.1_2.5m_bio_12.tif \
		$(WC)/wc2.1_2.5m_bio_13.tif \
		$(WC)/wc2.1_2.5m_bio_14.tif \
		$(WC)/wc2.1_2.5m_bio_15.tif \
		$(WC)/wc2.1_2.5m_bio_16.tif \
		$(WC)/wc2.1_2.5m_bio_17.tif \
		$(WC)/wc2.1_2.5m_bio_18.tif \
		$(WC)/wc2.1_2.5m_bio_19.tif \
		$(WC)/wc2.1_2.5m_elev.tif
	grass --exec bash scripts/grass_import_worldclim.sh $^

grass-import-natural-earth: natural-earth \
		$(NE)/ne_10m_admin_1_states_provinces.shp
	grass --exec bash scripts/grass_import_natural_earth.sh $^

grass-import-gbif-occ: select-gbif-occ \
		$(INTERNAL)/occ_megaxenops_parnaguae_selected.csv
	grass --exec bash scripts/grass_import_gbif_occ.sh $^


grass-define-area:
	## [TASK] 3.3 Define project area
	grass --exec bash scripts/grass_define_area.sh


grass-convert-gbif-occ:
	## [TASK] 3.4 Convert occurence data to raster
	grass --exec bash scripts/grass_convert_gbif_occ.sh


# 4. Fit and use model
model: sdm


sdm:
	## [TASK] 4.1 Fit MAXDM similarity-based models (GMS, KNNS)
	grass --exec python3 scripts/sdm.py


## 5. Visualise model results
visualise: grass-map
	
	
grass-map:
	## [TASK] 5.1 Generate GRASS GIS map
	grass --exec bash scripts/grass_map.sh


# Helpers

clean:
	rm -R data/

clean-grass:
	rm -R data/internal/grassdata

backup:
	mv data/ data_bak/
