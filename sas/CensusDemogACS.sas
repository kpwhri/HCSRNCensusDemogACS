************************************************************************************
ACS Extraction via API
************************************************************************************

Program Name:       CensusDemogACS.sas      
Contacts:           Alphonse.Derus@kp.org


VDW Version: V5                                                

Purpose: This is an ETL used to extract American Community Surveydata directly from the US Census Bureau's API. 
The data is then transformed into a SAS dataset. 
The data is then available to be loaded into a database.
;
************************************************************************************
PROGRAM DETAILS
************************************************************************************

Dependencies :
 
VDW tables:

Other Files:  
    census_key

-------------------------------------------------------------------------------------- 
input:
    1    custom_macros.sas

-------------------------------------------------------------------------------------- 
local_only: 
SAS List file to remain at your site - DO NOT SEND
Number of files created in this folder = [Varies]

-------------------------------------------------------------------------------------- 
share:    
Number of shared SAS Datasets created: 4
Output SAS data sets to be shared outside your site: 
    1 - cendemogdec_length.sas7bdat
    2 - cendemogdec_vartype.sas7bdat
    3 - dco_file.sas7bdat
    4 - run_time.sas7bdat
;

ods listing close;

*--------------------------------------------
SITE EDITS
---------------------------------------------;
* Call on StdVars.sas.;
* %include "&stdvars_dir./StdVars.sas" ;

*Where did you unpack the zip file?;
* %let root = \\fsproj\aaa...\PACKAGE_LOCATION;

* Where does your census key live?;
* check out document/sample_census_key.txt for an example;
/* %include "\\path\to\census_key.txt"; */

* is your network throttling you? let's try "sleep" to give the network a break and hopefully make it go away;
%let sleep_seconds=0.1;

*---NO EDITS SHOULD BE NEEDED BEYOND THIS POINT---;

*--------------------------------------------
SETUP
---------------------------------------------;


*Set sub-directories;
libname root "&root";
%let outlocal = &root/local_only;
libname outlocal "&outlocal.";
%let input = &root/input;
libname input "&input.";
%let outshare = &root/share;
libname outshare "&outshare.";
libname QA_ds "&outshare";
%let QAoutlib=QA_ds;

%let workplan = vdw_census_demog_acs;

*Define content area;
%let content_area = CENSUS;

*Set the year/month of the program distribution YYYYMM;
%let era = 202405;
*Set version of this workplan;
%let wp_v = 2;
*Set VDW specification version;
%let version = 5;



data _null_;
    *For trend cutoffs;
    call symput('start_year', 2000);
    call symput('end_year', strip(year(today())));
    call symput('currentMonth', strip(put(today(), monname.)));

    *For runtime file;
    st=datetime();
    call symput("session_date",put(today(),mmddyy10.));
    call symput("st",st);
    call symput("start_time",put(st,datetime.));
run;

*Call input files;
%include "&input./custom_macros.sas";
%include "&input./qa_macros.sas";
%include "&input./vdw_variable_calculations.sas";

* Global titles and footnotes;
title1 "VDW Census: ACS 2012+ ETL"; 
footnote1 "&_sitename : &workplan. (&sysdate, &systime)"; 

*Establish log in share folder and list in local;
proc printto     
    log="&root./share/&workplan._&era..log"
    print="&root./local_only/&workplan._&era..lst"
    ;
run; 

* set destination output;
filename pdfmain "&outshare./VDW Census ACS ETL &currentMonth. &end_year. &_siteabbr..pdf"; 


 *--------------------------------------------
 ---------------------------------------------
 ---------------------------------------------
 START MAIN PROGRAM
 ---------------------------------------------
 ---------------------------------------------
 ---------------------------------------------;





* build out a pipeline from the /input/custom_macros.sas;
* currently only works with tract level. Otherwise, you'd need to change the definition of geocode to incorporate geocode; 
* %get_states is to put the state list into a macro variable;
* top level is to iterate between years.;
%macro acs_pipeline(outds, geog=tract, start_year=, end_year=, key=&census_key., new_basetable=true, sleep_seconds=0);
    %get_states;
    %put NOTE: STATE_LIST = &state_list.;
    %local i next_state;
    %let base_setup = &new_basetable.;
    %do release_year=&start_year %to &end_year.;
        %do i=1 %to %sysfunc(countw(&state_list));
            %** Fetch the &next_state;
            %let next_state = %scan(&state_list, &i.);
            %put INFO: Retrieving state=&next_state..;   
            %** sleep if it gets buggy.;
            data _null_;
                call sleep(1000, &sleep_seconds.); /* Sleep for 5000 milliseconds (5 seconds) */
            run;
            %do i2=1 %to %sysfunc(countw(%quote(&variable_group_list.), %str(,)));
                %** fetch the next_var_group;
                %let next_vg = %scan(%quote(&variable_group_list.), &i2., %str(,));
                %let next_vdesc = %scan(%quote(&group_description_list.), &i2., %str(,));
                %put INFO: Fetching variable &next_vg.;
                %put INFO: Variable Description - &next_vdesc.;
                %getACSfromAPI(year=&release_year., releasetype=acs5, geog=tract, state=&next_state., census_key=&census_key., outds=&outds._raw_&next_vg., debug=false, vargroup=&next_vg.);
            %end;
            %** merge the variables together;
            %mergeVarGroupData(&outds._raw_,&outds._tmp);
            %put INFO: base_setup = &base_setup..;
            %base_append(&outds._tmp, basetable=&outds., new_basetable=&base_setup.);
            %let base_setup = false;
        %end;   
    %end;
