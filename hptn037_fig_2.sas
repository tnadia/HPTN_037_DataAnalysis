/* HPTN 037 Sexual Risk Behavior Analysis
   Focus: Trends in sexual risk behaviors over time
*/

/* 1. Setup and Data Preparation */
options NOFMTERR;
libname workdt 'D:\HPTN 037';

/* Define formats for sexual risk behavior variables */
proc format;
    value $yn 1='Yes' 0='No';
run;

/* Load and clean the main dataset */
data formatted_dataset;
    set workdt.analydata;
    /* Define additional risk variables */
    trans_sex = (RA7give = 1 or RA7recv = 1);
    high_risk_sex = (moreone = 1 or unpnon = 1 or trans_sex = 1);
    /* Keep only necessary variables */
    keep uid visnum moreone unpnon RA7give RA7recv trans_sex high_risk_sex site_id;
    /* Apply formats */
    format moreone unpnon RA7give RA7recv trans_sex high_risk_sex $yn.;
run;

/* 2. Data Filtering and Summary Calculation */
/* Filter for specific visit numbers */
proc sql;
    /* Calculate total participants and risk percentages for each visit */
    create table risk_behavior_summary as
    select visnum,
           count(*) as total,
           sum(moreone = 'Yes') * 100.0 / calculated total as moreone_pct,
           sum(unpnon = 'Yes') * 100.0 / calculated total as unpnon_pct,
           sum(RA7give = 'Yes') * 100.0 / 696 as RA7give_pct,
           sum(RA7recv = 'Yes') * 100.0 / 696 as RA7recv_pct,
           sum(trans_sex = 'Yes') * 100.0 / calculated total as trans_sex_pct,
           sum(high_risk_sex = 'Yes') * 100.0 / calculated total as high_risk_sex_pct
    from formatted_dataset
    where visnum in (0, 6, 12, 18, 24, 30)
    group by visnum;
quit;

/* 3. Data Visualization */
/* Define the picture format for percentages */
proc format;
    picture pctfmt low-high='000%';
run;

/* Generate the plot */
proc sgplot data=risk_behavior_summary;
    series x=visnum y=high_risk_sex_pct / markers lineattrs=(pattern=solid color=red) 
           legendlabel='High risk sexual behavior';
    series x=visnum y=moreone_pct / markers lineattrs=(pattern=dash color=black) 
           legendlabel='Multiple sexual partners';
    series x=visnum y=unpnon_pct / markers lineattrs=(pattern=solid color=blue) 
           legendlabel='Unprotected sex with non-primary partner';
    series x=visnum y=trans_sex_pct / markers lineattrs=(pattern=dashdot color=green) 
           legendlabel='Transactional sex';
    xaxis label='Months on Study' values=(0 to 30 by 6) grid;
    yaxis label='Percent Reporting Risk' values=(0 to 100 by 10) 
          valuesdisplay=('0%' '10%' '20%' '30%' '40%' '50%' '60%' '70%' '80%' '90%' '100%') 
          grid valuesformat=pctfmt.;
    keylegend / location=inside position=topright across=1;
    title 'Change in Sexual Risk Behavior During the Study';
run;
