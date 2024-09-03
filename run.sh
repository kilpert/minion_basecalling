#!/usr/bin/env bash

## snakemake --cores --use-conda --conda-frontend mamba -p --rerun-incomplete #--rerun-trigger mtime


## results.2024-8 (FAME3, 2nd paper)
snakemake --cores --use-conda --conda-frontend mamba -p --rerun-incomplete --configfile config/run001.minion.config.yaml
snakemake --cores --use-conda --conda-frontend mamba -p --rerun-incomplete --configfile config/run004.minion.config.yaml
snakemake --cores --use-conda --conda-frontend mamba -p --rerun-incomplete --configfile config/run005.minion.config.yaml
snakemake --cores --use-conda --conda-frontend mamba -p --rerun-incomplete --configfile config/run006.minion.config.yaml

# snakemake --cores --use-conda --conda-frontend mamba -p --rerun-incomplete --configfile config/run014.minion.config.yaml

