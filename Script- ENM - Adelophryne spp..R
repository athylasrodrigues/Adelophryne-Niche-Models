################################################################################

# ECOLOGICAL NICHE MODELING OF ADELOPHRYNE SPP.

# ENSEMBLE OF SMALL MODELS (ESM)

#

# ASSOCIATED MANUSCRIPT:

# FROM THE PAST TO THE FUTURE: ECOLOGICAL NICHE MODELING OF THE ENDEMIC FROGS

# ADELOPHRYNE NORDESTINA AND ADELOPHRYNE BATURITENSIS

################################################################################

############################

# LOAD REQUIRED PACKAGES

############################

library(biomod2)
library(ecospat)
library(terra)
library(raster)
library(spThin)
library(usdm)
library(geodata)

############################

# LOAD OCCURRENCE DATA

############################

occ <- read.csv("data/occurrences/adelophryne_baturitensis.csv")

species_name <- names(occ)[3]

summary(occ)

############################

# SPATIAL THINNING

############################

occ_thin <- thin(
  loc.data = occ,
  lat.col = "Latitude",
  long.col = "Longitude",
  spec.col = "Species",
  thin.par = 5,
  reps = 1,
  write.files = FALSE
)

occ_thin <- data.frame(occ_thin[[1]])

############################

# LOAD ENVIRONMENTAL DATA

############################

bio <- rast(
  list.files(
    "data/environmental_layers/current",
    pattern = ".tif$",
    full.names = TRUE
  )
)

study_area <- ext(-43, -37, -8, -3)

bio <- crop(bio, study_area)

elevation <- geodata::elevation_global(
  res = 0.5,
  path = "data/topography"
)

elevation <- crop(elevation, study_area)

env <- c(bio, rast(elevation))

############################

# VARIABLE SELECTION

############################

coordinates <- occ[, c("Longitude", "Latitude")]

env_values <- terra::extract(env, coordinates)

env_values <- data.frame(env_values)

vif_results <- vifstep(
  env_values,
  th = 10
)

selected_vars <- exclude(env, vif_results)

selected_vars <- rast(selected_vars)

names(selected_vars) <- c(
  "bio_7",
  "bio_13",
  "bio_18",
  "bio_19",
  "elev"
)

############################

# FORMAT DATA FOR MODELING

############################

formatted_data <- BIOMOD_FormatingData(
  resp.var = occ$presence,
  resp.xy = occ[, c("Longitude", "Latitude")],
  expl.var = selected_vars,
  resp.name = species_name,
  PA.nb.rep = 1,
  PA.nb.absences = 5000,
  PA.strategy = "random"
)

############################

# CROSS-VALIDATION

############################

cv <- bm_CrossValidation(
  bm.format = formatted_data,
  strategy = "kfold",
  nb.rep = 2,
  k = 3
)

############################

# ENSEMBLE OF SMALL MODELS

############################

esm_model <- ecospat.ESM.Modeling(
  data = formatted_data,
  models = c(
    "GLM",
    "CTA",
    "MAXENT",
    "ANN"
  ),
  NbRunEval = 2,
  DataSplit = 80,
  weighting.score = "SomersD",
  tune = FALSE,
  parallel = FALSE
)

############################

# ENSEMBLE CALIBRATION

############################

esm_ensemble <- ecospat.ESM.EnsembleModeling(
  esm_model,
  weighting.score = "SomersD",
  threshold = 0
)

esm_threshold <- ecospat.ESM.threshold(
  esm_ensemble
)

############################

# MODEL EVALUATION

############################

esm_evaluation <- ecospat.ESM.EnsembleEvaluation(
  ESM.modeling.output = esm_model,
  ESM.EnsembleModeling.output = esm_ensemble,
  metrics = "MaxTSS",
  EachSmallModels = FALSE
)

esm_evaluation$ESM.evaluations

############################

# CURRENT PROJECTION

############################

current_projection <- ecospat.ESM.Projection(
  ESM.modeling.output = esm_model,
  new.env = selected_vars
)

current_ensemble <- ecospat.ESM.EnsembleProjection(
  ESM.prediction.output = current_projection,
  ESM.EnsembleModeling.output = esm_ensemble
)

current_suitability <- current_ensemble$EF

current_binary <- (
  current_suitability >
    (esm_threshold$TSS.th * 1000)
) * 1

############################

# VARIABLE CONTRIBUTION

############################

var_contrib <- ecospat.ESM.VarContrib(
  esm_model,
  esm_ensemble
)

rowMeans(var_contrib)

############################

# FUTURE PROJECTIONS

############################

# SSP126 - 2041-2060

future_126 <- rast(
  list.files(
    "data/future/ssp126",
    pattern = ".tif$",
    full.names = TRUE
  )
)

future_126 <- crop(
  future_126,
  study_area
)

future_126 <- subset(
  future_126,
  c(
    "bio_7",
    "bio_13",
    "bio_18",
    "bio_19"
  )
)

future_126 <- c(
  future_126,
  elevation
)

future_projection <- ecospat.ESM.Projection(
  ESM.modeling.output = esm_model,
  new.env = future_126
)

future_ensemble <- ecospat.ESM.EnsembleProjection(
  ESM.prediction.output = future_projection,
  ESM.EnsembleModeling.output = esm_ensemble
)

future_suitability <- future_ensemble$EF

############################

# PAST CLIMATE PROJECTIONS

############################

# LAST INTERGLACIAL (LIG)

# LAST GLACIAL MAXIMUM (LGM)

# MID-HOLOCENE (MID)

# SAME PROCEDURE USED FOR FUTURE PROJECTIONS

############################

# EXPORT RESULTS

############################

writeRaster(
  current_suitability,
  "outputs/current_suitability.tif",
  overwrite = TRUE
)

writeRaster(
  current_binary,
  "outputs/current_binary.tif",
  overwrite = TRUE
)

saveRDS(
  esm_model,
  "outputs/esm_model.rds"
)

################################################################################

# END OF SCRIPT

################################################################################
