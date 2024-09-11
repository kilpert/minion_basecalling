library(readr)
library(tidyverse)

working_dir = "/home/kilpert/sshfs/projects/humgen/science/depienne/fame3/minion_basecalling/sample_sheets/generate_007_sample_sheet"
alias_tsv = "run007.alias.tsv"
sample_sheet_tsv = "run007_20230614_FGF14_RFC1_FAME_OGT.v2.sample_sheet.csv"

setwd(working_dir)
getwd()


ds = read_csv(sample_sheet_tsv)
ds

da = read_tsv(alias_tsv)
da

dm = merge(ds, da, by="alias", all=T)
dm

dm[is.na(dm$alias2),]$alias2 = dm[is.na(dm$alias2),]$alias
dm

dm %>%
    select(-alias) %>%
    rename(alias=alias2)
