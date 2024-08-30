rule pod5:
    input:
        config["run"]["input_dir"]
    output:
        pod5="{results}/{run}/pod5/{run}.pod5",
        summary="{results}/{run}/pod5/{run}.summary.tsv.gz"
    params:
        test=config["test"] if config["test"] else "",
    log:
        "{results}/{run}/pod5/{run}.pod5.log"
    benchmark:
        "{results}/{run}/.benchmark/pod5.{run}.benchmark.tsv"
    conda:
        "../envs/pod5.yaml"
    threads:
        8
    shell:
        "pod5 convert fast5 "
        "--strict "
        "--threads {threads} "
        "$(find {input} -name '*.fast5' | sort {params.test}) "
        "--output {output.pod5} "
        ">{log} 2>&1; "
        "pod5 view "
        "{output.pod5} "
        "| pigz --best -p {threads} "
        ">{output.summary} "


rule dorado_download_models:
    output:
        directory("resources/dorado_models/{dorado}")
    params:
        bin=lambda wildcards: config["dorado_basecaller"][wildcards.dorado]["bin"],
    log:
        "resources/dorado_models/{dorado}/{dorado}.dorado_download_models.log"
    shell:
        "{params.bin} download "
        "--overwrite "
        "--model all "
        "--directory {output} "
        ">{log} 2>&1 "


rule dorado_basecaller:
    input:
        rules.dorado_download_models.output,
        pod5=rules.pod5.output.pod5
    output:
        bam="{results}/{run}/{dorado}/{model}/dorado/{run}.{model}.dorado.bam",
        tsv="{results}/{run}/{dorado}/{model}/dorado/{run}.{model}.dorado.summary.tsv.gz"
    params:
        bin=lambda wildcards: config["dorado_basecaller"][wildcards.dorado]["bin"],
        extra=lambda wildcards: config["dorado_basecaller"][wildcards.dorado]["extra"],
        barcode_kits=lambda wildcards: " ".join(config["run"]["barcode_kits"]),
        model_path=lambda wildcards: config["dorado_basecaller"][wildcards.dorado]["model"][wildcards.model]
        ## sample_sheet=lambda wildcards: config["dorado_basecaller"][wildcards.dorado]["sample_sheet"],
        ## outdir="{results}/{run}/{dorado}/{model}/dorado",
    log:
        "{results}/{run}/{dorado}/{model}/log/{run}.{model}.dorado.log"
    benchmark:
        "{results}/{run}/.benchmark/dorado.{dorado}.{run}.{model}.benchmark.tsv"
    resources:
        gpu_requests=1
    threads:
        8
    shell:
        "{params.bin} basecaller "
        "{params.model_path} "
        "{params.extra} "
        "--kit-name {params.barcode_kits} "
        ##"--sample-sheet {params.sample_sheet} "
        "{input.pod5} "
        ">{output.bam} "
        "2>{log}; "
        "{params.bin} summary "
        "{output.bam} "
        "2>>{log} "
        "| pigz --best -p {threads} "
        ">{output.tsv} "


checkpoint dorado_demux_and_trim:
    input:
        rules.dorado_basecaller.output.bam
    output:
        directory("{results}/{run}/{dorado}/{model}/demux")
    params:
        bin=lambda wildcards: config["dorado_basecaller"][wildcards.dorado]["bin"],
        extra=lambda wildcards: config["dorado_basecaller"][wildcards.dorado]["extra"],
        outdir="{results}/{run}/{dorado}/{model}/demux",
        barcode_kits=lambda wildcards: config["run"]["barcode_kits"],
        sample_sheet=lambda wildcards: config["run"]["sample_sheet"],
        samples=samples,
    log:
        "{results}/{run}/{dorado}/{model}/log/{run}.{model}.demux.log"
    benchmark:
        "{results}/{run}/.benchmark/demux.{dorado}.{run}.{model}.benchmark.tsv"
    conda:
        "../envs/samtools.yaml"
    resources:
        gpu_requests=1
    threads:
        8
    shell:
        "{params.bin} demux "
        "--threads {threads} "
        ## "--no-trim "
        ## "--emit-fastq "
        "--emit-summary "
        "--kit-name {params.barcode_kits} "
        "--sample-sheet {params.sample_sheet} "
        "--output-dir {params.outdir} "
        "{input} "
        "2>{log}; "
        ## if no bam file for sample, create empty bam file (only including a header):
        "for sample in {samples}; do "
        "[ -f {params.outdir}/${{sample}}.bam ] || samtools view -H {params.outdir}/unclassified.bam -b -o {params.outdir}/${{sample}}.bam; "
        "done "


