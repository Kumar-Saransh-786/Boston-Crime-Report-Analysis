
# Load necessary libraries
library(dplyr)
library(DataExplorer)
library(ggplot2)
library(readr)
library(gtsummary)
library(flextable)
library(gt)

# Read each CSV file into R
data_2018 <- read.csv("Z:/NEU/Intermediate Analytics/Module 2/Final Project - Proposal/crime report (2018-2022)/Crime Incident Reports - 2018.csv")
data_2020 <- read.csv("Z:/NEU/Intermediate Analytics/Module 2/Final Project - Proposal/crime report (2018-2022)/Crime Incident Reports - 2020.csv")
data_2022 <- read.csv("Z:/NEU/Intermediate Analytics/Module 2/Final Project - Proposal/crime report (2018-2022)/Crime Incident Reports - 2022.csv")

#-------------------------------------------------------------------------------------------------------------------------

# Displaying columns with blank ("") values in Plot
blank_percentage <- sapply(data_2018, function(x) sum(x == "", na.rm = TRUE)) / nrow(data_2018) * 100
blank_df <- data.frame(Column = names(blank_percentage), Blank_Percentage = blank_percentage)
blank_df <- subset(blank_df, Blank_Percentage > 0)

ggplot(blank_df, aes(x = reorder(Column, -Blank_Percentage), y = Blank_Percentage)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  theme_minimal() +
  labs(title = "Percentage of Blank Values in Each Column",
       x = "Columns",
       y = "Percentage of Blank Values") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Convert blank ("") values to NA in the entire dataframe
data_2018[data_2018 == ""] <- NA

data_2018$SHOOTING <- ifelse(data_2018$SHOOTING == "Y", 1, 0)
head(data_2018$SHOOTING)

#-------------------------------------------------------------------------------------------------------------------------

# Combine the datasets into one using rbind
combined_data <- bind_rows(data_2018, data_2020, data_2022)

# Save the combined data to a new CSV file
write.csv(combined_data, "Z:/NEU/Intermediate Analytics/Module 2/Final Project - Proposal/crime report (2018-2022)/Combined_Crime_Incident_Reports_2018_2022.csv", row.names = FALSE)

# Output a message to confirm the file was saved
cat("Combined CSV file saved successfully.")

#-------------------------------------------------------------------------------------------------------------------------

#column names
column_names <- names(combined_data)
print(column_names)

# Create SERIOUS_CRIME variable
combined_data$SERIOUS_CRIME <- as.numeric(combined_data$UCR_PART == "Part One")

#--------------------------------------------------------------------------------------------------------------------------

# Data checking

# Displaying columns with blank ("") values in Plot
blank_percentage <- sapply(combined_data, function(x) sum(x == "", na.rm = TRUE)) / nrow(combined_data) * 100
blank_df <- data.frame(Column = names(blank_percentage), Blank_Percentage = blank_percentage)
blank_df <- subset(blank_df, Blank_Percentage > 0)

ggplot(blank_df, aes(x = reorder(Column, -Blank_Percentage), y = Blank_Percentage)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  theme_minimal() +
  labs(title = "Percentage of Blank Values in Each Column",
       x = "Columns",
       y = "Percentage of Blank Values") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Convert blank ("") values to NA in the entire dataframe
combined_data[combined_data == ""] <- NA


# View missing data patterns
plot_missing(combined_data)

#--------------------------------------------------------------------------------------------------------------------------

# Data cleaning

# Checking for NA values in each column
colSums(is.na(combined_data))

# Remove rows with 50% or more NA values
threshold <- 0.5
combined_data <- combined_data %>%
  filter(rowMeans(is.na(.)) < threshold)

# Function to calculate the mode
calculate_mode <- function(x) {
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}

# Threshold for NA proportion
na_threshold <- 0.3

# Iterate over columns to clean data
df1 <- combined_data %>%
  mutate(across(everything(), ~ {
    # Calculate proportion of missing values
    na_proportion <- sum(is.na(.)) / n()
    
    if (na_proportion < na_threshold) {
      if (is.numeric(.)) {
        replace(., is.na(.), median(., na.rm = TRUE))
      } else {
        replace(., is.na(.), calculate_mode(na.omit(.)))
      }
    } else {
      . # Leave the column as is if NA proportion >= 30%
    }
  }))

# View missing data patterns
plot_missing(df1)

head(df1$SHOOTING)
# Print the mode of shooting column
print(calculate_mode(df1$SHOOTING))
# Replace NA values in df1$SHOOTING with 0
df1$SHOOTING[is.na(df1$SHOOTING)] <- 0

head(df1$SERIOUS_CRIME)
# Print the mode of SERIOUS_CRIME column
print(calculate_mode(df1$SERIOUS_CRIME))
# Replace NA values in df1$SERIOUS_CRIME with 0
df1$SERIOUS_CRIME[is.na(df1$SERIOUS_CRIME)] <- 0

head(df1$OFFENSE_CODE_GROUP)
print(calculate_mode(df1$OFFENSE_CODE_GROUP))
# Replace NA values in df1$OFFENSE_CODE_GROUP with "Other"
df1$OFFENSE_CODE_GROUP[is.na(df1$OFFENSE_CODE_GROUP)] <- "Other"

head(df1$UCR_PART)
print(calculate_mode(df1$UCR_PART))
# Replace NA values in df1$UCR_PART with "Other"
df1$UCR_PART[is.na(df1$UCR_PART)] <- "Other"

#--------------------------------------------------------------------------------------------------------------------------

# Create a mapping of district codes to district names
district_mapping <- c(
  "D4" = "South End",
  "A7" = "East Boston",
  "D14" = "Brighton",
  "B3" = "Mattapan",
  "A1" = "Downtown",
  "C6" = "South Boston",
  "A15" = "Charlestown",
  "E5" = "West Roxbury",
  "E18" = "Hyde Park",
  "B2" = "Roxbury",
  "C11" = "Dorchester",
  "E13" = "Jamaica Plain",
  "External" = "External"
)

# Create the new column DISTRICT_NAME
df1$DISTRICT_NAME <- district_mapping[df1$DISTRICT]

head(df1)

# Create a mapping of month numbers to month names
month_mapping <- c(
  "1" = "Jan",
  "2" = "Feb",
  "3" = "Mar",
  "4" = "Apr",
  "5" = "May",
  "6" = "Jun",
  "7" = "Jul",
  "8" = "Aug",
  "9" = "Sep",
  "10" = "Oct",
  "11" = "Nov",
  "12" = "Dec"
)

# Replace month numbers with month names
df1 <- df1 %>%
  mutate(MONTH = case_when(
    as.character(MONTH) %in% names(month_mapping) ~ month_mapping[as.character(MONTH)],
    is.na(MONTH) ~ "Unknown",
    TRUE ~ as.character(MONTH)
  ))

# Create MONTH_ID column
month_mapping <- c("Jan" = 1, "Feb" = 2, "Mar" = 3, "Apr" = 4, "May" = 5, "Jun" = 6,
                   "Jul" = 7, "Aug" = 8, "Sep" = 9, "Oct" = 10, "Nov" = 11, "Dec" = 12)
df1$MONTH_ID <- month_mapping[df1$MONTH]

# Create DAY_ID column
day_mapping <- c("Monday" = 1, "Tuesday" = 2, "Wednesday" = 3, "Thursday" = 4,
                 "Friday" = 5, "Saturday" = 6, "Sunday" = 7)
df1$DAY_ID <- day_mapping[df1$DAY_OF_WEEK]


# Create the HOUR_BINNING column
df1 <- df1 %>%
  mutate(HOUR_BINNING = cut(HOUR, 
                            breaks = c(-1, 4, 8, 12, 16, 20, 24), 
                            labels = c("12 a.m.- 4 a.m.", "4 a.m. - 8 a.m.", "8 a.m. - 12 p.m.", 
                                       "12 p.m. - 4 p.m.", "4 p.m. - 8 p.m.", "8 p.m. - 12 a.m."),
                            include.lowest = TRUE,
                            right = FALSE))

#----------------------------------------------------------------------------------------------------------------------------

names(df1)

# 1. Create summary table by Year for DISTRICT
district_summary <- df1 %>% 
  select(YEAR, DISTRICT_NAME) %>% 
  tbl_summary(by = YEAR,
              statistic = list(
                all_continuous() ~ "{mean} ({sd})",
                all_categorical() ~ "{n} ({p}%)"
              ),
              digits = all_continuous() ~ 2) %>%
  add_overall() %>%
  modify_header(label = "**Variable**") %>%
  modify_caption("Table 1. Descriptive Statistics of Boston Crime Incidents for Districts by Year (2018-2022)")
print(district_summary)

  # Convert gtsummary object to flextable and assign to a new variable
district_summary_flextable <- as_flex_table(district_summary)

  # Add formatting to flextable
district_summary_flextable <- district_summary_flextable %>%
  fontsize(size = 10, part = "all") %>%
  set_caption("Table 1. Descriptive Statistics of Boston Crime Incidents for Districts by Year (2018-2022)")
print(district_summary_flextable)

  # Export flextable to Word document
save_as_docx(district_summary_flextable, path = "district_summary_by_year.docx")

#--------------------------------------------------------------------------------------------------------------------------

# 2. Create summary table by Year for DAY_OF_WEEK
day_of_week_summary <- df1 %>% 
  select(YEAR, DAY_OF_WEEK) %>% 
  tbl_summary(by = YEAR,
              statistic = list(
                all_continuous() ~ "{mean} ({sd})",
                all_categorical() ~ "{n} ({p}%)"
              ),
              digits = all_continuous() ~ 2) %>%
  add_overall() %>%
  modify_header(label = "**Variable**") %>%
  modify_caption("Table 2. Descriptive Statistics of Boston Crime Incidents for Day of Week by Year (2018-2022)")
print(day_of_week_summary)  

  # Convert gtsummary object to flextable and assign to a new variable
day_of_week_summary_flextable <- as_flex_table(day_of_week_summary)

  # Add formatting to flextable
day_of_week_summary_flextable <- day_of_week_summary_flextable %>%
  fontsize(size = 10, part = "all") %>%
  set_caption("Table 2. Descriptive Statistics of Boston Crime Incidents for Day of Week by Year (2018-2022)")
print(day_of_week_summary_flextable)

  # Export flextable to Word document
save_as_docx(day_of_week_summary_flextable, path = "day_of_week_summary_by_year.docx")

#--------------------------------------------------------------------------------------------------------------------------

# 3. Create summary table by Year for UCR_PART
ucr_part_summary <- df1 %>% 
  select(YEAR, UCR_PART) %>% 
  tbl_summary(by = YEAR,
              statistic = list(
                all_continuous() ~ "{mean} ({sd})",
                all_categorical() ~ "{n} ({p}%)"
              ),
              digits = all_continuous() ~ 2) %>%
  add_overall() %>%
  modify_header(label = "**Variable**") %>%
  modify_caption("Table 3. Descriptive Statistics of Boston Crime Incidents for UCR Part by Year (2018-2022)")
print(ucr_part_summary)  

# Convert gtsummary object to flextable and assign to a new variable
ucr_part_summary_flextable <- as_flex_table(ucr_part_summary)

# Add formatting to flextable
ucr_part_summary_flextable <- ucr_part_summary_flextable %>%
  fontsize(size = 10, part = "all") %>%
  set_caption("Table 3. Descriptive Statistics of Boston Crime Incidents for UCR Part by Year (2018-2022)")
print(ucr_part_summary_flextable)

# Export flextable to Word document
save_as_docx(ucr_part_summary_flextable, path = "ucr_part_summary_by_year.docx")

#-------------------------------------------------------------------------------------------------------------------------

# 4. Create summary table by Year for MONTH
month_summary <- df1 %>% 
  select(YEAR, MONTH) %>% 
  tbl_summary(by = YEAR,
              statistic = list(
                all_continuous() ~ "{mean} ({sd})",
                all_categorical() ~ "{n} ({p}%)"
              ),
              digits = all_continuous() ~ 2) %>%
  add_overall() %>%
  modify_header(label = "**Variable**") %>%
  modify_caption("Table 4. Descriptive Statistics of Boston Crime Incidents for Months by Year (2018-2022)")
print(month_summary)  

# Convert gtsummary object to flextable and assign to a new variable
month_summary_flextable <- as_flex_table(month_summary)

# Add formatting to flextable
month_summary_flextable <- month_summary_flextable %>%
  fontsize(size = 10, part = "all") %>%
  set_caption("Table 4. Descriptive Statistics of Boston Crime Incidents for Months by Year (2018-2022)")
print(month_summary_flextable)

# Export flextable to Word document
save_as_docx(month_summary_flextable, path = "month_summary_by_year.docx")

#--------------------------------------------------------------------------------------------------------------------------

# 5. Create summary table by Year for Hour
hour_summary <- df1 %>% 
  select(YEAR, HOUR_BINNING) %>% 
  tbl_summary(by = YEAR,
              statistic = list(
                all_continuous() ~ "{mean} ({sd})",
                all_categorical() ~ "{n} ({p}%)"
              ),
              digits = all_continuous() ~ 2) %>%
  add_overall() %>%
  modify_header(label = "**Variable**") %>%
  modify_caption("Table 5. Descriptive Statistics of Boston Crime Incidents for Hours by Year (2018-2022)")

# Convert gtsummary object to flextable and assign to a new variable
hour_summary_flextable <- as_flex_table(hour_summary)

# Add formatting to flextable
hour_summary_flextable <- hour_summary_flextable %>%
  fontsize(size = 10, part = "all") %>%
  set_caption("Table 5. Descriptive Statistics of Boston Crime Incidents for Hours by Year (2018-2022)")
print(hour_summary_flextable)

# Export flextable to Word document
save_as_docx(hour_summary_flextable, path = "hour_summary_by_year.docx")

#---------------------------------------------------------------------------------------------------------------------------

library(sf) # Library For handling spatial data

# Load Boston district shapefile (replace with actual file path)
boston_map <- st_read("Z:/NEU/Intermediate Analytics/Module 4/Final Project - milestone 2/Boston Map shape file/police_districts/Police_Districts.shp")

# Prepare incident data by district
district_incidents <- df1 %>%
  group_by(DISTRICT) %>%
  summarise(Total_Incidents = n()) %>%
  mutate(
    Incident_Percentage = (Total_Incidents / sum(Total_Incidents)) * 100,
    Color_Code = case_when(
      Incident_Percentage <= 5 ~ "Green",
      Incident_Percentage > 5  & Incident_Percentage <= 10 ~ "Yellow",
      Incident_Percentage > 10 ~ "Red"
    )
  )
district_incidents

# Join the incident data with the Boston map
boston_map_data <- boston_map %>%
  left_join(district_incidents, by = c("DISTRICT" = "DISTRICT"))

# Ensure correct factor ordering for Color_Code
boston_map_data$Color_Code <- factor(boston_map_data$Color_Code, 
                                     levels = c("Green", "Yellow", "Red"))

# Plot the Boston map with corrected color levels
ggplot(boston_map_data) +
  geom_sf(aes(fill = Color_Code), color = "black", size = 0.2) +
  geom_sf_text(aes(label = ID), color = "black", size = 3) +  # Add district labels
  scale_fill_manual(
    values = c("Green" = "green", "Yellow" = "yellow", "Red" = "red"),
    name = "Incident Levels",
    labels = c("Less Crime", "Moderate Crime", "High Crime")
  ) +
  labs(
    title = "Boston Crime Incidents by District",
    x = "Longitude",
    y = "Latitude",
    subtitle = "Color-coded based on total incidents",
    caption = "Data source: Boston Police Department"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    plot.title = element_text(hjust = 0.5),  # Center-align title
    plot.subtitle = element_text(hjust = 0.5),  # Center-align subtitle
    plot.caption = element_text(hjust = 0.5),  # Center-align caption
    legend.position = "right"  # Move legend to the right
  )

#----------------------------------------------------------------------------------------------------------------------------

# Prepare shooting data by district
district_shootings <- df1 %>%
  group_by(DISTRICT) %>%
  summarise(Total_Shootings = sum(SHOOTING)) %>%
  mutate(
    Shooting_Percentage = (Total_Shootings / sum(Total_Shootings)) * 100,
    Color_Code = case_when(
      Shooting_Percentage <= 5 ~ "Green",
      Shooting_Percentage > 5 & Shooting_Percentage <= 10 ~ "Yellow",
      Shooting_Percentage > 10 ~ "Red"
    )
  )
district_shootings

# Join the shooting data with the Boston map
boston_map_data <- boston_map %>%
  left_join(district_shootings, by = c("DISTRICT" = "DISTRICT"))

# Ensure correct factor ordering for Color_Code
boston_map_data$Color_Code <- factor(boston_map_data$Color_Code, 
                                     levels = c("Green", "Yellow", "Red"))

# Plot the Boston map with shooting data
ggplot(boston_map_data) +
  geom_sf(aes(fill = Color_Code), color = "black", size = 0.2) +
  geom_sf_text(aes(label = ID), color = "black", size = 3) +  # Add district labels
  scale_fill_manual(
    values = c("Green" = "green", "Yellow" = "yellow", "Red" = "red"),
    name = "Shooting Levels",
    labels = c("Less Shootings", "Moderate Shootings", "High Shootings")
  ) +
  labs(
    title = "Boston Shootings by District",
    x = "Longitude",
    y = "Latitude",
    subtitle = "Color-coded based on total shootings",
    caption = "Data source: Boston Police Department"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    plot.title = element_text(hjust = 0.5),
    plot.subtitle = element_text(hjust = 0.5),
    plot.caption = element_text(hjust = 0.5),
    legend.position = "right"
  )

#---------------------------------------------------------------------------------------------------------------------

# Question 1: What are the top 10 crimes in Boston?

# create Treemap of Offense Code Groups
library(treemapify)

# Filter out 'Other' from OFFENSE_CODE_GROUP
crime_filtered <- df1 %>%
  filter(OFFENSE_CODE_GROUP != "Other")

# Rename the specific value in the OFFENSE_CODE_GROUP column
crime_filtered <- crime_filtered %>%
  mutate(OFFENSE_CODE_GROUP = ifelse(OFFENSE_CODE_GROUP == "Motor Vehicle Accident Response", 
                                     "Vehicle Accident", 
                                     OFFENSE_CODE_GROUP))
# Prepare data for treemap
offense_group_summary <- crime_filtered %>%
  group_by(OFFENSE_CODE_GROUP) %>%
  summarise(count = n()) %>%
  arrange(desc(count))
offense_group_summary

# Create treemap
ggplot(offense_group_summary, aes(area = count, fill = OFFENSE_CODE_GROUP, label = paste(OFFENSE_CODE_GROUP, count, sep = "\n"))) +
  geom_treemap() +
  geom_treemap_text(fontface = "plain", colour = "black", place = "centre", grow = FALSE) +
  labs(title = "Treemap of Offense Code Groups") +
  theme(legend.position = "none",
        plot.title = element_text(hjust = 0.5)  # Center-align title
  )

# Find top 10 crimes
top_10_crimes <- crime_filtered %>%
  group_by(OFFENSE_CODE_GROUP) %>%
  summarise(count = n()) %>%
  arrange(desc(count)) %>%
  top_n(10, count) %>%
  mutate(percentage = count / sum(count) * 100)
top_10_crimes

# Plot top 10 crimes with colors based on OFFENSE_CODE_GROUP
ggplot(top_10_crimes, aes(x = reorder(OFFENSE_CODE_GROUP, -count), y = percentage, fill = OFFENSE_CODE_GROUP)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = sprintf("%.1f%%", percentage)), vjust = -0.5) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "none", # Hides the legend for a cleaner look (optional)
    plot.title = element_text(hjust = 0.5)  # Center-align title
  ) +
  labs(
    title = "Top 10 Crimes in Boston (2018-2022)",
    x = "Offense Code Group",
    y = "Percentage of Total Crimes"
  )

