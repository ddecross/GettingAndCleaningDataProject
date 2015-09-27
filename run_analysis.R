##-----------------------------------------------------------##
##                                                           ##
## 20150919 Doug DeCross                                     ##
##          This code will meet the requirements for the     ##
##          Coursera project in the Getting and Cleaning data##
##          class.  The stated requirements for this program ## 
##          are:                                             ##
##          1.  You should create one R script called        ##
##              run_analysis.R that does the following.      ##
##          2.  Merges the training and the test sets to     ##
##              create one data set.                         ##
##          3.  Extracts only the measurements on the mean   ##
##              and standard deviation for each measurement. ##
##          4.  Uses descriptive activity names to name the  ##
##              activities in the data set                   ##
##          5.  Appropriately labels the data set with       ##
##              descriptive variable names.                  ##
##          6.  From the data set in step 4, creates a       ##
##              second, independent tidy data set with the   ##
##              average of each variable for each activity   ##
##              and each subject.                            ##
##                                                           ##
##-----------------------------------------------------------##

## Set up testing code
vtesting <- FALSE
vinstall.libs <- FALSE

## Bring the test datasets down into ./data/GCProject.zip
## Unloaded into ./data/GCProject

## download.file(url="https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", destfile="./data/GCProject.zip")

if (vinstall.libs) install.packages("data.table")
if (vinstall.libs) install.packages("plyr")
if (vinstall.libs) install.packages("sqldf")

if (vinstall.libs) library(data.table)
if (vinstall.libs) library(plyr)
if (vinstall.libs) library(sqldf)
if (vinstall.libs) library(reshape2)

## Read in the tables in Test
x_test <- read.table(file="./data/GCProject/UCI HAR Dataset/test/x_test.txt", header=FALSE)
y_test <- read.table(file="./data/GCProject/UCI HAR Dataset/test/y_test.txt", header=FALSE)
sub_test <- read.table(file="./data/GCProject/UCI HAR Dataset/test/subject_test.txt", header=FALSE)

if (vtesting) head(x_test, 2)
if (vtesting) head(y_test, 2)
if (vtesting) head(sub_test, 2)

## Read in the tables in Train
x_train <- read.table(file="./data/GCProject/UCI HAR Dataset/train/x_train.txt", header=FALSE)
y_train <- read.table(file="./data/GCProject/UCI HAR Dataset/train/y_train.txt", header=FALSE)
sub_train <- read.table(file="./data/GCProject/UCI HAR Dataset/train/subject_train.txt", header=FALSE)

if (vtesting) head(x_train, 2)
if (vtesting) head(y_train, 2)
if (vtesting) head(sub_train, 2)

## Read in column names from features.txt
feat <- read.table(file="./data/GCProject/UCI HAR Dataset/features.txt", header=FALSE)

if (vtesting) head(feat)

## Read in "Links the class labels with their activity name."
lab <- read.table(file="./data/GCProject/UCI HAR Dataset/activity_labels.txt", header=FALSE)
if (vtesting) head(lab, 2)

## Assign column names to columns
names(x_test) <- feat[,2]
names(x_train) <- feat[,2]

y_test <- rename(y_test, replace = c("V1" = "activity.code"))
y_train <- rename(y_train, replace = c("V1" = "activity.code"))

sub_test <- rename(sub_test, replace = c("V1" = "subject.id"))
sub_train <- rename(sub_train, replace = c("V1" = "subject.id"))

lab <- rename(lab, replace = c("V1" = "lab.code", "V2" = "lab.desc"))

if (vtesting) names(y_test)
if (vtesting) names(y_train)

if (vtesting) names(sub_test)
if (vtesting) names(sub_train)

if (vtesting) names(lab)

## Combine all data for Test and Train

s.test.data <- data.frame(x_test, y_test, sub_test)
s.train.data <- data.frame(x_train, y_train, sub_train)

if (vtesting) names(s.test.data)
if (vtesting) names(s.train.data)

## Convert Data Frames to tables
s.test.data <- data.table(s.test.data)
s.train.data <- data.table(s.train.data)
s.lab.data <- data.table(lab)

if (vtesting) class(s.test.data)
if (vtesting) class(s.train.data)
if (vtesting) class(s.lab.data)

## Set up the Keys for these tables
setkeyv(s.test.data, c("subject.id", "activity.code"))
setkeyv(s.train.data, c("subject.id", "activity.code"))
setkey(s.lab.data, lab.code)

if (vtesting) tables()

## Union the Test and Train data.  

## The union of the two tables should equal the 
## sum of the rows in the two tables.

if (vtesting) nrow(s.test.data)
if (vtesting) nrow(s.train.data)

s.union.data <- sqldf("select distinct * from 's.test.data' union select distinct * from 's.train.data'")

## The sum of the previous 2 nrow statments should equal the next nrow
if (vtesting) nrow(s.union.data)

## Merge in the Activity lables into the main data set.  We will add the Activity Description
## to the main data set matching on the activity.code in the main data set to the lab.code
## in the s.lab.data

s.union.data <- merge(s.lab.data, s.union.data, by.x = "lab.code", by.y = "activity.code", all.y=TRUE)

## There are a number of tables that are taking up memory that will not be used any longer.
## This code will remove those tables from memory.

if (vtesting) tables()
remove(list = c("s.lab.data", "s.test.data", "s.train.data"))
if (vtesting) tables()

## Coursera requirement 2.  Extract only the measurements 
## on the mean and standard deviation for each measurement

## Identify the columns we want to keep.  The Activity Lable, mean... and std... columns
## The following code will return a TRUE or FALSE for each column, TRUE if it matchs the
## column names we are looking for.  The next step will create a new data set that contains
## only the columns marked as TRUE
s.mean.sdv.colname <- s.union.data[,colnames(s.union.data) 
                       %in% c("lab.code", "lab.desc", "subject.id") | 
                           grepl("mean..", colnames(s.union.data), fixed=TRUE) |
                           grepl("std..", colnames(s.union.data), fixed=TRUE)]

## Store only the columns related to Activity Lables, Mean or Std in the new data set
s.mean.sdv <- s.union.data[, s.mean.sdv.colname, with=FALSE]

## I think that haveing multiple periods "." in a column name is messy.  I am going to remove
## all multiple "." 
org.name <- colnames(s.mean.sdv)

## I saw some occurances where there were 3 periods and some where there were 2 periods.  I will
## rename 2 periods to 1 period 2 times.  This will leave only single periods in column names.
new.name <- sub("..", ".",org.name,fixed=TRUE)
new.name <- sub("..", ".",new.name,fixed=TRUE)

if (vtesting) print(org.name)

setnames(s.mean.sdv, org.name, new.name)

if (vtesting) colnames(s.mean.sdv)

## The s.mean.sdv data set now represents a Tidy Data Set and includes only the columns
## needed for this assignment (key columns and columns associated with STD and MEAN)

## The final step in this project is to create a second data set that contains the average of 
## each of the variables:
##   "From the data set in step 4, creates a second, independent tidy data 
##    set with the average of each variable for each activity and each subject."
## The following code will create this dataset.

s.mean.sdv.melt <- melt(s.mean.sdv[,-1,with=FALSE], id = c("subject.id","lab.desc"))
if (vtesting) head(s.mean.sdv.melt)

project.final.dataset <- dcast(s.mean.sdv.melt, subject.id + lab.desc ~ variable, mean)

## Write out the final data set
write.table(project.final.dataset, file = "./data/ProjectFinealDataset.txt", row.names=FALSE)

