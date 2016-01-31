## use reshape library to be able to stack columns and cast into new dataframe
library(reshape2)
filename <- "dataset.zip"

## Download the dataset:

if (!file.exists(filename)){
  
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  
  download.file(fileURL, filename, method="curl")
  
}
## unzip the dataset:
if (!file.exists("UCI HAR Dataset")) {
  
  unzip(filename)
  
}

# Load features
features <- read.table("UCI HAR Dataset/features.txt")
## Get second column
features[,2] <- as.character(features[,2])

## Load activity labels
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])


# Extract only the data on mean and standard deviation, grep for char string 
featuresNeed <- grep(".*mean.*|.*std.*", features[,2])
featuresNeed.names <- features[featuresNeed,2]
##then extract features needed just the mean
featuresNeed.names = gsub('-mean', 'Mean', featuresNeed.names)
featuresNeed.names = gsub('-std', 'Std', featuresNeed.names)
## Remove the "-" and "()"
featuresNeed.names <- gsub('[-()]', '', featuresNeed.names)

## Load the train datasets

train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresNeed]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
##Combine the train datasets
train <- cbind(trainSubjects, trainActivities, train)

##Load the test datasets
test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresNeed]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
##Combine the test datasets
test <- cbind(testSubjects, testActivities, test)

# merge train and test datasets and add labels to get an overall dataset
allData <- rbind(train, test)
##rename columns in order
colnames(allData) <- c("subject", "activity", featuresNeed.names)

# turn activities & subjects into factors and get levels of Activities
allData$activity <- factor(allData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
allData$subject <- as.factor(allData$subject)
## Melt data and stack column using subject and activity
allData.melted <- melt(allData, id = c("subject", "activity"))
## cast new data into data frame using subject+activity
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)

##Write the final dataset with average(mean),each variable,each activity and each subject
write.table(allData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)