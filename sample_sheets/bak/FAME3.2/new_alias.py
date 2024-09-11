import numpy as np
import os
import pandas as pd



# sample_sheet_csv = "001_20220412_FAME3.sample_sheet.csv"
# sample_sheet_csv = "004_20221019_FAME3_DAB1_FGF14_SCA8.sample_sheet.csv"
# sample_sheet_csv = "Run005_20230321_FAME3_NAA10_Ilaria.sample_sheet.csv"
sample_sheet_csv = "Run006_20230322_FAME3_NAA10_Ilaria.sample_sheet.csv"


master_tsv = "FAME3_fastq_EL_FKi.tsv"


df_m = pd.read_csv(master_tsv, sep="\t")
df_m = df_m.rename(columns={
    "new_name":"alias",
    "current_sample_name":"alias_old"
    })
print(df_m)
print(len(df_m.index))


df_s = pd.read_csv(sample_sheet_csv)
df_s = df_s.rename(columns={
    "alias":"alias_old"
    })
print(df_s)
print(len(df_s.index))


df = df_s.merge(df_m, on="alias_old", how="left")
print(df)
print(len(df.index))


##print( df.loc[df["alias_old"]==df["alias"]] )


## drop columns
df = df.drop(['run', 'fastq'], axis=1)
print(df)


## fill empty positions in alias from alias_old
df.loc[df['alias'].isnull(), "alias"] = df.loc[df['alias'].isnull(), "alias_old"]
print(df)


print("Duplicated:")
print(df.loc[df.duplicated()])
df = df.loc[np.invert(df.duplicated())] # remove duplicated rows
print(df)


df = df.drop(['alias_old'], axis=1)
print(df)


outfile = f"{sample_sheet_csv.split(".")[0]}_v3.sample_sheet.csv"
print("Output sample sheet:", outfile)
df.to_csv(outfile, index=False)


## test problematic barcode
## print( df.loc[df["barcode"]=="barcode25"] )

