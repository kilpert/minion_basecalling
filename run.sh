#!/usr/bin/env bash

##snakemake --cores --use-conda --conda-frontend mamba -p --rerun-incomplete --rerun-trigger mtime
snakemake -j 32 --profile humgen # --rerun-triggers mtime

