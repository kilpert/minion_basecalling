## Run QC

rule folder_pycoqc:
    input:
        directory("{results}/{run}/{cfg_type}/guppy_basecaller")
    output:
        html="{results}/{run}/{cfg_type}/run_qc/PycoQC/{run}.{cfg_type}.sequencing_summary.html",
        json="{results}/{run}/{cfg_type}/run_qc/PycoQC/{run}.{cfg_type}.sequencing_summary.json"
    params:
        sequencing_summary="{results}/{run}/{cfg_type}/guppy_basecaller/sequencing_summary.txt"
    log:
        "{results}/{run}/{cfg_type}/run_qc/PycoQC/{run}.{cfg_type}.sequencing_summary.log"
    conda:
        "../envs/pycoqc.yaml"
    shell:
        "pycoQC "
        "--summary_file {params.sequencing_summary} "
        "--html_outfile {output.html} "
        "--json_outfile {output.json} "
        ">{log} 2>&1 "


rule run_multiqc:
    input:
        "{results}/{run}/{cfg_type}/run_qc/PycoQC/{run}.{cfg_type}.sequencing_summary.html"
    output:
        "{results}/{run}/{cfg_type}/run_qc/{run}.{cfg_type}.multiqc.html"
    log:
        "{results}/{run}/{cfg_type}/run_qc/{run}.{cfg_type}.multiqc.log"
    params:
        indir="{results}/{run}/{cfg_type}/run_qc/PycoQC/",
        outdir="{results}/{run}/{cfg_type}/run_qc/",
        outfile="{run}.{cfg_type}.multiqc.html"
    conda:
        "../envs/multiqc.yaml"
    shell:
        "multiqc "
        "--force "
        "--outdir {params.outdir} "
        "--filename {params.outfile} "
        "{params.indir} "
        ">{log} 2>&1 "

