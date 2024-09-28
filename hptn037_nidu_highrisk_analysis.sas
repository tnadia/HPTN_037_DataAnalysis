/* HPTN 037 Data Analysis
   This SAS code analyzes data from the HPTN 037 study, focusing on the relationship
   between non-injection drug use (NIDU) and high-risk sexual behavior.
*/

/* 1. Setup and Data Preparation */
options NOFMTERR;
libname workdt 'D:\HPTN 037\raw data';
libname external 'D:\';

/* Format definitions for various variables */
proc format;
    value DM1sexf 1 = 'Male' 0 = 'Female';
    value treatf 1 = 'Intervention' 2 = 'Control';
    value binary_fmt 1 = 'Yes' 0 = 'No';
    /* Add other format definitions here */
run;

/* Load and format baseline data, filter for Philadelphia site */
data baseline_data;
    set workdt.analydatafinal;
    format DM1sex DM1sexf. treat treatf. /* Add other format applications */;
    if site_id = 222; /* Philadelphia site */
run;

/* 2. Create derived variables */
data analy;
    set baseline_data;
    
    /* Age categories */
    if 18 <= age <= 30 then agecat = 1;
    else if 31 <= age <= 40 then agecat = 2;
    else if 41 <= age <= 50 then agecat = 3;
    else if age >= 51 then agecat = 4;
    else agecat = .;

    /* Employment Status */
    employ = (DM2empl in (1, 2, 3));

    /* Education Level */
    if DM2educ in (1, 2, 3) then edu = 1;
    else if DM2educ = 4 then edu = 2;
    else if DM2educ in (5, 6, 7, 8) then edu = 3;
    else edu = .;

    /* Add other derived variables here */

    /* High risk sexual behavior */
    high_risk_sex = (moreone = 1 or unpnon = 1 or trans_sex = 1);

    /* Format application */
    format agecat agecatf. employ employf. edu eduf. /* Add other formats */;
run;

/* 3. Data Transposition and Cleaning */
/* Transpose NIDU variables */
%macro transpose_drug(drug);
    proc transpose data=analy out=transposed_&drug prefix=RA2&drug._;
        by uid;
        id visnum;
        var RA2&drug;
    run;
%mend;

%transpose_drug(crack);
%transpose_drug(cocai);
%transpose_drug(smamp);
%transpose_drug(benzo);
%transpose_drug(hero);

/* Merge all transposed datasets */
data final_transposed;
    merge transposed_crack transposed_cocai transposed_smamp transposed_benzo transposed_hero;
    by uid;
run;

/* Create 'ever_nidu' variable */
data analy_clean;
    set final_transposed;
    ever_nidu = max(of RA2crack_0-RA2crack_30 RA2cocai_0-RA2cocai_30 
                    RA2smamp_0-RA2smamp_30 RA2benzo_0-RA2benzo_30 
                    RA2hero_0-RA2hero_30);
    ever_nidu = (ever_nidu > 0);
    label ever_nidu = "Ever Used Non-Injection Drugs";
run;

/* 4. Outcome Variable Preparation */
/* Transpose outcome variables */
%macro transpose_outcome(var);
    proc transpose data=analy out=transposed_&var prefix=&var._;
        by uid;
        id visnum;
        var &var;
    run;
%mend;

%transpose_outcome(moreone);
%transpose_outcome(unpnon);
%transpose_outcome(trans_sex);
%transpose_outcome(high_risk_sex);

/* Merge transposed outcome datasets */
data final_transposed_outcome;
    merge transposed_moreone transposed_unpnon transposed_trans_sex transposed_high_risk_sex;
    by uid;
run;

/* Create 'ever_highrisk_sex' variable */
data analy_clean_outcome;
    set final_transposed_outcome;
    ever_highrisk_sex = max(of moreone_0-moreone_30 unpnon_0-unpnon_30 trans_sex_0-trans_sex_30);
    ever_highrisk_sex = (ever_highrisk_sex > 0);
    label ever_highrisk_sex = "Ever Engaged in High-Risk Sexual Behavior";
run;

/* 5. Final Dataset Preparation */
/* Merge exposure, outcome, and covariates */
data final_merged_data;
    merge analy_clean analy_clean_outcome deduplicated_data;
    by uid;
run;

/* 6. Statistical Analysis */
/* Logistic Regression */
ods pdf file='D:\HPTN 037\raw data\logistic_regression_output.pdf';
proc logistic data=final_merged_data;
    class ever_nidu (ref='0') treat (ref='Control') 
          DM1sex(ref='Male') agecat(ref='50+') employ(ref='Employed') 
          edu(ref='Up to some Secondary School') race (ref='white')
          marit(ref='Married/living with partner') drinkcat(ref='didnot drink') 
          new_RA1strt(ref='0') new_RA1jail(ref='0') RA3inj6m (ref='0') / param=ref;
    model ever_highrisk_sex (event='1') = ever_nidu treat DM1sex agecat employ edu race marit drinkcat new_RA1strt new_RA1jail RA3inj6m;
run;
ods pdf close;

/* GEE Model */
ods pdf file='D:\HPTN 037\raw data\gee_model_output.pdf';
proc genmod data=final_merged_data descending;
    class uid treat (ref='Control') nkid DM1sex (ref='Male') agecat (ref='50+') 
          employ (ref='Employed') race (ref='white') 
          marit (ref='Married/living with partner') 
          new_RA1strt (ref='0') new_RA1jail (ref='0');
    model ever_highrisk_sex = ever_nidu treat DM1sex agecat employ race marit new_RA1strt new_RA1jail / dist=bin link=log;
    repeated subject=nkid / type=ind;
    title "Log-binomial GEE Model for Risk Ratios";
run;
ods pdf close;

/* 7. Diagnostic Tests */
/* Check for multicollinearity */
proc reg data=final_merged_data;
    model ever_highrisk_sex = ever_nidu Ninje DM1sex agecat employ edu marit drinkcat new_RA1strt new_RA1jail / vif;
run;

/* Correlation analysis */
proc corr data=final_merged_data;
    var ever_nidu Ninje;
run;
