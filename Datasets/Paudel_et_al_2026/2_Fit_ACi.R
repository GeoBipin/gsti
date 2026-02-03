
# Fit ACi curves and estimate photosynthetic parameters

# This step fits ACi response curves for each leaf and estimates photosynthetic capacity parameters.
# We use a standard ACi fitting function, provide it with the quality-checked ACi data, and fit one curve per sample.
# The fitted parameters (Bilan) are the physiological traits that will later be linked with hyperspectral reflectance and metadata.

# Load the 'here' package to easily reference files and folders path, which is robust and independent on platform (Linux, Windows)
library(here)

# Find the path of the top relative directory
path=here()

# Set the working directory to the 'Paudel_et_al_2026' folder where the data is located
setwd(file.path(path,'/Datasets/Paudel_et_al_2026'))

# Load various functions that are used to fit, plot and analyse the ACi curves
source(file.path(path,'/R/fit_Vcmax.R'))
source(file.path(path,'/R/Photosynthesis_tools.R'))

# Load quality-checked ACi data
load("1_QC_ACi_data.Rdata")  # loads curated_data_qc

# Use the object saved in the previous step
if (exists("curated_data_qc")) {
  ACi_data <- curated_data_qc
} else if (exists("curated_data")) {
  ACi_data <- curated_data
} else {
  stop("Neither curated_data_qc nor curated_data found in loaded RData.")
}

# Create the column names required by the ACi fitting function
ACi_data$SampleID     <- as.character(ACi_data$Sample)
ACi_data$SampleID_num <- as.integer(ACi_data$Sample_num)

# Sort by curve and increasing Ci (required for stable fitting)
ACi_data <- ACi_data[order(ACi_data$SampleID_num, ACi_data$Ci), ]

# Fit ACi curves (one curve per sample)
Bilan <- f.fit_ACi(
  measures = ACi_data,
  param    = f.make.param()
)

# Attach SampleID and Sample name back to fitted parameters
sample_map <- ACi_data[!duplicated(ACi_data$SampleID_num),
                       c("SampleID_num", "SampleID", "Sample")]

Bilan <- merge(Bilan, sample_map, by = "SampleID_num", all.x = TRUE, sort = FALSE)

# Save fitted ACi parameters
save(Bilan, file = "2_Fitted_ACi_data.Rdata")

cat("ACi fitting completed successfully.\n")
cat("Saved: 2_Fitted_ACi_data.Rdata \n")
