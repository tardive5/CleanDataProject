---
title: "CodeBook"
author: "S.Tardivel"
date: "Sunday, January 25, 2015"
output: html_document
---

Here is my CodeBook.


# The initial step was to download and unzip the dataset big file and store it.The mode "wb" is fine for zip files.

Destination directory : Local directory you can obtain with getwd()
Destination filename  : "dataset.zip"

```{r}
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
              "dataset.zip",
             mode="wb")
```
```{r}
unzip("dataset.zip")
```

# 1. Merge the measurements from 2subsets of files "Test" and "Train" 

Measurements are under top directory "UCI HAR dataset".
After having read each measurements file, made of 561 columns/features, rbind() allows to merge them. 

VARIABLES

test.x  : table with all test measurements

train.x : table with all train measurements

dat.x   : resulting data.frame of merged measurements


```{r}
test.x <- read.table("UCI HAR Dataset/test/X_test.txt")
```

```{r}
train.x <- read.table("UCI HAR Dataset/train/X_train.txt")
```

```{r}
dat.x <- rbind(test.x, train.x)
```

NOTEE that was the longest portion of the code. A print() is put there to avoid any doubt.

# 2. Columns with mean and standard deviation shall be extracted

VARIABLES

dat    : Data frame with extracted measurements

dat.cn : data frame with associated column/feature names

dat.fn : all column/feature names



Data frames shall be initialized:

```{r}
dat <- data.frame(c(1:nrow(dat.x))) 
```

```{r}
dat.cn <- c("Index") # extracted column names 
```


Column/feature names are read from the file "features.txt".

For each column name, the second column of dat.fn[], that contains either "mean"" or "std"" string, the measurements are extracted into dat[].

The column name is also kept, into dat.cn[].

grepl() is used to find the strings "mean" or "std" but to skip "meanFreq" that I considered non-valid. 

grepl() is case.sensitive so names with "Mean" are also skipped.

cbind() concatenates columns.

For more visibility, colnames() adds names to extracted columns.

 
```{r}
dat.fn <- read.table("UCI HAR Dataset/features.txt")
```

```{r}
for (i in 1:ncol(dat.x)) {
  if ((grepl("mean",dat.fn[i,2]) || grepl("std",dat.fn[i,2])) &&
        !grepl("meanFreq",dat.fn[i,2])) {
    dat <- cbind(dat,dat.x[,i])
    dat.cn <- cbind(dat.cn,as.character(dat.fn[i,2]))
  }
}
```

```{r}
colnames(dat) <- dat.cn
```

# 3 & 4. Descriptive activities shall be associated with each row
VARIABLES

test.y     : table of activity number associated to each row of test data set

train.y    : table of activity number associated to each row of train data set

dat.y      : resulting one-column data frame of merged activity numbers

activities : string table that describes the 6 activities in the 2nd column

dat[,1]    : Idea is to reuse dat[] Index column for descriptive activity



```{r, echo=FALSE}
test.y <- read.table("UCI HAR Dataset/test/y_test.txt") 
```

```{r}
train.y <- read.table("UCI HAR Dataset/train/y_train.txt") 
```

```{r}
dat.y <- rbind(test.y, train.y)
```

```{r}
activities <- read.table("UCI HAR Dataset/activity_labels.txt") 
```

```{r}
dat[,1] <- activities[dat.y[,1],2]
```

# 5. Calculate the average per group of subject/activities
VARIABLES

test.s     : table of subject number associated to each row of test data set

train.s   : table of subject number associated to each row of train data set

dat.s     : resulting one-column data frame of merged subject numbers



Once subject is associated to each of measurements, dataset is grouped/splitted considering two criteria: the first column for subjects and the second column for activities.
average is calculated with sapply() and mean()

Finally, result is written on file "UCI HAR Dataset/result.txt"


```{r}
test.s <- read.table("UCI HAR Dataset/test/subject_test.txt") 
```

```{r}
train.s <- read.table("UCI HAR Dataset/train/subject_train.txt") 
```

```{r}
dat.s <- rbind(test.s, train.s)
```

```{r}
dat <- cbind(dat.s,dat)
```

```{r}
res <- sapply(split(dat[,3], list(dat[,1], dat[,2])),mean)
```
```{r}
for (i in 4:ncol(dat)) {
    res <- cbind(res,sapply(split(dat[,i], list(dat[,1], dat[,2])),mean))
}
```

```{r}
colnames(res) <- c(dat.cn[2:ncol(dat.cn)])
```

```{r}
write.table(res,file="UCI HAR Dataset/result.txt",row.name=FALSE)
```

# End of CodeBook