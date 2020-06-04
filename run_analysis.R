#getting the data
packages <- c("data.table", "reshape2")
sapply(packages, require, character.only=TRUE, quietly=TRUE)
path <- getwd()
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, file.path(path, "dataFiles.zip"))
unzip(zipfile = "dataFiles.zip")


#preparing the datas
features <- read.table("UCI HAR Dataset/features.txt", col.names = c("n","functions"))
activities <- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("code", "activity"))
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = "subject")
x_test <- read.table("UCI HAR Dataset/test/X_test.txt", col.names = features$functions)
y_test <- read.table("UCI HAR Dataset/test/y_test.txt", col.names = "code")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = "subject")
x_train <- read.table("UCI HAR Dataset/train/X_train.txt", col.names = features$functions)
y_train <- read.table("UCI HAR Dataset/train/y_train.txt", col.names = "code")


#merging datas
X <- rbind(x_train, x_test)
Y <- rbind(y_train, y_test)
sub <- rbind(subject_train, subject_test)
merge <- cbind(sub, Y, X)


#mean and sd
neat <- merge %>% select(subject, code, contains("mean"), contains("std"))

neat$code <- activities[neat$code, 2]

names(neat)[2] = "activity"
names(neat)<-gsub("Acc", "Accelerometer", names(neat))
names(neat)<-gsub("Gyro", "Gyroscope", names(neat))
names(neat)<-gsub("BodyBody", "Body", names(neat))
names(neat)<-gsub("Mag", "Magnitude", names(neat))
names(neat)<-gsub("^t", "Time", names(neat))
names(neat)<-gsub("^f", "Frequency", names(neat))
names(neat)<-gsub("tBody", "TimeBody", names(neat))
names(neat)<-gsub("-mean()", "Mean", names(neat), ignore.case = TRUE)
names(neat)<-gsub("-std()", "STD", names(neat), ignore.case = TRUE)
names(neat)<-gsub("-freq()", "Frequency", names(neat), ignore.case = TRUE)
names(neat)<-gsub("angle", "Angle", names(neat))
names(neat)<-gsub("gravity", "Gravity", names(neat))

FinalData <- neat %>%
        group_by(subject, activity) %>%
        summarise_all(funs(mean))
write.table(FinalData, "FinalData.txt", row.name=FALSE)