#---------------------------------------------------------------------------------------------------------------------------

# Question 2: What types of offenses are more prevalent in each district?

# Aggregate each district's most common offenses
district_crime <- crime_filtered %>%
  group_by(DISTRICT_NAME, OFFENSE_CODE_GROUP) %>%
  summarise(counts = n()) %>%
  arrange(DISTRICT_NAME, desc(counts))

# For each district, get the offense with the maximum count
most_common_crime_by_district <- district_crime %>%
  group_by(DISTRICT_NAME) %>%
  slice_max(order_by = counts, n = 1)
print(most_common_crime_by_district)

# Create a flextable from the summary
most_common_crime_table <- flextable(most_common_crime_by_district) %>%
  set_header_labels(
    DISTRICT_NAME = "District",
    OFFENSE_CODE_GROUP = "Most Common Offense",
    counts = "Number of Incidents"
  ) %>%
  theme_vanilla() %>%  # Apply a clean table style
  autofit() %>%        # Adjust column widths to fit content
  add_header_lines("Most Common Crimes by District") %>%
  align(i = 1, part = "header", align = "center")  # Center-align the title


# Print the flextable
most_common_crime_table

# Find top 3 crimes
top_3_crimes <- crime_filtered %>%
  group_by(OFFENSE_CODE_GROUP) %>%
  summarise(count = n()) %>%
  arrange(desc(count)) %>%
  top_n(3, count) %>%
  mutate(percentage = count / sum(count) * 100)
