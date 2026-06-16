# Adelophryne-Niche-Models
Occurrence records, environmental predictors, and R scripts used for ecological niche modeling of Adelophryne nordestina and Adelophryne baturitensis under past, present, and future climate scenarios.


# Ecological Niche Modeling of *Adelophryne nordestina* and *Adelophryne baturitensis*

## Overview

This repository contains occurrence data, environmental variables, and R scripts used to model the current, past, and future potential distributions of the endemic Brazilian frogs *Adelophryne nordestina* and *Adelophryne baturitensis*.

The analyses were conducted using Ensemble of Small Models (ESM) implemented in R through the packages **ecospat**, **biomod2**, and associated spatial analysis tools.

## Associated manuscript

Sousa AR, Arruda MO, Araripe J, Ávila RW, Ceron K.

*From the past to the future: ecological niche modeling of the endemic frogs Adelophryne nordestina and Adelophryne baturitensis in Northeastern Brazil.*

Submitted to The Herpetological Journal.

## Repository structure

```text
├── data/
│   ├── occurrences/
│   ├── environmental_layers/
│   └── metadata/
│
├── scripts/
│   ├── 01_data_preparation.R
│   ├── 02_variable_selection.R
│   ├── 03_ESM_calibration.R
│   ├── 04_current_projection.R
│   ├── 05_future_projection.R
│   └── 06_past_projection.R
│
├── outputs/
│   ├── suitability_maps/
│   ├── binary_maps/
│   └── evaluation_metrics/
│
└── README.md
```

## Environmental variables

Environmental predictors were obtained from WorldClim v2.1 and included:

* BIO7 – Temperature Annual Range
* BIO13 – Precipitation of Wettest Month
* BIO18 – Precipitation of Warmest Quarter
* BIO19 – Precipitation of Coldest Quarter
* Elevation

Variables were selected after removing collinear predictors using Variance Inflation Factor (VIF).

## Modeling procedure

1. Spatial thinning of occurrence records.
2. Extraction of environmental variables.
3. Removal of collinear predictors.
4. Calibration of Ensemble of Small Models (ESM).
5. Model evaluation using TSS and Somers' D.
6. Projection to:

   * Current climate
   * Last Interglacial (LIG)
   * Mid-Holocene (MID)
   * Last Glacial Maximum (LGM)
   * Future SSP scenarios

## Software

Analyses were performed in R (version 4.x).

Main packages:

* biomod2
* ecospat
* terra
* raster
* geodata
* spThin
* usdm

## Data availability

All occurrence data, scripts, and supplementary material associated with the manuscript are available in this repository.

## Contact

Átilas Rodrigues de Sousa
atilasrodrigues28@alu.ufc.br
Federal University of Ceará (UFC)

