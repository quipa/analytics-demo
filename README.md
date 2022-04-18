<style>
img[src~="thumbnail"] {
   width:200px;
   height:200px;
}
img[src~="bordered"] {
   border: 1px solid black;
}
</style>


# analytics-demo
Maxim Jaffe's geospatial analytics demonstration 


## Introduction

This project showscases my data geospatial analytic skils with a case study species.

The case study is the great xenops *Megaxenops parnaguae* a typical furnariid bird of the Brazilian Caatinga ([Wikipedia](https://en.wikipedia.org/wiki/Great_xenops), [BirdLife Factsheet](http://datazone.birdlife.org/species/factsheet/great-xenops-megaxenops-parnaguae)).

![*Megaxenops parnaguae*](https://upload.wikimedia.org/wikipedia/commons/thumb/4/45/Great_Xenops_Megaxenops_parnaguae.jpg/320px-Great_Xenops_Megaxenops_parnaguae.jpg)

Source: Wikipedia

The project creates a Species Distribution Model (SDM) for the case study species. It uses a prototype tool <a name='maxdm'></a>[MAXDM](/scripts/tools/maxdm.py) (**Max**im's Species **D**istribution **M**odels) specifically coded for this demonstration.

*MAXDM* SDMs predict patterns based on environmental variable similarity to occurence sites. It implements a geometric median similarity (GMS) and a k nearest neighbours similarity (KNNS) method.

These similarity methods are applicable to presence-only data and are relatively straightforward to calculate and reason about.

Example of map for a technical report:
![Megaxenops parnaguae SDM](maps/gms_map.png# thumbnail bordered)


To better understand the author's choices see [justifications](#justifications).


## Tasks

Here is a brief summary of the involved tasks and tools:

  1. Setup project: folders, scripts, packages, GRASS GIS; `Makefile`
  2. Download base data: [WorldClim](#worldclim), ['Natural Earth'](#natural-earth), [GBIF](#gbif))
  3. Process data: bash and GRASS GIS
  4. Fit and apply model: python ([MAXDM](#maxdm)) and GRASS GIS
  5. Visualise model results: GRASS GIS map (png)


## Setup

Current setup is defined for Linux Mint 20.3.

In project root run `make` in command-line. For specific tasks run:

1. `make setup`
2. `make download`
3. `make process`
4. `make model`
5. `make visualise`

To list subtasks `make summary`, for further details read [`Makefile`](Makefile).

Look in [`scripts`](scripts/) folder for specific bash or python scripts, these have similar names to those defined in the `Makefile`.

External data is downloaded into `data/external` folder. Internal data is stored in `data/internal` folder, including GRASS GIS data.

Generated maps are saved into [`maps`](maps/) folder.

Most scripts are in bash as it integrates well with GRASS GIS. Python is used for complex components.

### Dependencies
  * GRASS GIS 7.8
  * python 3.8
  * pandas 0.25
  * xarray 0.16
  * scikit-learn 0.22
  * bash 5.0
  * wget 1.20
  * gawk 1:5.0.1

### Porting

Porting to other operating systems should be possible:

* Linux distributions:
  * Adapt `setup-packages` in `Makefile` to use OS package manager (`apt`, `yum`, etc.)
* Mac OS:
  * Adapt `setup-packages` in `Makefile` to use [MacPorts](https://www.macports.org/) or other ports/package manager
* Windows:
  * install POSIX compliant subsystem/runtime ([WSL](https://docs.microsoft.com/en-us/windows/wsl/install), [cygwin](https://cygwin.com/))
  * adapt `setup-packages` in `Makefile` to use subsystem package manager


<a name='justifications'></a>
## Project justification

### Species choice
I choose the great xenops as I have a great interest in the Caatinga seasonally dry tropical forest and ornithology. This species is interesting as it is closely associated with both dense Caatinga, while tolerating degraded Caatinga. It is also an iconic Caatinga species.

### Data choice
I choose data sources that have worldwide application to demonstrate how the project could be adapted for other target species/taxa. Worldclim 2.5 minutes data was selected as compromise between resolution and download time.

### Geospatial analysis framework
This project predominantly uses GRASS GIS, the Python ecosystem, `bash`, `make` and other Linux/UNIX commands (e.g. wget, awk) for geospatial analysis.

### GRASS GIS
GRASS GIS is particularly apt for dealing with raster data which is common in SDMs. It has good integration with with python and bash, which makes it particularly suited for automated and reproducible data analysis.

It also provides a good user interface that is useful for interactive data analysis, for protyping batch analysis, and for veryfying batch analysis results

GRASS GIS provides a more robust, homogenous, and well integrated geospatial analysis experience when compared to using exclusively python ecosystem packages (e.g. fiona, geopandas, rasterio, xarray, cartopy, etc.). A similar argument can be made for R. Nevertheless it can integrate well with 

GRASS GIS is also open source, which makes it particularly well suited for used in resource-constrained environments (conservation projects in the Global South)

### Python
Python is particularly useful due to the following packages:
  * numerical computation (numpy, scipy, xarray)
  * data processing (pandas, numpy)
  * machine learning and statistical modelling (scikit-learn, etc.)

### make
A make is a useful tool for organise data analysis pipelines as it allows to define different task and data dependencies using a `Makefile`.

This is more flexible then a 'task' script since specific tasks can easily run. When dependencies are met (downloaded data files) this also avoids repeating work.

### Other unix tools
* wget: easy to use tool for downloading data
* [awk](https://en.wikipedia.org/wiki/AWK): useful language for text/csv processing

<a name='maxdm-justification'></a>
### MAXDM protoype
I prototyped [MAXDM](#maxdm) to demonstrate my ability to develop tools/models, in this case using a flexible package ([scikit-learn](https://scikit-learn.org/)) with *off-the-shelf* components. This similarity/distance based approach was selected as it could be implemented in a short period of time (2-3 days).

Note that in previous positions I have worked heavily with these types of modelling techniques / tools:

* Generalised Linear Models (GLMs) based on abundance monitoring data (using [`statsmodels`](https://www.statsmodels.org/) and `scikit-learn`.
* Hybrid ecological models linking GLMs to land use / land cover dynamic models agent-based / system dynamics models (using [NetLogo](https://en.wikipedia.org/wiki/NetLogo) and [Stella](https://en.wikipedia.org/wiki/STELLA_(programming_language)))

<!--- 
### Package manager
*TODO* write about conda
-->


## Data sources

* [GBIF](#gbif) 
  * *Megaxenops parnaguae* Reiser, 1905 occurences with coordinates (presence-only)
* <a name="worldclim"></a>[WorldCLim](https://www.worldclim.org/data/worldclim21.html) 2.1 historical climate data 2.5 minutes resolution
  * Bioclimatic variables
  * Elevation
* <a name="natural-earth"></a>[Natural Earth](https://www.naturalearthdata.com/) 1:10m
  * Cultural Vectors: Admin 1 – States, Provinces

![ Made with Natural Earth.](https://www.naturalearthdata.com/wp-content/uploads/2009/08/NEV-Logo-Black.png)


## References
* <a name="gbif"></a> GBIF.org (15 April 2022) GBIF Occurrence Download  https://doi.org/10.15468/dl.mcet5w
* Fick, S.E. and R.J. Hijmans, 2017. WorldClim 2: new 1km spatial resolution climate surfaces for global land areas. International Journal of Climatology 37 (12): 4302-4315. 
