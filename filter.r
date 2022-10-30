library(dplyr)
library(readr)
library(ggplot2)
library(tidyr)
options(dplyr.summarise.inform = FALSE)

crates_path <- file.path("crates.csv")
crates <- read_csv(
    crates_path,
    show_col_types = FALSE
)

categories_path <- file.path("categories.csv")
categories <- read_csv(
    categories_path,
    show_col_types = FALSE
)

quantile_max <- unname(quantile(crates$downloads, c(.80)))[[1]]
top20 <- crates %>% filter(
    downloads >= quantile_max
) %>%
arrange(desc(downloads))

quantile_max <- unname(quantile(crates$downloads, c(.95)))[[1]]
top5 <- crates %>% filter(
    downloads >= quantile_max
) %>%
arrange(desc(downloads))

quantile_max <- unname(quantile(crates$downloads, c(.99)))[[1]]
top1 <- crates %>% filter(
    downloads >= quantile_max
) %>%
arrange(desc(downloads))

top20 %>% write.table(
    file.path(paste(
        "top20.csv",
        sep = ""
    )),
    sep = ",",
    quote = FALSE,
    row.names = FALSE,
    col.names = FALSE
)

top5 %>% write.table(
    file.path(paste(
        "top5.csv",
        sep = ""
    )),
    sep = ",",
    quote = FALSE,
    row.names = FALSE,
    col.names = FALSE
)

top1 %>% write.table(
    file.path(paste(
        "top1.csv",
        sep = ""
    )),
    sep = ",",
    quote = FALSE,
    row.names = FALSE,
    col.names = FALSE
)