## QC (sequencing_summary.txt)

def sequencing_summary_input(wildcards):
    return str(checkpoints.guppy_basecaller.get(**wildcards).output["summary_txt"])


## Run QC

rule folder_pycoQC:
    input:
        sequencing_summary_input
    output:
        html="{results}/{guppy}/{run}/{cfg_type}/run_qc/pycoQC/{run}.{cfg_type}.pycoQC.html",
        json="{results}/{guppy}/{run}/{cfg_type}/run_qc/pycoQC/{run}.{cfg_type}.pycoQC.json"
    params:
        extra=config["pycoqc"],
    log:
        "{results}/{guppy}/{run}/{cfg_type}/run_qc/pycoQC/{run}.{cfg_type}.pycoQC.log"
    conda:
        "../envs/pycoqc.yaml"
    shell:
        "pycoQC "
        "{params.extra} "
        "--summary_file {input} "
        "--html_outfile {output.html} "
        "--json_outfile {output.json} "
        ">'{log}' 2>&1 "


## NanoPlot

rule folder_nanoplot:
    input:
        sequencing_summary_input
    output:
        "{results}/{guppy}/{run}/{cfg_type}/run_qc/NanoPlot/NanoPlot-report.html",
    params:
        outdir="{results}/{guppy}/{run}/{cfg_type}/run_qc/NanoPlot/",
        extra=config["nanoplot"],
        ## prefix="{run}.{cfg_type}",
        ## title="{run}.{cfg_type}",
    log:
        "{results}/{guppy}/{run}/{cfg_type}/run_qc/NanoPlot/{run}.{cfg_type}.NanoPlot.log"
    conda:
        "../envs/nanoplot.yaml"
    threads:
        8
    shell:
        "NanoPlot "
        "-t {threads} "
        "{params.extra} "
        "--summary '{input}' "
        "-o {params.outdir} "
        ## "--prefix {params.prefix} "
        ## "--title {params.title} "
        ">'{log}' 2>&1 "
        ##"&& touch {output} "


## MultiQC

rule run_multiqc:
    input:
        "{results}/{guppy}/{run}/{cfg_type}/run_qc/pycoQC/{run}.{cfg_type}.pycoQC.html",
        "{results}/{guppy}/{run}/{cfg_type}/run_qc/NanoPlot/NanoPlot-report.html",
    output:
        "{results}/{guppy}/{run}/{cfg_type}/run_qc/{run}.{cfg_type}.MultiQC.html"
    log:
        "{results}/{guppy}/{run}/{cfg_type}/run_qc/{run}.{cfg_type}.MultiQC.log"
    params:
        indir_pycoqc="{results}/{guppy}/{run}/{cfg_type}/run_qc/pycoQC/",
        indir_nanoplot="{results}/{guppy}/{run}/{cfg_type}/run_qc/NanoPlot/",
        outdir="{results}/{guppy}/{run}/{cfg_type}/run_qc/",
        outfile="{run}.{cfg_type}.MultiQC.html"
    conda:
        "../envs/multiqc.yaml"
    shell:
        "multiqc "
        "--force "
        "--outdir {params.outdir} "
        "--filename {params.outfile} "
        "{params.indir_pycoqc} "
        "{params.indir_nanoplot} "
        ">'{log}' 2>&1 "

