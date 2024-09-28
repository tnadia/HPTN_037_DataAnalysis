# HPTN_037_DataAnalysis
This repository contains SAS code for analyzing data from the HPTN 037 study, focusing on the relationship between non-injection drug use (NIDU) and high-risk sexual behavior.

# HPTN 037 Data Analysis Code

This repository contains SAS code for analyzing data from the HPTN 037 study, focusing on the relationship between non-injection drug use (NIDU) and high-risk sexual behavior.

## Overview

The code performs the following main tasks:
1. Data preparation and cleaning
2. Creation of derived variables
3. Data transposition for longitudinal analysis
4. Statistical analysis using logistic regression and GEE models
5. Diagnostic tests for multicollinearity

## Prerequisites

- SAS software (version 9.4 or later recommended)
- Access to the HPTN 037 dataset

## Setup

1. Clone this repository to your local machine.
2. Update the library references in the code to point to your local data directories:
   ```sas
   libname workdt 'path_to_your_data_directory';
   libname external 'path_to_your_external_directory';
   ```

## Running the Code

1. Open the SAS program in your SAS environment.
2. Adjust any necessary parameters or file paths.
3. Run the entire program or individual sections as needed.

## Code Structure

The code is organized into the following sections:

1. Setup and Data Preparation
2. Creation of Derived Variables
3. Data Transposition and Cleaning
4. Outcome Variable Preparation
5. Final Dataset Preparation
6. Statistical Analysis
7. Diagnostic Tests

Each section is clearly commented in the code for easy navigation.

## Output

The code generates several output files:
- Logistic regression results: `logistic_regression_output.pdf`
- GEE model results: `gee_model_output.pdf`

These files will be saved in the directory specified in the `ods pdf file=` statements.

## Customization

You may need to modify certain parts of the code based on your specific analysis needs:
- Adjust the site filter if analyzing data from sites other than Philadelphia
- Modify or add variables in the derived variables section
- Add or remove covariates in the statistical models

## Notes

- Ensure that your dataset matches the variable names and structures expected by this code.
- Some sections of the code (e.g., LOCF imputation) are commented out. Uncomment and adjust as needed for your analysis.

## Support

For questions or issues related to this code, please open an issue in the GitHub repository.