top_3_crimes

# Filter data for top 3 crimes in each district
top_3_crimes_in_districts <- crime_filtered %>%
  filter(OFFENSE_CODE_GROUP %in% top_3_crimes$OFFENSE_CODE_GROUP) %>%
  group_by(DISTRICT_NAME, OFFENSE_CODE_GROUP) %>%
  summarise(count = n(), .groups = "drop")

# Plot the data
ggplot(top_3_crimes_in_districts, aes(x = DISTRICT_NAME, y = count, fill = OFFENSE_CODE_GROUP)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(
    title = "Top 3 Crimes in each Districts (2018-2022)",
    x = "District",
    y = "Total Incidents",
    fill = "Offense Code Group"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    plot.title = element_text(hjust = 0.5)  # Center-align title
  )

#---------------------------------------------------------------------------------------------------------------------------

# Question 3: Is there a trend in total incident/shooting depending on a day of the week?

df1$DAY_OF_WEEK <- factor(
  df1$DAY_OF_WEEK,
  levels = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")
)

# Summarize incidents by DAY_OF_WEEK and YEAR
incidents_by_day <- df1 %>%
  group_by(DAY_OF_WEEK, YEAR) %>%
  summarise(Total_Incidents = n(), .groups = "drop") %>%
  arrange(DAY_OF_WEEK, YEAR)

# Create the line plot
ggplot(incidents_by_day, aes(x = DAY_OF_WEEK, y = Total_Incidents, group = YEAR, color = factor(YEAR))) +
  geom_line(size = 1) +
  labs(
    title = "Trend of Incidents by Day of the Week by Year",
    x = "Day of the Week",
    y = "Total Incidents",
    color = "Year"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    plot.title = element_text(hjust = 0.5)  # Center-align title
  )

# Summarize shooting incidents by DAY_OF_WEEK and YEAR
shootings_by_day <- df1 %>%
  filter(SHOOTING == 1) %>%  # Filter for shooting incidents
  group_by(DAY_OF_WEEK, YEAR) %>%
  summarise(Total_Shootings = n(), .groups = "drop") %>%
  arrange(DAY_OF_WEEK, YEAR)

# Create the line plot for shootings
ggplot(shootings_by_day, aes(x = DAY_OF_WEEK, y = Total_Shootings, group = YEAR, color = factor(YEAR))) +
  geom_line(size = 1) +
  geom_point(size = 3) +  # Add points for better visibility
  labs(
    title = "Trend of Shooting Incidents by Day of the Week by Year",
    x = "Day of the Week",
    y = "Total Shooting Incidents",
    color = "Year"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    plot.title = element_text(hjust = 0.5)  # Center-align title
  ) +
  scale_y_continuous(breaks = scales::pretty_breaks())  # Ensure appropriate y-axis breaks

#---------------------------------------------------------------------------------------------------------------------------

# Question 4: Which areas show the highest frequency of shooting?

# Subset analysis by district
district_analysis <- df1 %>%
  group_by(YEAR, DISTRICT_NAME) %>%
  summarise(
    Total_Incidents = n(),
    Shootings = sum(SHOOTING, na.rm = TRUE)
  ) %>%
  arrange(YEAR, desc(Total_Incidents))
print(district_analysis)

# Visualization: Shootings by year and district
ggplot(district_analysis, aes(x = DISTRICT_NAME, y = Shootings, fill = factor(YEAR))) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Total Shootings by District and Year (2018-2022)", x = "District", y = "Total Shootings") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        plot.title = element_text(hjust = 0.5)  # Center-align title
  )

