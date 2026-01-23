## This code is used to do the step 1 of the data curation process.
## It is used to analyse and check the data quality..
# This step visually checks each ACi curve to ensure the gas-exchange measurements look reasonable and correctly ordered.
# We plot net photosynthesis (A) against intercellular CO??? (Ci) for each sample, label individual measurement points, and save all curves into a single PDF file.
# Visual QA/QC helps detect obvious measurement or ordering problems before curve fitting, without removing or modifying any data points.


# Load the 'here' package to easily reference files and folders path, which is robust and independent on platform (Linux, Windows)
library(here)

# Find the path of the top relative directory
path=here()

# Set the working directory to the 'Paudel_et_al_2026' folder where the data is located
setwd(file.path(path,'/Datasets/Paudel_et_al_2026'))

# Load curated ACi data from Step 0
load("0_curated_data.Rdata", verbose = TRUE)  # loads curated_data

# Required columns check
required_columns <- c("Sample", "Sample_num", "A", "Ci", "Patm", "Qin", "Tleaf")
if (!all(required_columns %in% names(curated_data))) {
  stop(
    "Missing required columns: ",
    paste(setdiff(required_columns, names(curated_data)), collapse = ", "),
    "\nAvailable columns:\n",
    paste(names(curated_data), collapse = ", ")
  )
}

# Add SampleID for downstream consistency checks
curated_data$SampleID <- as.character(curated_data$Sample)

# Create record index for labeling points within each curve
curated_data$Record <- ave(curated_data$Ci, curated_data$Sample_num, FUN = seq_along)

# Create QA/QC PDF with all ACi curves
pdf(file = "1_QA_QC_Aci.pdf", width = 8, height = 6)

for (sample_number in sort(unique(curated_data$Sample_num))) {
  
  curve_data <- curated_data[curated_data$Sample_num == sample_number, ]
  
  plot(
    x = curve_data$Ci,
    y = curve_data$A,
    main = paste("Sample_num:", sample_number, "| Sample:", unique(curve_data$Sample)),
    xlab = "Ci (ppm)",
    ylab = expression(A~(mu*mol~m^{-2}~s^{-1})),
    pch  = 1,
    cex  = 1.3
  )
  
  text(
    x = curve_data$Ci,
    y = curve_data$A,
    labels = curve_data$Record,
    cex = 0.7
  )
}

dev.off()

# Save QA/QC-checked ACi data (unchanged values)
curated_data_qc <- curated_data
save(curated_data_qc, file = "1_QC_ACi_data.Rdata")

cat("QA/QC plots created (no points removed).\n")
cat("Saved: 1_QC_ACi_data.Rdata\n")
cat("PDF:   1_QA_QC_Aci.pdf\n")
