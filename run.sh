#!/usr/bin/env bash

## snakemake --cores --use-conda --conda-frontend mamba -p --rerun-incomplete #--rerun-trigger mtime


## results.FAME3-2 (FAME3, 2nd paper)
snakemake --cores --use-conda --conda-frontend mamba -p --rerun-incomplete --configfile config/run001.minion.config.yaml
snakemake --cores --use-conda --conda-frontend mamba -p --rerun-incomplete --configfile config/run004.minion.config.yaml
snakemake --cores --use-conda --conda-frontend mamba -p --rerun-incomplete --configfile config/run005.minion.config.yaml
snakemake --cores --use-conda --conda-frontend mamba -p --rerun-incomplete --configfile config/run006.minion.config.yaml
snakemake --cores --use-conda --conda-frontend mamba -p --rerun-incomplete --configfile config/run007.minion.config.yaml
snakemake --cores --use-conda --conda-frontend mamba -p --rerun-incomplete --configfile config/run010.minion.config.yaml
snakemake --cores --use-conda --conda-frontend mamba -p --rerun-incomplete --configfile config/run011.minion.config.yaml
snakemake --cores --use-conda --conda-frontend mamba -p --rerun-incomplete --configfile config/run014.minion.config.yaml

## DAB1
# snakemake --cores --use-conda --conda-frontend mamba -p --rerun-incomplete --configfile config/run014.minion.config.yaml

