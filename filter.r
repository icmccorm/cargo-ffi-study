library(dplyr)
library(readr)
library(ggplot2)
library(tidyr)
options(dplyr.summarise.inform = FALSE)

crates_path <- file.path("./data/crates.csv")
crates <- read_csv(
    crates_path,
    show_col_types = FALSE
)

verified_path <- file.path("./data/verified.csv")
verified <- read_csv(
    verified_path,
    show_col_types = FALSE
)
with_abi <- verified %>%
    filter(status != "noabi") %>%
    inner_join(crates, by = c("crate_id"))

with_abi

with_abi %>% write.csv(file = file.path("./data/all.csv"))

quantile_max <- unname(quantile(with_abi$downloads, c(.80)))[[1]]
with_abi %>% filter(
    downloads >= quantile_max
) %>%
arrange(desc(downloads)) %>%
write.csv(file = file.path("./data/top20.csv"))