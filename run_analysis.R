## Script run_analysis.R ##
#  Files: directory =  'train'     directory = 'test'
#             subject_train.txt        subject_test.txt
#             X_train.txt              X_test.txt
#             y_train.txt              y_test.txt

# Use the dplyr library
library(dplyr)

# Use a feature file with duplicate names differentiated, otherwise dplyr select statements can fail.
# Also, remove parentheses from column names, which will cause unwanted side effecs in R statements.
# Python script rmdups.py produces file 'features_uniq.txt' with 'features.txt' as input.

#featureFile       <- './features.txt'
featureFile       <- './features_uniq.txt'

trainDataFile     <- './train/X_train.txt'
trainSubjectsFile <- './train/subject_train.txt' 
trainActivityFile <- './train/y_train.txt'

testDataFile      <- './test/X_test.txt'
testSubjectsFile  <- './test/subject_test.txt' 
testActivityFile  <- './test/y_test.txt'

get_data <- function(datFile) {
        read.table(datFile, stringsAsFactors = FALSE, header = FALSE)
}

labelActivity <- function(x) {
        if      (x == 1) { return ( "WALKING" ) }
        else if (x == 2) { return ( "WALKING_UPSTAIRS" ) }
        else if (x == 3) { return ( "WALKING_DOWNSTAIRS" ) }
        else if (x == 4) { return ( "SITTING" ) }
        else if (x == 5) { return ( "STANDING" ) }
        else if (x == 6) { return ( "LAYING" ) }
        else             { return ( "UNKNOWN" ) }
}

# Prepare the tidy data sets

        featureNames          <- get_data(featureFile)

### First prepare the training data ###
        trainData             <- get_data(trainDataFile)
        trainSubjects         <- get_data(trainSubjectsFile)
        trainActivity         <- get_data(trainActivityFile)
        trainSubjectsActivity <- cbind(trainSubjects, trainActivity)
 
# Change the names of the first two columns to "subject" and "Activity"
        colnames(trainSubjectsActivity) <- c("subject", "Activity")

# Change activity numbers to descriptive names
        trainSubjectsActivity[,2] <- sapply(trainSubjectsActivity[,2], labelActivity)

# Add feature labels to the data
        colnames(trainData) <- featureNames[,2]

# Add the subject and activity columns to the data
        new_train             <- cbind(trainSubjectsActivity, trainData)


### Next prepare the test data. ###
        testData              <- get_data(testDataFile)
        testSubjects          <- get_data(testSubjectsFile)
        testActivity          <- get_data(testActivityFile)
        testSubjectsActivity  <- cbind(testSubjects, testActivity)

# Change the names of the first two columns to "subject" and "Activity"
        colnames(testSubjectsActivity)  <- c("subject", "Activity")
        
# Change activity numbers to descriptive names
        testSubjectsActivity[,2] <- sapply(testSubjectsActivity[,2], labelActivity) 

# Add feature labels to the data
        colnames(testData) <- featureNames[,2]

# Add the subject and activity columns to the data
        new_test              <- cbind(testSubjectsActivity, testData)

### Stack the training and test data frames into a single data frame, and order
### it by subject number and alphabetized activity.

        allData <- rbind(new_train, new_test)
        allData2 <- allData[order(allData$subject, allData$Activity), ]

# Next, select all columns that are a 'mean' or 'sd' measurement.
# Get the column names of the data frame.
ad2names <- colnames(allData2)

# Get the indices of the columns desired.
mean_idx <- grep('mean', ad2names)
std_idx  <- grep('std', ad2names)

# Create a new data frame that retains only the 'mean' and 'std' columns.
mean_std_frame <- select(allData2, 1:2, union(mean_idx, std_idx) )

# Convert data frame 'mean_std_frame' to a table data frame.
msf <- tbl_df(mean_std_frame)

# Group 'msf' by subject and Activity for calculating the tidy data means 
msf <- tbl_df(mean_std_frame)
by_sa <- group_by(msf, subject, Activity)

# Calculate the mean of each non-grouped column with the 'summarise_each' operator.
tidy_means <- summarise_each(by_sa, funs(mean))

# Write out the data frame of tidy means.
write.table(tidy_means, row.names = FALSE, file = './tidyMeans.txt')
