* Kwon and Erola. 2025. Sociological Science. 
*= Do file for the Appendix A table 
*= Last updated on Oct 10, 2025

	
********************************************
use "KwonJani_2025_CombinedData_cleaned", clear //check the main analysis do file to get this data


* Countries divided into two groups: non-WEIRD and WEIRD countries 
gen weirdcnt = 0
replace weirdcnt = 1 /// 
	if country==36 | country==40 | country==56 |country==203| ///
		country==208 | country==246 | country==250 | country==276 | ///
		country==352 | country==376 | country==380 | country==392 | ///
		country==410 | country==578 | country==724 | country==752 | ///
		country==756 | country==826 | country==840    
tab country weirdcnt, m 


* A1. Education-based Meritocracy
mixed payedu ggini glog_gdp gtertiary0 gage female i.married i.college i.weirdcnt || country: college , mle cov(unstructured)  
estat icc 
estat ic 
est sto a11 

mixed  payedu ggini glog_gdp gage female i.married c.gtertiary0##i.college i.weirdcnt || country: college , mle cov(unstructured) 
estat icc 
estat ic 
est sto a12 

mixed  payedu ggini glog_gdp  gage female i.married c.gtertiary0##i.college b2.socmob1 i.weirdcnt || country: college , mle cov(unstructured) 
estat icc 
estat ic 
est sto a13 

estout a11 a12 a13 using AppendixA.xls, nobaselevels label cells(b(star fmt(3)) se(par(`"="("' `")""') fmt(3))) replace	

	
* A2. Skill-based Meritocracy 	
mixed  payskill ggini glog_gdp gtertiary0 gage female i.married i.college i.weirdcnt || country: college , mle cov(unstructured)  
estat icc 
estat ic 
est sto a21 

mixed  payskill ggini glog_gdp gage female i.married i.weirdcnt c.gtertiary0##i.college || country: college , mle cov(unstructured) 
estat icc 
estat ic 
est sto a22

mixed  payskill ggini glog_gdp gage female i.married b2.socmob1 i.college i.weirdcnt c.gtertiary0##i.college  || country: college , mle cov(unstructured)  
estat icc 
estat ic 
est sto  a23 
	
estout  a21 a22 a23  using AppendixA.xls, nobaselevels label cells(b(star fmt(3)) se(par(`"="("' `")""') fmt(3))) append	
	
	
* Effort-based Meritocracy
mixed  payeffort ggini glog_gdp gtertiary0 gage female i.married i.college i.weirdcnt || country: college , mle cov(unstructured)  
estat icc 
estat ic 
est sto a31 

mixed  payeffort ggini glog_gdp gage female i.married c.gtertiary0##i.college i.weirdcnt || country: college , mle cov(unstructured) 
estat icc 
estat ic 
est sto a32 

mixed  payeffort ggini glog_gdp gage female i.married b2.socmob1 c.gtertiary0##i.college i.weirdcnt  || country: college , mle cov(unstructured) 
estat icc 
estat ic 
est sto a33 
		
estout a31 a32 a33 using AppendixA.xls, nobaselevels label cells(b(star fmt(3)) se(par(`"="("' `")""') fmt(3))) append

		