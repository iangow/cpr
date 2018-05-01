library(readr)
library(dplyr, warn.conflicts = FALSE)
library(stringr)

# Some helper functions ----
fix_boolean <- function(var) {
    if_else(str_detect(var, "^(Yes|Y;)"), TRUE,
            if_else(str_detect(var,"^No"), FALSE, NA))
}

fix_names <- function(df) {
    colnames(df) <- tolower(colnames(df))
    return(df)
}

# Read data ----
cpr_data <-
    read_csv(file.path("http://lib.law.virginia.edu/Garrett",
                               "corporate-prosecution-registry/browse",
                               "cpr-data.csv"), guess_max = 4000) %>%
    fix_names() %>%
    rename(leniency_reasons = does_agreement_discuss_reasons_or_relevent_considerations_for_leniency) %>%
    mutate(date=as.Date(date),
           us_public_co_note = us_public_co,
           us_public_co = fix_boolean(us_public_co),
           leniency_reasons_note = leniency_reasons,
           leniency_reasons = fix_boolean(leniency_reasons))

cpr_data %>% count(us_public_co_note, us_public_co)

# Push data to PostgreSQL ----
library(RPostgreSQL)

pg <- dbConnect(PostgreSQL(), host="10.101.13.99", password="temp_20170710")

rs <- dbWriteTable(pg, c("cpr", "cpr_data"), cpr_data,
                   overwrite = TRUE, row.names = FALSE)
rs <- dbGetQuery(pg, "ALTER TABLE cpr.cpr_data OWNER TO cpr")
rs <- dbGetQuery(pg, "GRANT SELECT ON cpr.cpr_data TO cpr_access")
dbDisconnect(pg)

library(rvest)
library(lubridate)

library(dplyr,warn.conflicts = FALSE)

docket_link <- "http://lib.law.virginia.edu/Garrett/corporate-prosecution-registry/dockets/1stUnionTransfer.htm"

fix_names <- function(df){
     names(df) <- c("date_filed" ,"item_number","docket_text")
     df
}

docket_df <-
    read_html(docket_link) %>%
    html_nodes("table") %>%
    .[[5]] %>%
    html_table() %>%
    fix_names() %>%
    mutate(date_filed=mdy(date_filed)) %>%
    mutate(docket_text =gsub("\r\n\\s*","",docket_text))

docket_df

docket_text