#--------------------------------------------------------------------------------------------------------------------------

# Question 5: How does time/hour of day affect the type of crimes reported?

# Summarize incidents by HOUR and YEAR
crime_by_hour <- df1 %>%
  group_by(HOUR, YEAR) %>%
  summarise(Total_Incidents = n(), .groups = "drop") %>%
  arrange(HOUR, YEAR)

# Create the line plot
ggplot(crime_by_hour, aes(x = HOUR, y = Total_Incidents, group = YEAR, color = factor(YEAR))) +
  geom_line(size = 1) +
  geom_point(size = 2) +
  labs(
    title = "Total Incidents by Hour of the Day by Year (2018-2022)",
    x = "Hour of the Day",
    y = "Total Incidents",
    color = "Year"
  ) +
  scale_x_continuous(
    breaks = seq(0, 24, by = 2),  # Set x-axis breaks from 0 to 24 with steps of 2
    limits = c(0, 24)             # Ensure the axis spans from 0 to 24
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    plot.title = element_text(hjust = 0.5)  # Center-align title
  )

# Subset analysis by time of day
time_analysis <- df1 %>%
  group_by(YEAR, HOUR_BINNING) %>%
  summarise(
    Total_Incidents = n(),
    Shootings = sum(SHOOTING, na.rm = TRUE)
  ) %>%
  arrange(YEAR, desc(Total_Incidents))
