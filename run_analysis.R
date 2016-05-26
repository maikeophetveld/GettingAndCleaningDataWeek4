
## 1. General settings
## use required library
library(reshape2)

## save filename of zip folder in parameter
filename <- "getdata_dataset.zip"

## 2. Prepare files in directory

## Download and unzip the dataset if the zip file is not downloaded or extracted yet
if ( !file.exists( filename ) ) {
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file( fileURL, filename, mode = "wb" )
}  
if ( !file.exists( "UCI HAR Dataset" ) ) { 
  unzip( filename ) 
}

## 2. Load activity labels + features for dataset
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

## 3. Save features that are necessary: mean and standard deviation
featuresRequired <- grep( ".*mean.*|.*std.*", features[,2] )
featuresRequired.names <- features[featuresRequired,2]
featuresRequired.names = gsub( '-mean', 'Mean', featuresRequired.names )
featuresRequired.names = gsub( '-std', 'Std', featuresRequired.names )
featuresRequired.names <- gsub( '[-()]', '', featuresRequired.names )

## 4. Load the datasets filtered for the required features
train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresRequired]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresRequired]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

## 5. merge datasets and add labels
allData <- rbind(train, test)
colnames(allData) <- c("subject", "activity", featuresRequired.names)

## 6. Create factors for activity and subject
allData$activity <- factor(allData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
allData$subject <- as.factor(allData$subject)

## 7. Reshape the data
allData.melted <- melt(allData, id = c("subject", "activity"))
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)

## 8. Export data
write.table(allData.mean, "cleaned_data.txt", row.names = FALSE, quote = FALSE)
