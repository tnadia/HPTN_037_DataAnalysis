/* HPTN 037 Non-Injection Drug Use Analysis
   Focus: Philadelphia site, drug use trends, and treatment effects
*/

/* 1. Setup and Data Preparation */
options NOFMTERR;
libname workdt 'C:\Users\tasmi\OneDrive\Documents\URI_Projects\DATA\Preliminary Work';

/* Format definitions for drug use variables */
proc format;
    value $yn 1 = 'Yes' 0 = 'No';
run;

/* Merge relevant datasets */
data m1;
    set workdt.keys;
    keep site_id uid site index treat;
run;

data m2;
    set workdt.dm;
    keep DM1sex site_id uid nkid;
run;

data m3;
    set workdt.Ra;
    array drugs[5] RA2crack RA2cocai RA2smamp RA2hero RA2benzo;
    do i = 1 to 5;
        drugs[i] = (drugs[i] = 1);
    end;
    drop i;
    format RA2crack RA2cocai RA2smamp RA2hero RA2benzo $yn.;
    keep uid visnum RA2crack RA2cocai RA2smamp RA2hero RA2benzo site_id;
run;

/* Sort and merge datasets */
proc sort data=m1; by uid; run;
proc sort data=m2; by uid; run;
proc sort data=m3; by uid; run;

data combine;
    merge m1(in=in1) m2 m3;
    by uid;
    if in1;
    Ninj = (RA2crack=1 | RA2cocai=1 | RA2smamp=1 | RA2hero=1 | RA2benzo=1);
run;

/* 2. Data Filtering and Variable Creation */
data gee1;
    set combine;
    where visnum in (0, 6, 12, 18, 24, 30);
    viscat = visnum / 6;
run;

/* Filter for Philadelphia site */
data phili;
    set gee1;
    where site_id = 222;
run;

/* 3. Statistical Analysis */
%macro drug_analysis(drug);
    proc glimmix data=phili empirical=classical method=laplace;
        class uid treat(ref="2") nkid;
        model &drug(event='Yes') = viscat treat*viscat / dist=binary link=logit s cl;
        random intercept / subject=nkid type=UN gcorr;
        random intercept / subject=uid(nkid) type=UN gcorr;
        covtest / wald;
    run;
%mend;

%drug_analysis(RA2crack);
%drug_analysis(RA2cocai);
%drug_analysis(RA2smamp);
%drug_analysis(RA2hero);
%drug_analysis(RA2benzo);

/* Analysis for any non-injection drug use */
proc glimmix data=phili empirical=classical method=laplace;
    class uid treat(ref="2") nkid;
    model Ninj(event='1') = viscat treat*viscat / dist=binary link=logit s cl;
    random intercept / subject=nkid type=UN gcorr;
    random intercept / subject=uid(nkid) type=UN gcorr;
    covtest / wald;
run;

/* 4. Data Visualization Preparation */
proc means data=phili nway noprint;
    class visnum;
    var RA2crack RA2cocai RA2hero RA2benzo Ninj;
    output out=drug_use_summary(drop=_:) mean=Crack_pct Cocaine_pct Opiates_pct Benzodiazepines_pct Ninj_pct;
run;

data drug_use_summary;
    set drug_use_summary;
    array pcts[*] Crack_pct Cocaine_pct Opiates_pct Benzodiazepines_pct Ninj_pct;
    do i = 1 to dim(pcts);
        pcts[i] = pcts[i] * 100;
    end;
    drop i;
run;

/* 5. Data Visualization */
proc sgplot data=drug_use_summary;
    series x=visnum y=Crack_pct / markers lineattrs=(pattern=solid color=blue) legendlabel='Crack (smoke)';
    series x=visnum y=Cocaine_pct / markers lineattrs=(pattern=dash color=red) legendlabel='Powder cocaine (snort or sniff)';
    series x=visnum y=Opiates_pct / markers lineattrs=(pattern=dot color=green) legendlabel='Opiates (smoked)';
    series x=visnum y=Benzodiazepines_pct / markers lineattrs=(pattern=shortdash color=black) legendlabel='Benzodiazepines';
    xaxis label='Months on Study' values=(0 to 30 by 6) grid;
    yaxis label='Percent Reporting Use' values=(0 to 100 by 10) grid;
    keylegend / location=inside position=topright across=1;
    title 'Change in Non-Injection Drug Use During the Study';
run;
