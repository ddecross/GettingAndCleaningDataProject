# GettingAndCleaningDataProject
This repository holds the deliverables for the Coursera Getting and Cleaning Data project 

run_analysis.R
This is an R script that does the following against the "Human Activity Recognition Using Smartphones Data Set" (http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones#):

Read in files (data and column names) 
--> add column names to data 
--> Merge data files  
--> Convert data fraims to tables
--> set keys on tables 
--> Union the tables 
--> remove data fraims that are now longer needed 
--> create table containing only keys, STD and MEAN columns 
--> tidy up col names by removing multiple periods in column names 
--> get mean data 
--> write out dataset

ProjectFinealDataset.txt
This is a text file that is the result of running run_analysis.R with the data set folder in the R working directory.

codeBook.md
A data dictionary that describes the variables contained in the tidyDataFinal.txt output file.
