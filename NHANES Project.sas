**************************************************************************
** P8483 Final Project 													**
																		**
** 																		**                                            **
** Rubab Sohail 	                                                    **
																		**
** 																		**
**************************************************************************    ;


* 
Population of interest: US adults (age 21 - 65 years)
Data source: NHANES 2015-16
  
We will examine whether a self-reported healthy diet, ranked as an ordered categorical variable (poor/
not poor), is associated with a diagnosis of diabetes mellitus as defined by glyco-hemoglobin levels
greater than or equal to 6.5%, as a dichotomous variable, in adults 21 years of age to 65 years of 
age. 

We hypothesize that a poor diet (as defined as DBQ700 = 5 (“poor”) and DBQ700 = 4 ("fair")) will lead 
to a diagnosis of diabetes as defined as a glycohemoglobin level >=6.5%, when compared to a diet rated
as good, very good, or excellent (DBQ700 = 1/2/3), adjusting for age, physical activity, and 
education.

Variables of interest (NHANES name):
1. Self-reported diet (DBQ700) from the file DBQ_I
2. Education (DMDEDUC2) from the file DEMO_I
3. Physical activity (PAQ665) from the file PAQ_I
4. Glycohemoglobin (LBXGH) from the file GHB_I
5. Age (RIDAGEYR) from the file DEMO_I

Outcome = Glycohemoglobin (using this as a proxy for diabetes)
Predictor = Diet (poor vs. not poor)
Confounders = Education (using this as a proxy for SES), physical activity, age. 

;

* 
Part 1:
Importing SAS data files from NHANES through proc http and merging them into a single file called
"FINAL".
We are restricting age (RIDAGEYR) between 21 and 65 years to capture our population of interest and 
removing any missing, refused, or don't know values from our data.
  


* Importing GHB_I which contains our outcome GLYCOHEMOGLOBIN (LBXGH) and removing missing values;

filename GHB_I "/home/u60678721/sasuser.v94/GHB_I.xpt";
proc http 
url = "https://wwwn.cdc.gov/Nchs/Nhanes/2015-2016/GHB_I.XPT"
out = GHB_I;
run;

libname GHB xport "/home/u60678721/sasuser.v94/GHB_I.xpt";
data GHB; set GHB.GHB_I;
if LBXGH ne .;
keep SEQN LBXGH;
run;


* Importing DBQ_I which contains our main exposure SELF-REPORTED DIET (DBQ700) and removing missing
  values;

filename DBQ_I "/home/u60678721/sasuser.v94/DBQ_I.xpt";
proc http 
url = "https://wwwn.cdc.gov/Nchs/Nhanes/2015-2016/dbq_I.XPT"
out = DBQ_I;
run;

libname DBQ xport "/home/u60678721/sasuser.v94/DBQ_I.xpt";
data DBQ; set DBQ.DBQ_I;
if DBQ700 not in (.,7,9);
keep SEQN DBQ700;
run;


* Importing DEMO_I which contains the variables AGE (RIDAGEYR) & EDUCATION (DMDEDUC2). We are
  restricting age to 21-65 years to capture our population of interest and removing any missing 
  values;

filename DEMO_I "/home/u60678721/sasuser.v94/DEMO_I.xpt";
proc http 
url = "https://wwwn.cdc.gov/Nchs/Nhanes/2015-2016/DEMO_I.XPT"
out = DEMO_I;
run;

libname DEMO xport "/home/u60678721/sasuser.v94/DEMO_I.xpt";
data DEMO; set DEMO.DEMO_I;
if 21 le RIDAGEYR le 65;
if DMDEDUC2 not in (.,7,9);
keep SEQN RIDAGEYR DMDEDUC2 RIAGENDR;
run;


* Importing PAQ_I which contains the variable PHYSICAL ACTIVITY (PAQ665) and removing any missing
  values;
  
filename PAQ_I "/home/u60678721/sasuser.v94/PAQ_I.xpt";
proc http
url = "https://wwwn.cdc.gov/Nchs/Nhanes/2015-2016/PAQ_I.XPT"
out = PAQ_I;
run;

libname PAQ xport "/home/u60678721/sasuser.v94/PAQ_I.xpt";
data PAQ; set PAQ.PAQ_I;
if PAQ665 not in (.,7,9);
keep SEQN PAQ665;
run;


