*=== Kwon and Erola. 2025. Sociological Science. 
*= Last updated on Oct 10, 2025
cd "Your directory"
use "ZA5400_v4-0-0.dta", clear //version 4 is used for this analysis
	* Note: The main survey data, the ISSP 2009 (International Social Survey Programme; ZA5400; Version 4.0.0), are publicly available via the GESIS (https://www.gesis.org/en/issp/data-and-documentation/social-inequality/2009). 
rename V5 country
fre country


* Age
fre AGE 
recode AGE(99=.), gen(age) 
gen agegrp = . 
replace agegrp = 1 if age >24 & age< 35
replace agegrp = 2 if age >34 & age< 45
replace agegrp = 3 if age >44 & age< 55
replace agegrp = 4 if age >54 & age< 65
replace agegrp = 5 if age >64 & age< 99
label define agegrp0    1 "age 25-34" /// 
						2 "age 35-44" /// 
						3 "age 45-54" /// 
						4 "age 55-64" /// 
						5 "age 65 or over" 				
label values agegrp agegrp0
tab  age agegrp, m //age 15-24 + NA are treated as missing
fre agegrp


* Female
fre SEX 
recode SEX(9=.) (1=0) (2=1) , gen(female) 
label define female 0 "Male" 1"Female"
label values female female
tab female SEX,m


* Married  
fre MARITAL
recode MARITAL(9=.)(2 3 4 5=0), gen(married) 
tab MARITAL married,m 


* College 
fre DEGREE
recode DEGREE(8 9=.) (0 1 2 3 4 = 0)(5 = 1), gen(college) 
label define  college 0 "No college" 1"College"
label values college college
tab DEGREE college,m


* Subjective social mobility
*= create the mobility table using ladders with 7 rungs 
fre V44 V45
recode V44(97 98 99=.) (1 2 3=1)(4 5 6 7=2)(8 9 10=3), gen(SSS3) 
recode V45(98 99 =.) (1 2 3=1)(4 5 6 7=2)(8 9 10=3), gen(CSSS3) 
fre SSS CSSS
label define ssslab ///
        1  "Low" ///                                       
		2  "Middle"  ///  
        3  "High"   
label values SSS3 ssslab
label values CSSS3 ssslab
tab V44 SSS3,m 
tab V45 CSSS3,m 

gen socmob1 = .
replace socmob1 = 1 if SSS3<CSSS3  &(SSS3!=. & CSSS3!=.)
replace socmob1 = 2 if SSS3==CSSS3 &(SSS3!=. & CSSS3!=.)
replace socmob1 = 3 if SSS3>CSSS3  &(SSS3!=. & CSSS3!=.)
label define socmob0 1 "Downward mobility" 2 "No mobility"  3 "Upward mobility"
label value socmob1 socmob0
fre socmob1


* Support for meritocracy: education, skill, effort 
fre V48 V51 V52 

*= education-based meritocracy 
recode V48(8 9=.) (1=5)(2=4)(4=2)(5=1), gen(payedu)
label variable payedu "Support for education-based meritocracy"
label define merit 5 "Essential" 4 "Very important" 3 "Fairly important" 2"Not very important" 1"Not important at all"
label value payedu merit
tab V48 payedu,m 

*= skill-based meritocracy
recode V51(0 8 9=.) (1=5)(2=4)(4=2)(5=1), gen(payskill) //Portugal(PT) not asked
label variable payskill "Support for skill-based meritocracy"
label value payskill merit
tab V51 payskill,m 

*= effort-based meritocracy
recode V52(8 9=.) (1=5)(2=4)(4=2)(5=1), gen(payeffort)
label variable payeffort "Support for effort-based meritocracy
label value payeffort merit
tab V52 payeffort,m 


* Keep necessary variables only
keep C_ALPHAN country age-payeffort

************************************************
* Data Merge with Macro-level Data (Tertiary education, GDP per capita, Gini index)
merge m:1 country using "KwonJani_2025_MacroData.dta"
browse


************************************************
* Sample selection and Listwise deletion 
codebook country 
fre gini gdp tertiary2534

* Country selection
*==drop the countries without relevant macro-level data 
drop if tertiary2534==.  
drop if gini==. 
drop if gdppc==. 

*= Drop portugal as payskill question is not asked 
fre payskill if C_ALPHAN == "PT"
drop if C_ALPHAN == "PT"
	codebook country 
	
* Age group selection 
*= drop age below 25 and above 64 as their proportion of tertiary education is not available
*= drop age missing 
fre age agegrp 
drop if age <25 
drop if agegrp==5 
drop if age== . 
fre age agegrp
	codebook country  
	
* Create cohort-specific tertiary education proportion
fre agegrp 						
gen tertiary0 = . 
replace tertiary0 = tertiary2534 if agegrp==1
replace tertiary0 = tertiary3544 if agegrp==2
replace tertiary0 = tertiary4554 if agegrp==3
replace tertiary0 = tertiary5564 if agegrp==4
replace tertiary0 = . if agegrp==. 

* Log transformation of GDP per capita
gen log_gdp= log(gdppc)

* Listwise deletion of individual-level missing values
mdesc age female married payeffort payedu payskill socmob1 college 
foreach X of varlist age female married  payeffort payedu payskill socmob1 college {
		drop if `X' ==.
		}

 

********************************************
* 0. Prep
********************************************
mdesc age female married  payeffort payedu payskill socmob1 college

* Continuous IVs centered around the grand mean
sum age 
gen gage = age - r(mean) 
sum age gage 

sum gini 
gen ggini = gini -r(mean) 

sum log_gdp 
gen glog_gdp = log_gdp -r(mean) 

sum tertiary0 
gen gtertiary0 = tertiary0 -r(mean) 


save "KwonJani_2025_CombinedData_cleaned", replace 


* Table 1. descriptives 
sum payedu payskill payeffort  /// 
	age gage female married college i.socmob1  ///
	gini ggini log_gdp glog_gdp tertiary0 gtertiary0

pwcorr payeffort payedu payskill, sig 



********************************************
* 1. Main analysis 
********************************************

* M1: Support for education-based meritocracy
mixed payedu || country:  , mle 
estat icc 

mixed payedu ggini glog_gdp gtertiary0 gage female i.married i.college  || country:college  , mle cov(unstructured)  
estat icc 
estat ic 
est sto m11 

mixed payedu ggini glog_gdp gage female i.married c.gtertiary0##i.college || country: college , mle cov(unstructured) 
estat icc 
estat ic 
est sto m12 
 sum gtertiary0
	margins, at(gtertiary0 = (-22.5(5)34.5) college=(0 1)) vsquish 
	marginsplot, title ("Predictive Margins with 95% CIs by College:" "Support for Education-based Meritocracy") ylabel(3(0.1)4, grid) ytitle("Predicted Support for Education-based Meritocracy") xtitle("Proportion of Tertiary Educated") plot1opts(lcolor(gs10) lpattern("--") msymbol(square)  mc(gs10) msize(small) ) plot2opts(lcolor(black) mc(black) msize(small)) ci1opts(lcolor(gs10))  ci2opts(lcolor(black) mc(black) msize(small)) legend(ring(0) pos(6) row(1)  region(style(none)) size(small)  on order(3 "No college" 4 "College") ) 
	graph export Figure1.png, replace
	
mixed payedu ggini glog_gdp gage female i.married c.gtertiary0##i.college b2.socmob1 || country: college , mle cov(unstructured)  
estat icc 
estat ic 
est sto m13 

estout m11 m12 m13 using "Tables.xls", nobaselevels label cells(b(star fmt(3)) se(par(`"="("' `")""') fmt(3))) replace		


* M2: Support for skill-based meritocracy
mixed payskill || country:  , mle 
estat icc

mixed payskill ggini glog_gdp gtertiary0 gage female i.married i.college || country:college  , mle cov(unstructured)   
estat icc 
estat ic 
est sto m21 

mixed payskill ggini glog_gdp gage female i.married c.gtertiary0##i.college || country: college , mle cov(unstructured)  
estat icc 
estat ic 
est sto m22 

mixed payskill ggini glog_gdp gage female i.married b2.socmob1 c.gtertiary0##i.college || country: college , mle cov(unstructured) 
estat icc 
estat ic 
est sto m23 
	
estout m21 m22 m23 using "Tables.xls", nobaselevels label cells(b(star fmt(3)) se(par(`"="("' `")""') fmt(3))) append	


* M3: Support for effort-based meritocracy
mixed  payeffort || country:  , mle 
estat icc 

mixed payeffort ggini glog_gdp gtertiary0 gage female i.married i.college  || country:college  , mle cov(unstructured)  
estat icc 
estat ic 
est sto m31 

mixed payeffort ggini glog_gdp gage female i.married c.gtertiary0##i.college || country: college , mle cov(unstructured)  
estat icc 
estat ic 
est sto m32 

mixed payeffort ggini glog_gdp  gage  female i.married b2.socmob1 c.gtertiary0##i.college || country: college , mle cov(unstructured) 
estat icc 
estat ic 
est sto m33 

estout m31 m32 m33 using "Tables.xls", nobaselevels label cells(b(star fmt(3)) se(par(`"="("' `")""') fmt(3))) append	
		



		