# rule dorado_trim:
#     input:
#         rules.dorado_demux.output
#     output:
#         "{results}/{run}/{dorado}/{model}/trim/{sample}.bam"
#     params:
#         bin=lambda wildcards: config["dorado_basecaller"][wildcards.dorado]["bin"]
#     log:
#         "{results}/{run}/{dorado}/{model}/trim/{sample}.trim.log"
#     shell:
#         "{params.bin} trim "
#         "{input}/{wildcards.sample}.bam "
#         ">{output} "
#         "2>{log} "


rule dorado_fastq:
    input:
        rules.dorado_demux_and_trim.output
    output:
        "{results}/{run}/{dorado}/{model}/fastq/{sample}.fastq.gz"
    log:
        "{results}/{run}/{dorado}/{model}/log/{sample}.dorado_fastq.log"
    benchmark:
        "{results}/{run}/.benchmark/dorado_fastq.{dorado}.{model}.{sample}.benchmark.tsv"
    conda:
        "../envs/samtools.yaml"
    threads:
        8
    shell:
        "samtools fastq "
        "--threads {threads} "
        "{input}/{wildcards.sample}.bam "
        "2>{log} "
        "-c 9 "
        "-0 {output} "


rule dorado_fastq_md5:
    input:
        expand("{{results}}/{{run}}/{{dorado}}/{{model}}/fastq/{sample}.fastq.gz",
            sample=samples,
        )
    output:
        "{results}/{run}/{dorado}/{model}/fastq/checksum.md5"
    params:
        indir="{results}/{run}/{dorado}/{model}/fastq/"
    shell:
        "bash workflow/scripts/md5_make "
        "{params.indir} "


rule dorado_fastq_fastqc:
    input:
        rules.dorado_fastq.output
    output:
        html="{results}/{run}/{dorado}/{model}/qc/fastqc/{sample}.html",
        zip="{results}/{run}/{dorado}/{model}/qc/fastqc/{sample}_fastqc.zip" # the suffix _fastqc.zip is necessary for multiqc to find the file. If not using multiqc, you are free to choose an arbitrary filename
    params:
        extra = "--quiet"
    log:
        "{results}/{run}/{dorado}/{model}/log/{sample}.fastqc.log"
    threads: 1
    resources:
        mem_mb = 8192
    wrapper:
        "v4.3.0/bio/fastqc"



rule dorado_pycoQC:
    input:
        rules.dorado_basecaller.output.tsv
    output:
        html="{results}/{run}/{dorado}/{model}/qc/pycoQC/{run}.{model}.pycoQC.html",
        json="{results}/{run}/{dorado}/{model}/qc/pycoQC/{run}.{model}.pycoQC.json"
    params:
        extra=config["pycoqc"],
    log:
        "{results}/{run}/{dorado}/{model}/log/{run}.{model}.pycoQC.log"
    conda:
        "../envs/pycoqc.yaml"
    shell:
        "pycoQC "
        "{params.extra} "
        "--summary_file {input} "
        "--html_outfile {output.html} "
        "--json_outfile {output.json} "
        ">'{log}' 2>&1 "


rule dorado_nanoplot:
    input:
        rules.dorado_basecaller.output.tsv
    output:
        "{results}/{run}/{dorado}/{model}/qc/NanoPlot/NanoPlot-report.html",
    params:
        outdir="{results}/{run}/{dorado}/{model}/qc/NanoPlot/",
        extra=config["nanoplot"],
        ## prefix="{run}.{cfg_type}",
        ## title="{run}.{cfg_type}",
    log:
        ##"{results}/{guppy}/{run}/{cfg_type}/run_qc/NanoPlot/{run}.{cfg_type}.NanoPlot.log"
        "{results}/{run}/{dorado}/{model}/log/{run}.{model}.NanoPlot.log"
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


rule dorado_multiqc:
    input:
        expand("{{results}}/{{run}}/{{dorado}}/{{model}}/qc/fastqc/{sample}_fastqc.zip",
            sample=samples,
        ),
        rules.dorado_pycoQC.output,
        rules.dorado_nanoplot.output,
    output:
        "{results}/{run}/{dorado}/{model}/qc/{run}.multiqc.html"
    params:
        ""  # Optional: extra parameters for multiqc.
    log:
        "{results}/{run}/{dorado}/{model}/qc/{run}.multiqc.log"
    wrapper:
        "v4.3.0/bio/multiqc"