* Sorting our data files and merging them in the file "FINAL";

proc sort data = GHB;
by SEQN;
run;
proc sort data = DBQ;
by SEQN;
run;
proc sort data = DEMO;
by SEQN;
run;
proc sort data = PAQ;
by SEQN;
run;

data FINAL;
merge demo (in = a)
	PAQ (in = b)
	GHB (in = c)
	DBQ (in = d);
by SEQN;
if a and b and c and d;
run;

*
We have 3,975 observations in our merged data set called FINAL (See Abstract Methods and Table 1) ;



*
Part 2:
Operationalization of exposure, outcome, and confounders:

OUTCOME = GLYCOHEMOGLOBIN (dichotomous)
We are using glycohemoglobin levels to diagnose diabetes. 
Diabetes is defined as having a glycohemoglobin level of greater than or equal to 6.5%. 
Glycohemoglobin levels of less than 6.5% will not lead to a diagnosis of diabetes.

Exposure = DIET (dichotomous)
We are defining diet as "poor" and "not poor". 
A poor diet is defined as participants answering DBQ700-How healthy is the diet? as poor or fair.
All other responses to DBQ700 (good, very good, excellent) are categorized as "not poor".

Confounder #1 = EDUCATION (dichotomous)
We are defining education level as "high school graduate" and "college or above".
Individuals answering 1 (less than 9th grade), 2 (9-11th grade), 3 (high school graduate/GED or
equivalent) to DMDEDUC2 have their education level categorized as "high school graduate".
Individuals answering 4 (some college or AA degree), 5 (college graduate or above) to DMDEDUC2 have 
their education level categorized as "college or above".

Confounder #2 = PHYSICAL ACTIVITY (dichomotous)
The variable PAQ665 from the file PAQ_I asks about moderate recreational activities for 10 minutes
continuously in a week. We have used this as a proxy for how physically active the participants are.
The question is answered as "Yes" or "No".

Confounder #3 = AGE (continuous)
We are using age (variable RIDAGEYR from DEMO_I) as a continuous variable in the range of 21-65 years.
;

proc format;
value dbtsf 1 = 'Diabetes' 0 = 'No Diabetes';
value dietf 1 = 'Poor' 0 = 'Not Poor';
value eduf 1 = 'College or above' 0 = 'High school graduate';
value paqf 1 = 'Yes' 2 = 'No';
value sex 1 = 'Male' 2 = 'Female';
run;

data FINAL; set FINAL;
if LBXGH >= 6.5 then dbts_status = 1;
else if LBXGH < 6.5 then dbts_status = 0;
if DBQ700 in (4,5) then diet = 1;
else if DBQ700 in (1,2,3) then diet = 0;
if DMDEDUC2 in (1,2,3) then edu = 0;
else if DMDEDUC2 in (4,5) then edu = 1;
format dbts_status dbtsf. diet dietf. edu eduf. PAQ665 paqf. RIAGENDR sex.;
run;


*
Table 1 demographics;

*Sorting and checking the distribution of the variable diet in our data set; 
proc sort data = FINAL;
by diet;
run;

proc freq data = FINAL;
table diet;
run;

*
diet		Frequency	Percent		Cumulative Frequency	Cumulative Percent
Not Poor	2557		64.33			2557					64.33
Poor		1418		35.67			3975					100.00

(See Table 1)
;


*Checking age distributions and whether age differs significantly by diet category through a 
two-sample t-test;
proc means mean std data = FINAL; 
var RIDAGEYR;
by diet;
run;

*
					diet=Not Poor
					
Analysis Variable : RIDAGEYR Age in years at screening

				Mean			Std Dev
			43.3077826			13.0891187


						diet=Poor

Analysis Variable : RIDAGEYR Age in years at screening
				Mean			Std Dev
			42.8279267			12.8101609
			
(See Table 1)
;

proc ttest data = FINAL;
var  ridageyr;
class diet;
run;

*
Method	Variances	DF		t Value		Pr > |t|
Pooled	Equal		3973	1.12		0.2646

(See Table 1)
;


*Checking the distributions of the categorical variables education, physical activity, gender, and 
diabetes status and whether each of these variables differ significantly by diet category through a
Chi-square test;
proc freq data = FINAL;
table dbts_status edu PAQ665 RIAGENDR;
by diet;
run;

