# Getting and Cleaning Data Course Project
## Code Book

This document describes details of run_analysis.R

### Helper Functions

`download()`: creates a data directory and downloads the raw data to it  
`extract()`: extracts the data package by unzipping it  
`tidy_features()`: uses regex to remove parenthesis and duplicates in the list of features  
`load_data()`: used to create data.frames from the respective "train" or "test" datasets depending on what is passed to the "type" arg. An "Activity" and "Subject" column is also added to the data.frame before returning it from "y\_" and "subject\_" .txt respectively.


### Process Flow
1. `run_analysis.R` downloads and extracts the dataset from:
+ http://archive.ics.uci.edu/ml/machine-learning-databases/00240/ (currently using coursera url to minimize auth site traffic; see alt url in code)
2. Gather all the activity labels from `activity_labels.txt`
3. Gather and clean all the feature labels from `features.txt`. These will come to be the dataset's column names
4. Load the "test" (2947 obs.) and "train" (7352 obs.) datasets and apply the `feature_labels` as column headers
5. Merge the two sets together into `all_data` (10299 obs.)
6. Create a vector indexing all the column names we're interested in (mean, standard deviation, Activity, and Subject). These are singled out using regex search on the following keywords "mean", "std", "Activity", and "Subject".
7. Convert the Activity column to factors so we can use `levels()` to rename all the previously numeric values as actual Activity labels.
8. The final step is to create another dataset condenced to averages of each feature, activity, and subject. This is handled elegantly with dplyr `group_by` and `summarize_each` on `mean()`.
9. The resulting data.frame is written to the cwd as `uci_har_mean_by_activity_subject.txt`

### Auth notes
The last two features listed in `feature_info.txt` seemed to have typos of "BodyBody". This was cleaned in `tidy_features()`