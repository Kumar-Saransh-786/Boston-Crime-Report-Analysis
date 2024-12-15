# Boston-Crime-Report-Analysis
Our analysis utilizes a dataset sourced from the Boston Police Department's crime incident reports, which includes key details about crime incidents from 2015 to 2024. This report focuses on the years 2018, 2020, and 2022. We employ descriptive statistics, visualizations, and logistic regression modeling to uncover meaningful patterns.

Publisher: Department of Innovation and Technology 
Location: Boston (all)
Description: The dataset used in this report is sourced from the Boston Police Department’s (BPD) crime incident report system, which captures essential details about incidents to which BPD officers respond. Covering records from 2015 through 2024, the dataset focuses on documenting the type of crime, along with the time and location of each incident. This streamlined approach, part of a new system introduced in June 2015, reduces the number of fields, providing more concise information on each case.

Questions to Answer from the Dataset:
1. What types of offenses are more prevalent in each district?
2. If possible, which areas show the highest frequency of shootings?
3. Is there a trend for any particular months of the year where crimes occur?
4. Is there a trend in incidents depending on a day of the week?
5. How does time/hour of day affect the type of crimes reported?

Analytical Plans and Methods:
1. Time Series Analysis: this analyzes the crime incidence trend and patterns in time, month, day of the week, hour, etc., to see if criminal activities are temporally predisposed.
2. Geospatial Analysis: The latitudinal and longitudinal data provide information on heat maps or cluster analyses that were made to denote crime hotspots and how they relate to different districts or areas where reporting is from.
3. Chi-Square Test of Independence: This test is appropriate for various categorical variables on one or more dimensions. Such as the association between DISTRICT and SHOOTING.
4. Logistic Regression: this will model the probability of a shooting using the predictor variables that will be beneficial in pinning the causes leading to a serious incident.
