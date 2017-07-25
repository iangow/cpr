library(readr)
library(dplyr, warn.conflicts = FALSE)
cpr_data <- read_csv(file.path("http://lib.law.virginia.edu/Garrett",
                               "corporate-prosecution-registry/browse",
                               "cpr-data.csv"), guess_max = 4000)

names(cpr_data) <- tolower(names(cpr_data))
cpr_data
cpr_data %>% select(date)

