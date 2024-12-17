%macro mergeVarGroupData(inds_base,outds);
    data &outds.;
        merge &inds_base.:;
        by geocode;
    run;
%mend mergeVarGroupData;

%macro deleteDatasets(lib=work, datasets=);
    proc datasets library=&lib nolist;
        delete &datasets;
    run;
    quit;
%mend deleteDatasets;


%macro base_append( inds                    /*The dataset we will append to the dataset. */
                    ,basetable=basetable    /*Just the name of the base table to house the raw counts. It could be named anything */
                    ,new_basetable=true     /*Set to false if you have a structure and just need to append data. */
                    );
    %if &new_basetable. = true %then %do;
    %put INFO: creating a new base table: &basetable..;
    proc sql;
    create table &basetable. like &inds.;
    quit;
    %end;
    %else %do;
    %put INFO: not creating a new base table.;
    %end;
    %put INFO: Appending to &basetable..;
    proc datasets library=work nolist;
        append base=&basetable. data=&inds.;
    run;
%mend base_append;


* Macro to fetch states;
%macro get_states();
    %global state_list statename_list;
        * AL  01  ALABAMA;
        * AK  02  ALASKA;
        * AZ  04  ARIZONA;
        * AR  05  ARKANSAS;        
        * CA  06  CALIFORNIA;
        * CO  08  COLORADO;
        * CT  09  CONNECTICUT;
        * DC  11  DISTRICT OF COLUMBIA;
        * DE  10  DELAWARE;
        * FL  12  FLORIDA;
        * GA  13  GEORGIA;
        * HI  15  HAWAII;
        * ID  16  IDAHO;
        * IL  17  ILLINOIS;
        * IN  18  INDIANA;
        * IA  19  IOWA;
        * KS  20  KANSAS;
        * KY  21  KENTUCKY;
        * LA  22  LOUISIANA;
        * ME  23  MAINE;
        * MD  24  MARYLAND;
        * MA  25  MASSACHUSETTS;
        * MI  26  MICHIGAN;
        * MN  27  MINNESOTA;
        * MS  28  MISSISSIPPI;
        * MO  29  MISSOURI;
        * MT  30  MONTANA;
        * NE  31  NEBRASKA;
        * NV  32  NEVADA;
        * NH  33  NEW HAMPSHIRE;
        * NJ  34  NEW JERSEY;
        * NM  35  NEW MEXICO;
        * NY  36  NEW YORK;
        * NC  37  NORTH CAROLINA;
        * ND  38  NORTH DAKOTA;
        * OH  39  OHIO;
        * OK  40  OKLAHOMA;
        * OR  41  OREGON;
        * PA  42  PENNSYLVANIA;
        * RI  44  RHODE ISLAND;
        * SC  45  SOUTH CAROLINA;
        * SD  46  SOUTH DAKOTA;
        * TN  47  TENNESSEE;
        * TX  48  TEXAS;
        * UT  49  UTAH;
        * VA  51  VIRGINIA;
        * VT  50  VERMONT;
        * WA  53  WASHINGTON;
        * WI  55  WISCONSIN;
        * WV  54  WEST VIRGINIA;
        * WY  56  WYOMING;
    * Puerto Rico sometimes has data, but the other territories not so much.;
    * 64 - Federated States of Micronesia;
    * 66 - Guam;
    * 68 - Marshall Islands;
    * 69 - Northern Mariana Islands;
    * 70 - Palau;
    * 72 - Puerto Rico;
    * 78 - Virgin Islands of the US;
    %let state_list = 01 02 04 05 06 08 09 10 11 12 13 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 44 45 46 47 48 49 50 51 53 54 55 56;
%mend get_states;


