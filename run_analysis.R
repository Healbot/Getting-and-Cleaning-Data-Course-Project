library(dplyr)

## constants
download_to_dir <- "run_analysis_workspace"
root_dir <- file.path(download_to_dir, "UCI HAR Dataset")
zip_file <- file.path(download_to_dir, "UCI HAR Dataset.zip")
download_url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
out_file <- file.path(download_to_dir, "uci_har_mean_by_activity_subject.txt")
# alt: http://archive.ics.uci.edu/ml/machine-learning-databases/00240/UCI%20HAR%20Dataset.zip


## helper functions
download <- function(url, dest) {
    if(!file.exists(download_to_dir)) { dir.create(download_to_dir) }
    download.file(url, dest)
}

extract <- function(file) {
    unzip(file, exdir=download_to_dir, overwrite = TRUE)
}

tidy_features <- function(file) {
    f <- read.table(file)[ ,2]
    
    #correct dupes and make more readable
    f <- factor(gsub("BodyBody", "Body", f))
    f <- factor(gsub("\\(\\)", "", f))
    
    return(f)
}

load_data <- function(type, col_names) {
    data <- read.table(file.path(root_dir, type, paste0("X_", type, ".txt")), col.names = col_names)
    activities_labels <- read.table(file.path(root_dir, type, paste0("y_", type, ".txt")))
    subjects_labels <- read.table(file.path(root_dir, type, paste0("subject_", type, ".txt")))
    
    data$Activity <- activities_labels[ ,1]
    data$Subject <- subjects_labels[ ,1]
    
    return(data)
}


## download and extract
if(!file.exists(zip_file)) { download(download_url, zip_file) }
extract(zip_file)


## prepare labels
activity_labels <- read.table(file.path(root_dir, "activity_labels.txt"))[,2]
feature_labels <- tidy_features(file.path(root_dir, "features.txt"))


## load
test_data <- load_data("test", feature_labels)
train_data <- load_data("train", feature_labels)


## gather and trim data
all_data <- merge(test_data, train_data, all=TRUE, sort=FALSE)
columns_of_interest <- grep("\\.mean|\\.std|Activity|Subject", colnames(all_data))
slim_data <- all_data[ ,columns_of_interest]

## expand the activity labels
slim_data$Activity <- as.factor(slim_data$Activity)
levels(slim_data$Activity) <- activity_labels

## manipulate and write averages to file
all_averages <- slim_data %>% group_by(Activity, Subject) %>% summarize_each(funs(mean))
write.csv(all_averages, out_file)
