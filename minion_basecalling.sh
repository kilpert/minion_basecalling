#!/usr/bin/env bash

source ~/bin/run.sh


## Run parameters
flow_cell_type="FLO-MIN106"
library_prep_kit="SQK-LSK109"
barcode_kit="EXP-NBD196"

guppy_config="dna_r9.4.1_450bps_fast.cfg"
#guppy_config="dna_r9.4.1_450bps_hac.cfg"
#guppy_config="dna_r9.4.1_450bps_sup.cfg"
input_dir="/vol/minion/minknow/data/001_20220412_FAME3/no_sample/20220412_1232_MN37911_FAR54812_bfd8a256"
output_dir="/vol/minion/minion_basecalling/results/001_20220412_FAME3.fast" # <-------------------------------------adjust_name




## Program defaults (do NOT change!)
##guppy_basecaller="/vol/minion/opt/ont-guppy/bin/guppy_basecaller"
guppy_bin="/vol/minion/opt/ont-guppy/bin"
##guppy_basecall_server="/vol/minion/opt/ont-guppy/bin/guppy_basecall_server"
guppy_config_dir="/vol/minion/opt/ont-guppy/data"
guppy_defaults="--do_read_splitting --calib_detect --recursive --compress_fastq --disable_pings" # --resume --num_callers 1 --nested_output_folder


#guppy_flowcell=
#guppy_kit=
## OR:


## "$guppy_bin/guppy_basecaller" -x auto --input_path "$input_dir" --save_path "$output_dir" --config "${guppy_config_dir}/${guppy_config}"

## find "$input_dir" -name "*.fast5" | "$guppy_bin/guppy_basecaller" -x auto --save_path "$output_dir" --config "${guppy_config_dir}/${guppy_config}" "$guppy_defaults"

#run \
#"$guppy_bin/guppy_basecaller" \
#-x auto \
#"$guppy_defaults" \
#--input_path \
#"$input_dir" \
#--save_path \
#"$output_dir" \
#--config \
#"${guppy_config_dir}/${guppy_config}"
## --barcode_kits "$barcode_kit" # <- does NOT WORK!


#guppy_defaults="--recursive --compress_fastq --disable_pings"
### Barcoding (subsequent to base calling!)
#run \
#"$guppy_bin/guppy_barcoder" \
#-x auto \
#--worker_threads 8 \
#"$guppy_defaults" \
#--input_path "$output_dir" \
#--save_path "${output_dir}.demultiplex" \
#--barcode_kits "$barcode_kit"




run "$guppy_bin/guppy_basecaller" \
  -x auto \
  "$guppy_defaults" \
  --input_path "$input_dir" \
  --save_path "$output_dir" \
  --config "${guppy_config_dir}/${guppy_config}" \
  --progress_stats_frequency=2 \
  --barcode_kits "$barcode_kit" # e.g. EXP-NBD196


## Start server first (NOT WORKING!!!)
## run "$guppy_bin/guppy_basecall_client" --port localhost:5555 "$guppy_defaults" --input_path "$input_dir" --config dna_r9.4.1_450bps_fast.cfg --save_path "$output_dir"


## Guppy Basecall Client
## /opt/ont/guppy/bin/crashpad_handler
## --database=/vol/minion/minknow/data/001_20220412_FAME3/basecalling/guppy_basecall_client-core-dump-db
## --metrics-dir=/vol/minion/minknow/data/001_20220412_FAME3/basecalling/guppy_basecall_client-core-dump-db
## --url=https://submit.backtrace.io/nanoporetech/7a24030541d099764b8e1c5b9aed2dd678c747bbbe00b6e918f21c31f2ff7e4c/minidump
## --annotation=app_name=guppy_basecall_client
## --annotation=cmd_line=/opt/ont/guppy/bin/guppy_basecall_client##--port##ipc:///tmp/.guppy/5555##--server_file_load_timeout##600##--num_callers=1##--save_path##/vol/minion/minknow/data/001_20220412_FAME3/basecalling##--config##dna_r9.4.1_450bps_fast.cfg##--progress_stats_frequency=2##--input_path##/vol/minion/minknow/data/001_20220412_FAME3##--compress_fastq##--recursive##--barcode_kits##EXP-NBD196
## --annotation=hostname=minion
## --annotation=version=6.0.7+c7819bc52
## --initial-client-fd=5
## --shared-client-connection