%macro getACSfromAPI(year=, releasetype=acs5,geog=tract, state=, census_key=, outds=, debug=true, vargroup=);
   * Read column names from first row of JSON data.;
    * Data sourced from Census API:
    * * https://api.census.gov/data/2010/acs/acs5/variables.html;
    * * https://api.census.gov/data/2011/acs/acs5/variables.html;
    * * https://api.census.gov/data/2012/acs/acs5/variables.html;
    * * https://api.census.gov/data/2013/acs/acs5/variables.html;
    * * https://api.census.gov/data/2014/acs/acs5/variables.html;
    * * https://api.census.gov/data/2015/acs/acs5/variables.html;
    * * https://api.census.gov/data/2016/acs/acs5/variables.html;
    * * https://api.census.gov/data/2017/acs/acs5/variables.html;
    * * https://api.census.gov/data/2018/acs/acs5/variables.html;
    * * https://api.census.gov/data/2019/acs/acs5/variables.html;
    * * https://api.census.gov/data/2020/acs/acs5/variables.html;
    * * https://api.census.gov/data/2021/acs/acs5/variables.html;
    * * https://api.census.gov/data/2022/acs/acs5/variables.html;
    
    * define the URL based on the parameters from the macro;
    %let url = https://api.census.gov/data/&year./acs/&releasetype.?get=NAME,group(&vargroup)%str(&)for=&geog.:*%str(&)in=state:&state.%str(&)key=&census_key.;

    * define a temp file for the api to write the response;
    filename resp temp;

    * make a proc http call to the Census;
    proc http
        url= "&url."
        method="get"
        out=resp;
    run;
    
    * read in the json;
    libname apijson JSON fileref=resp;
    
    * this is a really wonky bit. we want to create a dataset with 3 variables to keep, set lengths, and rename variables;
    * the base return dataset is element1..elementn;
    data var_names;
        set apijson.root;
        if _n_ = 1;
        array varlist {*} element:;
        do v = 1 to dim(varlist);
            origname = compress('element' || v);
            kp = varlist{v};
            rn = compress(origname || "=" || varlist{v});
            if varlist{v} = 'NAME' then do;
                ln = varlist{v} || ' $65';
            end;
            else if varlist{v} = 'state' then do;
                ln = varlist{v} || ' $2';
            end;
            else if varlist{v} = 'county' then do;
                ln = varlist{v} || ' $3';
            end;
            else if varlist{v} = 'tract' then do;
                ln = varlist{v} || ' $6';
            end;
            else do;
                ln = varlist{v} || ' $10';
            end;
            output;
        end;
        keep rn kp ln;
    run;
    * the API often includes duplicate "NAME" variable, which is problematic later;
    proc sort nodupkey data=var_names;
        by kp;
    run;

    * smash these into macro variables for use later.;
    proc sql noprint;
        select rn into :rn_stmt separated by ' '
            from var_names;
        select kp into :kp_stmt separated by ' '
            from var_names;
        select ln into :ln_stmt separated by ' '
            from var_names;
    quit;

    * define the length, keep, and rename variables from above;
    * turn off length check warnings-- we allocated more space than the source;
    options varlenchk= nowarn;
    data _tmp_ds(keep=&kp_stmt.);
        length &ln_stmt. ;
        set apijson.root(rename=(&rn_stmt.) firstobs=2) ;
    run;
    * turn warnings back on;
    options varlenchk=warn;

        
    * pull out metadata for some type changing;
    proc contents data=_tmp_ds out=cont noprint;
    run;
    
    * produce dynamic type changing b/c all census variables are counts;
    * keep only variables ending in 'E' - this signifies that they are estimates and not margin of error estimates or annotations.;
    * You can go in and process "M" or margin of error estimates if you want to investigate how different some of these variables can be;
    proc sql noprint;
        select cat('_',NAME,'=input(',NAME,',8.);drop ',NAME,'; rename _',NAME,'=',NAME) 
        into :character_to_numeric separated by ';'
        from cont
        where 
            upcase(NAME) not in('NAME','STATE','COUNTY','TRACT') and type=2
            and (substr(strip(reverse(NAME)),1,1) ='E')
        ;
        select NAME
        into :_outds_kp separated by ' '
        from cont
        where 
            (upcase(NAME) in('NAME','STATE','COUNTY','TRACT') )
            or 
            (substr(strip(reverse(NAME)),1,1) ='E')
        ;
    quit;


    %put INFO: Outputting dataset for state=&state. to &outds.. ;
    %put INFO: Keeping &_outds_kp.. ;
    data &outds.;
        length geocode $ 11;
        set _tmp_ds(keep=&_outds_kp.);
        &character_to_numeric.;
        year=&year.;
        geocode = cats(state,county,tract);
    run;

    proc sort data=&outds. nodupkey;
        by geocode;
    run;

    *clean up;
    %if &debug^=true %then %do;
        %deleteDatasets(lib=work, datasets= var_names _tmp_ds cont);
    %end;
