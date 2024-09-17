import os
import pandas as pd



infile_paths_tsv = "paths.tsv"

outfile_data_tsv = "fastq_merge.tsv"



## paths
print("{:#^100}".format(f" {infile_paths_tsv} "))

df_paths = pd.read_csv(infile_paths_tsv, sep="\t")
## print(df_paths)

df_paths["run_barcode"] = df_paths["path"].apply( lambda x: os.path.basename(x).rstrip(".fastq.gz") )
## print(df_paths)

df_paths['run'] = df_paths['run_barcode'].str.partition('_')[0]
df_paths['barcode'] = df_paths['run_barcode'].str.partition('_')[2]

df_paths = df_paths.drop(columns=["run_barcode"])
print(df_paths)

## df_paths.to_csv(outfile_data_tsv, sep="\t", index=False)


## sample sheets

sample_sheets = [
    "run001.sample_sheet.csv",
    "run004.sample_sheet.csv",
    "run005.sample_sheet.csv",
    "run006.sample_sheet.csv",
    "run007.sample_sheet.csv",
    "run010.sample_sheet.csv",
    "run011.sample_sheet.csv",
    "run014.sample_sheet.csv",
]
## print(sample_sheets)


## sample_sheet = sample_sheets[0]

df_list = []
for sample_sheet in sample_sheets:
    print("{:#^100}".format(f" {sample_sheet} "))

    df_sample_sheet = pd.read_csv(sample_sheet)
    ## print(df_sample_sheet)

    run =  sample_sheet.split(".")[0]

    df_sample_sheet["run"] = run

    df_sample_sheet = df_sample_sheet[["run", "barcode", "alias"]]
    print(df_sample_sheet)

    ## merge
    print("{:#^100}".format(f" merge ({run}) "))

    df = pd.merge(
        left=df_paths,
        right=df_sample_sheet,
        how="right",
        left_on=["run", "barcode"],
        right_on=["run", "barcode"]
    )
    print(df)
    df_list.append(df)


print("{:#^100}".format(f" df_list "))
for df in df_list:
    print(df)


print("{:#^100}".format(f" df (final) "))
df = pd.concat(df_list)

df = df.sort_values(by=['path'])

df = df[["run", "barcode", "alias", "path"]]


print(df)

## save
df.to_csv(outfile_data_tsv, sep="\t", index=False) 
print(f"File saved to: '{outfile_data_tsv}'")

