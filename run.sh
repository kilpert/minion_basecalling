#!/usr/bin/env bash

## snakemake --cores --use-conda --conda-frontend mamba -p --rerun-incomplete #--rerun-trigger mtime


## results.FAME3-2 (FAME3, 2nd paper)
# snakemake --cores --use-conda --conda-frontend mamba -p --rerun-incomplete --rerun-trigger mtime --configfile config/runs/run001.config.yaml
# snakemake --cores --use-conda --conda-frontend mamba -p --rerun-incomplete --rerun-trigger mtime --configfile config/runs/run004.config.yaml
# snakemake --cores --use-conda --conda-frontend mamba -p --rerun-incomplete --rerun-trigger mtime --configfile config/runs/run005.config.yaml
# snakemake --cores --use-conda --conda-frontend mamba -p --rerun-incomplete --rerun-trigger mtime --configfile config/runs/run006.config.yaml
# snakemake --cores --use-conda --conda-frontend mamba -p --rerun-incomplete --rerun-trigger mtime --configfile config/runs/run007.config.yaml
# snakemake --cores --use-conda --conda-frontend mamba -p --rerun-incomplete --rerun-trigger mtime --configfile config/runs/run010.config.yaml
# snakemake --cores --use-conda --conda-frontend mamba -p --rerun-incomplete --rerun-trigger mtime --configfile config/runs/run011.config.yaml
# snakemake --cores --use-conda --conda-frontend mamba -p --rerun-incomplete --rerun-trigger mtime --configfile config/runs/run014.config.yaml

# snakemake --use-conda -p --rerun-incomplete --configfile config/runs/run001.config.yaml
# snakemake --use-conda -p --rerun-incomplete --configfile config/runs/run004.config.yaml
# snakemake --use-conda -p --rerun-incomplete --configfile config/runs/run005.config.yaml
# snakemake --use-conda -p --rerun-incomplete --configfile config/runs/run006.config.yaml
# snakemake --use-conda -p --rerun-incomplete --configfile config/runs/run007.config.yaml
# snakemake --use-conda -p --rerun-incomplete --configfile config/runs/run010.config.yaml
# snakemake --use-conda -p --rerun-incomplete --configfile config/runs/run011.config.yaml
# snakemake --use-conda -p --rerun-incomplete --configfile config/runs/run013.config.yaml
# snakemake --use-conda -p --rerun-incomplete --configfile config/runs/run014.config.yaml
# snakemake --use-conda -p --rerun-incomplete --configfile config/runs/run015.config.yaml

## DAB1
# snakemake --cores --use-conda --conda-frontend mamba -p --rerun-incomplete --configfile config/runs/run014.config.yaml

## 2025
snakemake --use-conda -p --rerun-incomplete --configfile config/runs/run016.config.yaml # run16_20251001_MARCHF6_FGF14_RNU2s

