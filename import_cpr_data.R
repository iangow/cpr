library(readr)
library(dplyr, warn.conflicts = FALSE)
cpr_data <- read_csv(file.path("http://lib.law.virginia.edu/Garrett",
                               "corporate-prosecution-registry/browse",
                               "cpr-data.csv"), guess_max = 4000)

names(cpr_data) <- tolower(names(cpr_data))
cpr_data
cpr_data %>% select(date)

## cpr data imported

cpr_data %>% mutate(date=as.Date(date))

library(stringr)

fix_boolean <- function(var){
    if_else(str_detect(var,"^Yes"),TRUE,if_else(str_detect(var,"^No"),FALSE,NA))
}

cpr_data %>% mutate(us_public_co_note=us_public_co,us_public_co=fix_boolean(us_public_co)) %>% count(us_public_co_note,us_public_co)