print(time_analysis)

# Visualization: Shootings by time of day
ggplot(time_analysis, aes(x = HOUR_BINNING, y = Shootings, fill = factor(YEAR))) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Shootings by Time of Day and year (2018-2022)", x = "Time of Day", y = "Total Shooting") +
  theme_minimal()+
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        plot.title = element_text(hjust = 0.5)  # Center-align title
  )

#---------------------------------------------------------------------------------------------------------------------------

# Question 6: Is there a trend for any particular months of the year where crimes occur?

# Summarize incidents by MONTH and YEAR
incidents_by_month <- df1 %>%
  group_by(MONTH, YEAR) %>%
  summarise(Total_Incidents = n(), .groups = "drop") %>%
  arrange(MONTH, YEAR)

# Create the line plot
ggplot(incidents_by_month, aes(x = MONTH, y = Total_Incidents, group = YEAR, color = factor(YEAR))) +
  geom_line(size = 1) +
  geom_point(size = 2)+
    labs(
    title = "Trend of Incidents by Month by Year",
    x = "Month",
    y = "Total Incidents",
    color = "Year"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    plot.title = element_text(hjust = 0.5)  # Center-align title
  )

# Summarize shooting incidents by MONTH and YEAR
shootings_by_month <- df1 %>%
  filter(SHOOTING == 1) %>%  # Filter for shooting incidents
  group_by(MONTH, YEAR) %>%
  summarise(Total_Shootings = n(), .groups = "drop") %>%
  arrange(MONTH, YEAR)