*
(See Table 1 for the following results)

For diet=Not Poor:

dbts_status		Frequency	Percent		Cumulative Frequency	Cumulative Percent
No Diabetes			2322	90.81			2322					90.81
Diabetes			235		9.19			2557					100.00


edu						Frequency	Percent		Cumulative Frequency	Cumulative Percent
High school graduate	950			37.15			950						37.15
College or above		1607		62.85			2557					100.00


						Moderate recreational activities
PAQ665		Frequency		Percent		Cumulative Frequency	Cumulative Percent
Yes				1264		49.43			1264					49.43
No				1293		50.57			2557					100.00


									Gender
RIAGENDR	Frequency	Percent		Cumulative Frequency	Cumulative Percent
Male		1229		48.06			1229					48.06
Female		1328		51.94			2557					100.00


For diet=Poor:

dbts_status		Frequency	Percent		Cumulative Frequency	Cumulative Percent
No Diabetes			1220	86.04				1220					86.04
Diabetes			198		13.96				1418					100.00


edu						Frequency		Percent		Cumulative Frequency	Cumulative Percent
High school graduate		774			54.58			774						54.58
College or above			644			45.42			1418					100.00


							Moderate recreational activities
PAQ665		Frequency	Percent		Cumulative Frequency	Cumulative Percent
Yes				452		31.88				452					31.88
No				966		68.12				1418				100.00


										Gender
RIAGENDR	Frequency		Percent		Cumulative Frequency	Cumulative Percent
Male			664			46.83			664						46.83
Female			754			53.17			1418					100.00
;

proc freq data = final;
table dbts_status*diet edu*diet PAQ665*diet RIAGENDR*diet /chisq;
run;

*
For dbts_status:
Statistic	DF		Value		Prob
Chi-Square	1		21.4076		<.0001

For edu:
Statistic	DF		Value		Prob
Chi-Square	1		112.8434	<.0001

For PAQ665:
Statistic	DF		Value		Prob
Chi-Square	1		114.6076	<.0001

For RIAGENDR:
Statistic	DF		Value		Prob
Chi-Square	1		0.5601		0.4542

(See Table 1)
;



* 
Part 3: 
Analysis.
  
We will calculate the prevalence ratio of diabetes, first for the crude model containing diet only,
followed by the adjusted model containing:
	1. Diet (main exposure)
	2. Education
	3. Physical activity
	4. Age
	
We will then look for confounding between the crude and adjusted estimates and assess whether 
age, education and physical activity confound the relationship between diet and diabetes.
;
  

/* CRUDE MODEL WITH DIET ONLY */

proc genmod data = FINAL;
class SEQN diet (ref = 'Not Poor') / param = ref;
model dbts_status (event = 'Diabetes') = diet/
link = log dist = poisson;
estimate 'Crude PR' diet 1;
repeated subject = SEQN/type = unstructured;
run;
  
* 
Crude PR and 95% CI = 1.5193 (1.2721, 1.8146) -- See Abstract Results and Table 1. 
The prevalence of diabetes among those who have a poor diet (reported as poor or fair) is 51.93% 
greater than those who do not have a poor diet (reported as good, very good, excellent). We 
are 95% confident the true prevalence is between 27.21% and 81.46%.
;


/* ADJUSTED MODEL WITH DIET, AGE, EDUCATION, AND PHYSICAL ACTIVITY */

proc genmod data = FINAL;
class SEQN diet (ref = 'Not Poor') edu (ref = 'High school graduate') PAQ665 (ref = 'Yes') / 
param = ref;
model dbts_status (event = 'Diabetes') = diet edu PAQ665 RIDAGEYR/
link = log dist = poisson;
estimate 'Adjusted PR' diet 1;
repeated subject = SEQN/type = unstructured;
run;

* 
Adjusted PR and 95% CI = 1.4790	(1.2422, 1.7609) -- See Abstract Results and Table 1.
The prevalence of diabetes among those who have a poor diet (reported as poor or fair) is 47.90% 
greater than those who do not have a poor diet (reported as good, very good, excellent), 
adjusting for age, education and physical activity. We are 95% confident the true prevalence is 
between 24.22% and 76.09%.
;