%mend acs_pipeline;


* Run the pipeline;
%acs_pipeline(acs_demog_raw, geog=tract, start_year=2012, end_year=2022, key=&census_key., new_basetable=true, sleep_seconds=&sleep_seconds.);


data outlocal.acs_demog_calculated; 
    set acs_demog_raw (rename=(year=census_year));
    keep geocode census_year &_siteabbr._area_description &_siteabbr._popsize &acs_demog_keep. ;
        geocode_boundary_year = floor(year(census_year)/10) * 10 ; * this gives us the map vintage;
        &_siteabbr._area_description = name; * this gives us a human readable name of a geography.;
        &_siteabbr._popsize = B01001_001E; * this gives us the population of a geography.;
        state = substr(geocode, 1,2);
        county = substr(geocode, 3,3);
        tract = substr(geocode, 5,6);
        &EDUCATION1.;
        &EDUCATION2.;
        &EDUCATION3.;
        &EDUCATION4.;
        &EDUCATION5.;
        &EDUCATION6.;
        &EDUCATION7.;
        &EDUCATION8.;
        &MEDFAMINCOME.;
        &FAMINCOME1.;
        &FAMINCOME2.;
        &FAMINCOME3.;
        &FAMINCOME4.;
        &FAMINCOME5.;
        &FAMINCOME6.;
        &FAMINCOME7.;
        &FAMINCOME8.;
        &FAMINCOME9.;
        &FAMINCOME10.;
        &FAMINCOME11.;
        &FAMINCOME12.;
        &FAMINCOME13.;
        &FAMINCOME14.;
        &FAMINCOME15.;
        &FAMINCOME16.;
        &FAMPOVERTY.;
        &MEDHOUSINCOME.;
        &HOUSINCOME1.;
        &HOUSINCOME2.;
        &HOUSINCOME3.;
        &HOUSINCOME4.;
        &HOUSINCOME5.;
        &HOUSINCOME6.;
        &HOUSINCOME7.;
        &HOUSINCOME8.;
        &HOUSINCOME9.;
        &HOUSINCOME10.;
        &HOUSINCOME11.;
        &HOUSINCOME12.;
        &HOUSINCOME13.;
        &HOUSINCOME14.;
        &HOUSINCOME15.;
        &HOUSINCOME16.;
        &HOUSPOVERTY.;
        &POV_LT_50.;
        &POV_50_74.;
        &POV_75_99.;
        &POV_100_124.;
        &POV_125_149.;
        &POV_150_174.;
        &POV_175_184.;
        &POV_185_199.;
        &POV_GT_200.;
        &ENGLISH_SPEAKER.;
        &SPANISH_SPEAKER.;
        &BORNINUS.;
        &MOVEDINLAST12MON.;
        &MARRIED.;
        &DIVORCED.;
        &DISABILITY.;
        &UNEMPLOYMENT.;
        &UNEMPLOYMENT_MALE.;
        &INS_MEDICARE.;
        &INS_MEDICAID.;
        &HH_NOCAR.;
        &HH_PUBLIC_ASSISTANCE.;
        &HMOWNER_COSTS_MORT.;
        &HMOWNER_COSTS_NO_MORT.;
        &HOMES_MEDVALUE.;
        &PCT_CROWDING.;
        &FEMALE_HEAD_OF_HH.;
        &MGR_FEMALE.;
        &MGR_MALE.;
        &RESIDENTS_65.;
        &SAME_RESIDENCE.;
        ;
run;

* confirm that all geographies are accounted for;
proc freq data=acs_demog_calculated;
    tables
        state*year 
        / out=outshare.state_year_freq
        ;
run;

* make sure the data exists as we expect it;
proc means data = outlocal.acs_demog_calculated min p1 p25 p50 p75 p99 max mean out=outshare.var_means_lvl1;
run;