# Create the line plot for shootings
ggplot(shootings_by_month, aes(x = MONTH, y = Total_Shootings, group = YEAR, color = factor(YEAR))) +
  geom_line(size = 1) +
  geom_point(size = 3) +  # Increased point size for better visibility
  labs(
    title = "Trend of Shooting by Month and Year",
    x = "Month",
    y = "Total Shooting Incidents",
    color = "Year"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    plot.title = element_text(hjust = 0.5)  # Center-align title
  ) +
  scale_x_discrete(limits = month.abb) +  # Use month abbreviations on x-axis
  scale_y_continuous(breaks = scales::pretty_breaks())  # Ensure appropriate y-axis breaks

#-------------------------------------------------------------------------------------------------------------------------

# Chi-Square Test: Association between DISTRICT and OFFENSE_CODE_GROUP
chi_square_test <- chisq.test(table(df1$DISTRICT_NAME, df1$OFFENSE_CODE_GROUP))
print(chi_square_test)

# Chi-square test for association between district and shootings
chi_square_test <- chisq.test(table(df1$DISTRICT, df1$SHOOTING))
print(chi_square_test)

# ANOVA: Compare mean differences in HOUR across different DISTRICTS
anova_model <- aov(HOUR ~ DISTRICT_NAME, data = df1)
summary(anova_model)

