library(readr)
library(tidyverse)



# sample_sheet_csv = "001_20220412_FAME3.sample_sheet.csv"
# sample_sheet_csv = "004_20221019_FAME3_DAB1_FGF14_SCA8.sample_sheet.csv"
# sample_sheet_csv = "Run005_20230321_FAME3_NAA10_Ilaria.sample_sheet.csv"
sample_sheet_csv = "Run006_20230322_FAME3_NAA10_Ilaria.sample_sheet.csv"



workdir = "/home/kilpert/Downloads/sample_sheet"
setwd(workdir)
getwd()



master_tsv = "FAME3_fastq_EL_FKi.tsv"

df_m = read_tsv(master_tsv) %>%
    rename(alias=new_name, alias_old=current_sample_name)
df_m
nrow(df_m)
df_m = distinct(df_m)
nrow(df_m)

# outfile = "FAME3_fastq_EL_FKi.tsv"
# outfile
# write_tsv(df_m, outfile)
 


df_s = read_csv(sample_sheet_csv)
df_s["alias_old"] = df_s["alias"]
df_s["alias"] = NULL
df_s



df = merge(df_s, df_m, by="alias_old", all.x=T) %>%
    arrange(barcode) %>%
    select(-run, -fastq)
df

## fill empty positions in alias from alias_old
df[is.na(df["alias"]),]["alias"] = df[is.na(df["alias"]),]["alias_old"]

## order columns
df = df %>%
    select(kit, flow_cell_id, experiment_id, barcode, alias_old, alias) %>%
    arrange(barcode)
df
nrow(df)

df = distinct(df)
nrow(df)

bname = gsub(".sample_sheet.csv", "", basename(sample_sheet_csv))
outfile = sprintf("%s_v2.sample_sheet.csv", bname)
outfile
write_csv(df, outfile)
