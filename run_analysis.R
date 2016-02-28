library(plyr)

##Change the directory and handle file download
setwd('L:/MyDocs/Coursera/Getting_Cleaning_Data/Project')
if (file.exists("./Data/UCI HAR Dataset")){
  print("Data already exists! Skipping Download")
} else if (!file.exists("./UCI HAR Dataset")){
  print("Downloading Data")
  fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileUrl,destfile="./Data/Dataset.zip")
}

setwd(paste0(getwd(), '//Data//UCI HAR Dataset'))
print("Directory Changed")

##Start cleansing / combining of data
##features
x1 <- read.table("train/X_train.txt")
x2 <- read.table("test/X_test.txt")
comb_x <- rbind(x1, x2)
feature_names <- read.table("features.txt")
names(comb_x) <- feature_names$V2

##Activity
y1 <- read.table("train/y_train.txt")
y2 <- read.table("test/y_test.txt")
comb_y <- rbind(y1, y2)
##Make activity id's into names
activity_labels <- read.table("activity_labels.txt")
activity_labels[, 2] = gsub("_", "", tolower(as.character(activity_labels[, 2])))
comb_y[,1] = activity_labels[comb_y[,1], 2]
names(comb_y) <- c("activity")

##Subject
subj1 <- read.table("train/subject_train.txt")
subj2 <- read.table("test/subject_test.txt")
comb_subj <- rbind(subj1, subj2)
names(comb_subj) <- c("subject")

##Merge Data
comb_subj_act <- cbind(comb_subj, comb_y)
comb_all <- cbind(comb_x, comb_subj_act)

##Subset for mean and std
feature_sub<- feature_names$V2[grep("mean\\(\\)|std\\(\\)", feature_names$V2)]

##Subset for selected names
comb_all <- subset(comb_all, select=c(as.character(feature_sub), "subject", "activity"))

##Change names of variables to be a little more user friendly
names(comb_all)<-gsub("^t", "time", names(comb_all))
names(comb_all)<-gsub("^f", "frequency", names(comb_all))
names(comb_all)<-gsub("Acc", "Accelerometer", names(comb_all))
names(comb_all)<-gsub("Gyro", "Gyroscope", names(comb_all))
names(comb_all)<-gsub("Mag", "Magnitude", names(comb_all))
names(comb_all)<-gsub("BodyBody", "Body", names(comb_all))
names(comb_all)<-tolower(names(comb_all)) 

##Creaty Second Tidy Dataset
tidy_data <- ddply(comb_all, .(subject, activity), function(x) colMeans(x[, 1:66]))

##Write tidy data to file
setwd('L:/MyDocs/Coursera/Getting_Cleaning_Data/Project')
write.table(tidy_data, file = "tidydata.txt",row.name=FALSE)

##Clean environment
rm(fileUrl, activity_labels, comb_subj, comb_subj_act, comb_y, comb_x, feature_sub, features, subj2, subj1, x1, x2, y1, y2, feature_names)