#--------------------------------------------------------------------------------------------------------------------------

# Load necessary libraries
library(corrplot)

# Select numeric columns for correlation analysis
numeric_columns <- df1 %>%
  select_if(is.numeric)  # Select only numeric columns

# Compute correlation matrix
correlation_matrix <- cor(numeric_columns, use = "complete.obs")

# View the correlation matrix
print("Correlation Matrix:")
print(correlation_matrix)

# Visualize the correlation matrix using corrplot
corrplot(correlation_matrix, method = "color", 
         col = colorRampPalette(c("red", "white", "green"))(200),
         addCoef.col = "black", number.cex = 0.8, tl.col = "black", tl.cex = 0.8)

#--------------------------------------------------------------------------------------------------------------------------

# Load required libraries
library(caret)
library(pROC)
library(broom)
library(MASS)

# Split the data into training and testing sets
set.seed(123)
train_index <- createDataPartition(df1$SHOOTING, p = 0.7, list = FALSE)
train_data <- df1[train_index, ]
test_data <- df1[-train_index, ]

head(df1)
names(df1)

# Model-1: Full model with all predictors
model1 <- glm(SHOOTING ~ DISTRICT + REPORTING_AREA + YEAR + HOUR + OFFENSE_CODE + DAY_ID + MONTH_ID,
                     data = train_data, family = "binomial")
