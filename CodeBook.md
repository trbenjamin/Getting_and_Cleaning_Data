### Main Script
run_analysis.R
	execute in R-Studio with command: source('./run_analysis.R')

### Data Input and Variables
Files: directory =  'train'     directory = 'test'
           subject_train.txt        subject_test.txt
           X_train.txt              X_test.txt
           y_train.txt              y_test.txt

# Use a feature file with duplicate names differentiated, otherwise dplyr select statements can fail.
# Also, remove parentheses from column names, which will cause unwanted side effecs in R statements.
# Python script rmdups.py produces file 'features_uniq.txt' with 'features.txt' as input.

featureFile       <- './features_uniq.txt'
    This file is derived from features.txt, with special characters removed and duplicate vatiable names disambiguated.

trainDataFile     <- './train/X_train.txt'
trainSubjectsFile <- './train/subject_train.txt' 
trainActivityFile <- './train/y_train.txt'

testDataFile      <- './test/X_test.txt'
testSubjectsFile  <- './test/subject_test.txt' 
testActivityFile  <- './test/y_test.txt'

# Function to read file data into data frames
get_data <- function(datFile) {
        read.table(datFile, stringsAsFactors = FALSE, header = FALSE)
}

# Function to replace activity numbers 1-6 with descriptive activity names
labelActivity <- function(x) {
        if      (x == 1) { return ( "WALKING" ) }
        else if (x == 2) { return ( "WALKING_UPSTAIRS" ) }
        else if (x == 3) { return ( "WALKING_DOWNSTAIRS" ) }
        else if (x == 4) { return ( "SITTING" ) }
        else if (x == 5) { return ( "STANDING" ) }
        else if (x == 6) { return ( "LAYING" ) }
        else             { return ( "UNKNOWN" ) }
}

        featureNames          <- get_data(featureFile)

### training data ###
        trainData             <- get_data(trainDataFile)
        trainSubjects         <- get_data(trainSubjectsFile)
        trainActivity         <- get_data(trainActivityFile)
        trainSubjectsActivity <- cbind(trainSubjects, trainActivity)
 
### test data. ###
        testData              <- get_data(testDataFile)
        testSubjects          <- get_data(testSubjectsFile)
        testActivity          <- get_data(testActivityFile)
        testSubjectsActivity  <- cbind(testSubjects, testActivity)

# Naming the first two columns "subject" and "Activity"
        colnames(trainSubjectsActivity) <- c("subject", "Activity")

# Change activity numbers to descriptive names
        trainSubjectsActivity[,2] <- sapply(trainSubjectsActivity[,2], labelActivity)

# Add feature labels (variable names) to the data
        colnames(trainData) <- featureNames[,2]

# Bind subject and activity columns to observation data
        new_train             <- cbind(trainSubjectsActivity, trainData)

# Naming the first two columns "subject" and "Activity"
        colnames(testSubjectsActivity)  <- c("subject", "Activity")
        
# Change activity numbers to descriptive names
        testSubjectsActivity[,2] <- sapply(testSubjectsActivity[,2], labelActivity) 

# Add feature labels (variable names) to the data
        colnames(testData) <- featureNames[,2]

# Bind subject and activity columns to observation data
        new_test              <- cbind(testSubjectsActivity, testData)

### Stack the training and test data frames into a single data frame, and order
### it by subject number and alphabetized activity.

        allData <- rbind(new_train, new_test)
        allData2 <- allData[order(allData$subject, allData$Activity), ]

# Next, select all columns that are a 'mean' or 'sd' measurement.
# Get the column names of the data frame.
ad2names <- colnames(allData2)

# Get the indices of 'mean' and 'std' columns.
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
