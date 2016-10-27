# ============ OBJECTIVES ============ #
# === tidy data set === #
# === CodeBook.md === #
# === README.md === #

# getting ready, set wd, download and unzip files
old.dir <- getwd()
dir()
dir.create("Final Assignment")
setwd("~/Final Assignment")
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, destfile = "files.zip")
dir.create("original data")
dir.create("edit data")
unzip(zipfile = "files.zip", exdir = "original data")  # unzip it 1st time 
unzip(zipfile = "files.zip", exdir = "edit data")  # unzip it 2nd time, use this set only
setwd("~/Final Assignment/edit data/UCI HAR Dataset")  # set wd inside the edit data folder 


# 1. Merges the training and the test sets to create one data set.
header <- read.table(file.choose())  # read the feature.txt
header <- as.vector(header$V2)  # only extract the second column b/c this is the column names of the data set
activityLabel <- read.table(file.choose())  # read the activity_labels.txt

trainSubject <- read.table(file.choose())  # read the subject_train.txt
dim(trainSubject); names(trainSubject) <- "SubjectID"  # rename column
trainSet <- read.table(file.choose())  # read the X_train.txt
dim(trainSet); names(trainSet) <- header  # rename column
trainLabel <- read.table(file.choose())  # read the y_train.txt
dim(trainLabel); names(trainLabel) <- "Label"  # rename column
train <- cbind(trainSubject, trainLabel, trainSet)  # cbind the train set 
train$flag <- rep('train', dim(train)[[1]])  # add a column to distinguish the train set 

testSubject <- read.table(file.choose())  # read the subject_test.txt
dim(testSubject); names(testSubject) <- "SubjectID"  # rename column
testSet <- read.table(file.choose())  # read the X_test.txt
dim(testSet); names(testSet) <- header  # rename column
testLabel <- read.table(file.choose())  # read the y_test.txt
dim(testLabel); names(testLabel) <- "Label"  # rename column
test <- cbind(testSubject, testLabel, testSet)  # cbind the test set
test$flag <- rep('test', dim(test)[[1]])  # add a column to distinguish the test set 

dim(train); dim(test)
mergeSet <- rbind(train, test)  # rbind the train and test sets into one
dim(mergeSet)  # 10299  564
View(mergeSet)


# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
mean_AND_sd_columns <- header[grepl(pattern = "mean|std", header)]
mergeSet2 <- subset(mergeSet, select = c("SubjectID", "Label", "flag", mean_AND_sd_columns))
names.mergeSet2 <- names(mergeSet2)
dim(mergeSet2)  # 10299  82
View(mergeSet2)


# 3. Uses descriptive activity names to name the activities in the data set
names(activityLabel) <- c("Label", "ActivityName")
mergeSet3 <- merge(activityLabel, mergeSet2, by = "Label", all.x = TRUE)
unique(mergeSet3$SubjectID[mergeSet3$flag == 'train'])  # check SubjectID
unique(mergeSet3$SubjectID[mergeSet3$flag == 'test'])  # check SubjectID
dim(mergeSet3)  # 10299  83
View(mergeSet3)


# 4. Appropriately labels the data set with descriptive variable names.
names.mergeSet3 <- names(mergeSet3) 
  # names.mergeSet3 <- toupper(names.mergeSet3)  # make all upper cases 
names.mergeSet3 <- gsub(pattern = "\\()", replacement = "", names.mergeSet3)  # remove ()
names(mergeSet3) <- names.mergeSet3


# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
if(!require(reshape2)){install.packages("reshape2")};require(reshape2)  # load reshape2
     
mergeSet4 <- melt(mergeSet3, id = c('Label', 'ActivityName', 'SubjectID', 'flag'))  # melt
mergeSet4 <- dcast(mergeSet4, Label + ActivityName + SubjectID + flag ~ variable, mean)  # dcast
names.mergeSet4 <- names(mergeSet4)
dim(mergeSet4)  # 180  83
View(mergeSet4)

write.table(mergeSet4, "tidy.dataset.txt", row.names = F, quote = F)



