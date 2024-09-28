# HPTN 037 Data Analysis

This directory contains SAS code for analyzing data from the HPTN 037 study, focusing on non-injection drug use (NIDU) and high-risk sexual behavior.

## Files in this Directory

1. `hptn037_nidu_highrisk_analysis.sas`: Main analysis script for NIDU and high-risk sexual behavior.
2. `hptn037_fig_1.sas`: Script for generating Figure 1, showing non-injection drug use trends.
3. `hptn037_fig_2.sas`: Script for generating Figure 2, showing sexual risk behavior trends.

## File Descriptions

### 1. hptn037_nidu_highrisk_analysis.sas

This script performs the primary analysis for the HPTN 037 study:

- Prepares and cleans the dataset
- Creates derived variables
- Conducts logistic regression and GEE models
- Performs diagnostic tests

**Key Outputs**: 
- Logistic regression results (`logistic_regression_output.pdf`)
- GEE model results (`gee_model_output.pdf`)

### 2. hptn037_fig_1.sas

This script focuses on non-injection drug use analysis for the Philadelphia site:

- Merges and prepares relevant datasets
- Conducts statistical analysis using GLIMMIX
- Generates a visualization of drug use trends over time

**Key Output**: A plot showing the change in non-injection drug use during the study.

### 3. hptn037_fig_2.sas

This script analyzes and visualizes sexual risk behavior trends:

- Prepares the dataset for sexual risk behavior analysis
- Calculates risk percentages for each visit
- Generates a plot showing changes in sexual risk behaviors over time

**Key Output**: A plot showing the change in sexual risk behavior during the study.

## Usage Instructions

1. Ensure you have SAS software installed (version 9.4 or later recommended).
2. Update the `libname` statements in each script to point to your local data directory.
3. Run the scripts in the following order:
   a. `hptn037_nidu_highrisk_analysis.sas`
   b. `hptn037_fig_1.sas`
   c. `hptn037_fig_2.sas`
4. Review the output PDFs and generated plots.

## Data Requirements

- HPTN 037 dataset files: `analydatafinal`, `keys`, `dm`, `Ra`, `analydata`
- Ensure all required variables are present in these datasets

## Notes

- The analysis focuses on the Philadelphia site (site_id = 222) in some scripts.
- Modify site selection if analyzing data from other locations.
- Review and validate all results, especially percentage calculations.

## Support

For questions or issues related to this analysis, please contact the study data management team.