%mend;

* Demographic variables to define what we pull as we pull it;
data _variable_list;
    length variable_group $10 group_description $120;
    infile datalines dlm="|" dsd;
    input variable_group group_description;
    datalines;
B01001|"SEX BY EDUCATIONAL ATTAINMENT FOR THE POPULATION 25 YEARS AND OVER"
B05001|"NATIVITY AND CITIZENSHIP STATUS IN THE UNITED STATES"
B07001|"GEOGRAPHICAL MOBILITY IN THE PAST YEAR BY AGE FOR CURRENT RESIDENCE IN THE UNITED STATES"
B08201|"HOUSEHOLD SIZE BY VEHICLES AVAILABLE"
B12001|"SEX BY MARITAL STATUS FOR THE POPULATION 15 YEARS AND OVER"
B15002|"SEX BY EDUCATIONAL ATTAINMENT FOR THE POPULATION 25 YEARS AND OVER"
B16007|"AGE BY LANGUAGE SPOKEN AT HOME FOR THE POPULATION 5 YEARS AND OVER"
B17001|"POVERTY STATUS IN THE PAST 12 MONTHS BY SEX BY AGE"
B17026|"RATIO OF INCOME TO POVERTY LEVEL OF FAMILIES IN THE PAST 12 MONTHS"
B18101|"SEX BY AGE BY DISABILITY STATUS"
B19001|"HOUSEHOLD INCOME IN THE PAST 12 MONTHS (IN RELEASE YEAR INFLATION-ADJUSTED DOLLARS)"
B19013|"MEDIAN HOUSEHOLD INCOME IN THE PAST 12 MONTHS (IN 2018 INFLATION-ADJUSTED DOLLARS)"
B19057|"PUBLIC ASSISTANCE INCOME IN THE PAST 12 MONTHS FOR HOUSEHOLDS"
B19101|"FAMILY INCOME IN THE PAST 12 MONTHS (IN RELEASE YEAR INFLATION-ADJUSTED DOLLARS)"
B19113|"MEDIAN FAMILY INCOME IN THE PAST 12 MONTHS (IN RELEASE YEAR INFLATION-ADJUSTED DOLLARS)"
B23001|"SEX BY AGE BY EMPLOYMENT STATUS FOR THE POPULATION 16 YEARS AND OVER"
B25014|"TENURE BY OCCUPANTS PER ROOM"
B25026|"TOTAL POPULATION IN OCCUPIED HOUSING UNITS BY TENURE BY YEAR HOUSEHOLDER MOVED INTO UNIT"
B25091|"MORTGAGE STATUS BY SELECTED MONTHLY OWNER COSTS AS A PERCENTAGE OF HOUSEHOLD INCOME IN THE PAST 12 MONTHS"
B25115|"TENURE BY HOUSEHOLD TYPE AND PRESENCE AND AGE OF OWN CHILDREN"
B25077|"HOUSEHOLD MEDIAN VALUE (DOLLARS)"
C18108|"AGE BY NUMBER OF DISABILITIES"
C24040|"SEX BY INDUSTRY FOR THE FULL-TIME, YEAR-ROUND CIVILIAN EMPLOYED POPULATION 16 YEARS AND OVER"
C27006|"MEDICARE COVERAGE BY SEX BY AGE"
C27007|"MEDICAID/MEANS-TESTED PUBLIC COVERAGE BY SEX BY AGE"
    ;
run;

* macro variables to iterate over variable groups;
proc sql noprint; 
    select variable_group
    into :variable_group_list separated by ","
    from _variable_list
    ;
    select group_description
    into :group_description_list separated by ","
    from _variable_list
    ;
quit;