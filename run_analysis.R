# This program is monolithic, organized into 5 major steps as per instructions
# Author : Sophie Tardivel
# Date : 25Jan2015


# Init. Download and unzip initial dataset file

download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
              "dataset.zip",
             mode="wb")

unzip("dataset.zip")

#1. Merge the training and the test sets to create one data set.
#
print("CREATION OF DATASET, BE PATIENT DURING FEW MINUTES ;-)")


# Read Train and Test measurements tables
test.x <- read.table("UCI HAR Dataset/test/X_test.txt")
train.x <- read.table("UCI HAR Dataset/train/X_train.txt")

# Merge vertically both tables in a single dataset
dat.x <- rbind(test.x, train.x)


# 2. Extract columns mean() and standard deviation std() for X,Y,Z of each measurements
#
print("2. EXTRACTION OF MEAN() and STANDARD DEVIATION(), BE PATIENT DURING FEW SECONDS ;-)")


# Extraction dataset initialized by an Index (from 1 to nrow)
dat <- data.frame(c(1:nrow(dat.x))) 
dat.cn <- c("Index") # extracted column names 

# Read all column/feature names
dat.fn <- read.table("UCI HAR Dataset/features.txt")

# Identify the right columns/feature names = they contain mean() or std() but not meanFreq()
for (i in 1:ncol(dat.x)) {
  
  if ((grepl("mean",dat.fn[i,2]) || grepl("std",dat.fn[i,2])) &&
        !grepl("meanFreq",dat.fn[i,2])) {
    
    dat <- cbind(dat,dat.x[,i])
    dat.cn <- cbind(dat.cn,as.character(dat.fn[i,2]))
  }
}

# name column to facilitate reading
colnames(dat) <- dat.cn

# 3. Use descriptive activity names to name the activities in the data set
# 4. Appropriately label the data set with descriptive variable names. 
#
print("3 & 4. LABEL Mean() & Std() DATASET WITH ACTIVITIES NAMES")


# Read activities number of Test and Train measurements and merge them 
test.y <- read.table("UCI HAR Dataset/test/y_test.txt") 
train.y <- read.table("UCI HAR Dataset/train/y_train.txt") 
dat.y <- rbind(test.y, train.y)

# Get descriptive activity 
activities <- read.table("UCI HAR Dataset/activity_labels.txt") 

# Label dataset by associating description to activity numbers in the first non-used column
dat[,1] <- activities[dat.y[,1],2]



# 5. From the data set in step 4, creates a second, independent tidy data set 
#    with the average of each variable for each activity and each subject.
#
print("5. TIDY DATA WITH AVERAGE OF EACH VARIABLE X,Y,Z for EACH ACTIVITY and EACH SUBJECT-PERSON")

# Read Subject numbers
test.s <- read.table("UCI HAR Dataset/test/subject_test.txt") 
train.s <- read.table("UCI HAR Dataset/train/subject_train.txt") 
dat.s <- rbind(test.s, train.s)

# Associate with labelled dataset (new first column)
dat <- cbind(dat.s,dat)

# Calculate the average of each column 
# starting after Subject (first) and Label (Second) columns

res <- sapply(split(dat[,3], list(dat[,1], dat[,2])),mean)

for (i in 4:ncol(dat)) {
    res <- cbind(res,sapply(split(dat[,i], list(dat[,1], dat[,2])),mean))
}

# Associate column names to the average suppressing the index column name
colnames(res) <- c(dat.cn[2:ncol(dat.cn)])


write.table(res,file="UCI HAR Dataset/result.txt",row.name=FALSE)

# THE END