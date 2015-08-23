# Getting_and_Cleaning_Data
Project for Coursera class "Getting and Cleaning Data"

### Overview

Run the script from directory 'UCI_HAR_Dataset.
Use the dplyr library for ease of calculation.
Data are available in the 'train' and 'test' directories.

Merge training and test data sets that contain Sasmsung sensor data.
Use descriptive column names for the sensor variables, with any special characters removed to prevent unwanted side-effects..
Distinguish duplicate column names by adding a numeric suffix, otherwise dplyr 'select' functions will fail..

### Make Data Frames
Make a character vector containing the cleaned variable names from file features_uniq.txt

Perform the following steps for both the 'train' and 'test' data.
* Load measurement data into a data frame.
* Apply the modified column names to columns 3 - 561.
* Load another data frame with the subject-activity data for each row of observation data.
* Change the names of the first two columns to "subject" and "Activity"
* Change activity numbers (1 - 6) to descriptive activity names
* Column bind the Subject-Activity data frame to the Measurement data frame.

### Calculate means and write data output
Stack the training and test data frames into a single data frame, and order it by subject number and alphabetized activity.
Create a new data frame (mean_std_frame) with subject, activity, and only those measurement columns that are either means or standard deviations (std).
Convert data frame 'mean_std_frame' to a table data frame ('msf').
Group 'msf' by Subject and Activity for calculating the tidy data means 
Calculate the mean of each non-grouped column with the 'summarise_each' operator.
Write out the tidy data frame of measseument means for each Subject-Activity group.