summary(model1)

# Model-2: Reduced model with selected predictors
model2 <- glm(SHOOTING ~ DISTRICT + DAY_OF_WEEK + MONTH + HOUR_BINNING + OFFENSE_CODE_GROUP,
                     data = train_data, family = "binomial")
summary(model2)

#---------------------------------------------------------------------------------------------------------------------------

# Compare models using flextable:

# Function to calculate adjusted R-squared for logistic regression
logistic_pseudo_r2 <- function(model) {
  1 - model$deviance / model$null.deviance
}

# Function to get model statistics
get_model_stats <- function(model) {
  glance_data <- glance(model)
  tibble(
    Model = deparse(substitute(model)),
    `Adj R-squared` = round(logistic_pseudo_r2(model), 4),
    AIC = round(glance_data$AIC, 2),
    BIC = round(glance_data$BIC, 2)
  )
}

# Combine statistics for both models
model_comparison <- bind_rows(
  Model1 = get_model_stats(model1),
  Model2 = get_model_stats(model2)
)

# Create flextable
comparison_table <- flextable(model_comparison) %>%
  theme_vanilla() %>%
  autofit() %>%
  bold(part = "header") %>%
  set_caption("Comparison of Logistic Regression Models")

# Print the table
comparison_table

# Export flextable to Word document
save_as_docx(comparison_table, path = "Comparison of Logistic Regression Models.docx")

#--------------------------------------------------------------------------------------------------------------------------

# Function to create confusion matrix for Model-2
create_confusion_matrix <- function(model, data) {
  predictions <- predict(model, newdata = data, type = "response")
  predicted_classes <- ifelse(predictions > 0.5, 1, 0)
  conf_matrix <- table(Actual = data$SHOOTING, Predicted = predicted_classes)
  return(conf_matrix)
}

# Confusion matrices for training set
train_cm_model2 <- create_confusion_matrix(model2, train_data)

# Print confusion matrices (Training Set)
print("Confusion Matrix for Model 2 (Training Set):")
print(train_cm_model2)

# Confusion matrices for test set
test_cm_model2 <- create_confusion_matrix(model2, test_data)

# Print confusion matrices (Test Set)
print("Confusion Matrix for Model 2 (Test Set):")
print(test_cm_model2)

#----------------------------------------------------------------------------------------------------------------------------

# Make predictions on the test set
test_pred <- predict(model2, newdata = test_data, type = "response")

# Create ROC curve
roc_obj <- roc(test_data$SHOOTING, test_pred)

# Plot ROC curve
plot(roc_obj, main = "ROC Curve for Model 2 (Test Set)", 
     col = "blue", lwd = 2,
     print.auc = TRUE, auc.polygon = TRUE, grid = TRUE)



