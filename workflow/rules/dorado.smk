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



# $ ./opt/dorado/dorado-0.8.0-linux-x64/bin/dorado basecaller --help
# [2024-09-18 13:00:08.757] [info] Running: "basecaller" "--help"
# Usage: dorado [--help] [--verbose]... [--device VAR] [--models-directory VAR] [--bed-file VAR] [--recursive] [--read-ids VAR] [--max-reads VAR] [--resume-from VAR] [--min-qscore VAR] [--emit-moves] [--emit-fastq] [--emit-sam] [--output-dir VAR] [--reference VAR] [--mm2-opts VAR] [--modified-bases VAR...] [--modified-bases-models VAR] [--modified-bases-threshold VAR] [--kit-name VAR] [--sample-sheet VAR] [--barcode-both-ends] [--barcode-arrangement VAR] [--barcode-sequences VAR] [--primer-sequences VAR] [--no-trim] [--trim VAR] [--estimate-poly-a] [--poly-a-config VAR] [--batchsize VAR] [--chunksize VAR] [--overlap VAR] model data

# Positional arguments:
#   model                       Model selection {fast,hac,sup}@v{version} for automatic model selection including modbases, or path to existing model directory. 
#   data                        The data directory or file (POD5/FAST5 format). 

# Optional arguments:
#   -h, --help                  shows help message and exits 
#   -v, --verbose               [may be repeated]
#   -x, --device                Specify CPU or GPU device: 'auto', 'cpu', 'cuda:all' or 'cuda:<device_id>[,<device_id>...]'. Specifying 'auto' will choose either 'cpu', 'metal' or 'cuda:all' depending on the presence of a GPU device. [nargs=0..1] [default: "auto"]
#   --models-directory          Optional directory to search for existing models or download new models into. [nargs=0..1] [default: "."]
#   --bed-file                  Optional bed-file. If specified, overlaps between the alignments and bed-file entries will be counted, and recorded in BAM output using the 'bh' read tag. [nargs=0..1] [default: ""]

# Input data arguments (detailed usage):
#   -r, --recursive             Recursively scan through directories to load FAST5 and POD5 files. 
#   -l, --read-ids              A file with a newline-delimited list of reads to basecall. If not provided, all reads will be basecalled. [nargs=0..1] [default: ""]
#   -n, --max-reads             Limit the number of reads to be basecalled. [nargs=0..1] [default: 0]
#   --resume-from               Resume basecalling from the given HTS file. Fully written read records are not processed again. [nargs=0..1] [default: ""]

# Output arguments (detailed usage):
#   --min-qscore                Discard reads with mean Q-score below this threshold. [nargs=0..1] [default: 0]
#   --emit-moves                Write the move table to the 'mv' tag. 
#   --emit-fastq                Output in fastq format. 
#   --emit-sam                  Output in SAM format. 
#   -o, --output-dir            Optional output folder, if specified output will be written to a calls file (calls_<timestamp>.sam|.bam|.fastq) in the given folder. 

# Alignment arguments (detailed usage):
#   --reference                 Path to reference for alignment. [nargs=0..1] [default: ""]
#   --mm2-opts                  Optional minimap2 options string. For multiple arguments surround with double quotes. 

# Modified model arguments (detailed usage):
#   --modified-bases            A space separated list of modified base codes. Choose from: pseU, m6A_DRACH, m6A, 6mA, m5C, 5mC, 5mCG_5hmCG, 5mCG, 5mC_5hmC, inosine_m6A, 4mC_5mC. [nargs: 1 or more] 
#   --modified-bases-models     A comma separated list of modified base model paths. [nargs=0..1] [default: ""]
#   --modified-bases-threshold  The minimum predicted methylation probability for a modified base to be emitted in an all-context model, [0, 1]. [nargs=0..1] [default: 0.05]

# Barcoding arguments (detailed usage):
#   --kit-name                  Enable barcoding with the provided kit name. Choose from: EXP-NBD103 EXP-NBD104 EXP-NBD114 EXP-NBD114-24 EXP-NBD196 EXP-PBC001 EXP-PBC096 SQK-16S024 SQK-16S114-24 SQK-LWB001 SQK-MLK111-96-XL SQK-MLK114-96-XL SQK-NBD111-24 SQK-NBD111-96 SQK-NBD114-24 SQK-NBD114-96 SQK-PBK004 SQK-PCB109 SQK-PCB110 SQK-PCB111-24 SQK-PCB114-24 SQK-RAB201 SQK-RAB204 SQK-RBK001 SQK-RBK004 SQK-RBK110-96 SQK-RBK111-24 SQK-RBK111-96 SQK-RBK114-24 SQK-RBK114-96 SQK-RLB001 SQK-RPB004 SQK-RPB114-24 TWIST-16-UDI TWIST-96A-UDI VSK-PTC001 VSK-VMK001 VSK-VMK004 VSK-VPS001. [nargs=0..1] [default: ""]
#   --sample-sheet              Path to the sample sheet to use. [nargs=0..1] [default: ""]
#   --barcode-both-ends         Require both ends of a read to be barcoded for a double ended barcode. 
#   --barcode-arrangement       Path to file with custom barcode arrangement. 
#   --barcode-sequences         Path to file with custom barcode sequences. 
#   --primer-sequences          Path to file with custom primer sequences. [nargs=0..1] [default: <not representable>]

# Trimming arguments (detailed usage):
#   --no-trim                   Skip trimming of barcodes, adapters, and primers. If option is not chosen, trimming of all three is enabled. 
#   --trim                      Specify what to trim. Options are 'none', 'all', 'adapters', and 'primers'. Default behaviour is to trim all detected adapters, primers, or barcodes. Choose 'adapters' to just trim adapters. The 'primers' choice will trim adapters and primers, but not barcodes. The 'none' choice is equivelent to using --no-trim. Note that this only applies to DNA. RNA adapters are always trimmed. [nargs=0..1] [default: ""]

# Poly(A) arguments (detailed usage):
#   --estimate-poly-a           Estimate poly(A)/poly(T) tail lengths (beta feature). Primarily meant for cDNA and dRNA use cases. 
#   --poly-a-config             Configuration file for poly(A) estimation to change default behaviours [nargs=0..1] [default: ""]

# Advanced arguments (detailed usage):
#   -b, --batchsize             The number of chunks in a batch. If 0 an optimal batchsize will be selected. [nargs=0..1] [default: 0]
#   -c, --chunksize             The number of samples in a chunk. [nargs=0..1] [default: 10000]
#   -o, --overlap               The number of samples overlapping neighbouring chunks. [nargs=0..1] [default: 500]


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


# $ ./opt/dorado/dorado-0.8.0-linux-x64/bin/dorado demux --help
# [2024-09-18 13:33:40.800] [info] Running: "demux" "--help"
# Usage: dorado demux [--help] [--recursive] --output-dir VAR [--kit-name VAR] [--sample-sheet VAR] [--no-classify] [--threads VAR] [--max-reads VAR] [--read-ids VAR] [--verbose]... [--emit-fastq] [--emit-summary] [--barcode-both-ends] [--no-trim] [--sort-bam] [--barcode-arrangement VAR] [--barcode-sequences VAR] reads

# Barcode demultiplexing tool. Users need to specify the kit name(s).

# Positional arguments:
#   reads                  An input file or the folder containing input file(s) (any HTS format). [nargs=0..1] [default: ""]

# Optional arguments:
#   -h, --help             shows help message and exits 
#   -r, --recursive        If the 'reads' positional argument is a folder any subfolders will also be searched for input files. 
#   -o, --output-dir       Output folder for demultiplexed reads. [required]
#   --kit-name             Barcoding kit name. Cannot be used with --no-classify. Choose from: EXP-NBD103 EXP-NBD104 EXP-NBD114 EXP-NBD114-24 EXP-NBD196 EXP-PBC001 EXP-PBC096 SQK-16S024 SQK-16S114-24 SQK-LWB001 SQK-MLK111-96-XL SQK-MLK114-96-XL SQK-NBD111-24 SQK-NBD111-96 SQK-NBD114-24 SQK-NBD114-96 SQK-PBK004 SQK-PCB109 SQK-PCB110 SQK-PCB111-24 SQK-PCB114-24 SQK-RAB201 SQK-RAB204 SQK-RBK001 SQK-RBK004 SQK-RBK110-96 SQK-RBK111-24 SQK-RBK111-96 SQK-RBK114-24 SQK-RBK114-96 SQK-RLB001 SQK-RPB004 SQK-RPB114-24 TWIST-16-UDI TWIST-96A-UDI VSK-PTC001 VSK-VMK001 VSK-VMK004 VSK-VPS001. 
#   --sample-sheet         Path to the sample sheet to use. [nargs=0..1] [default: ""]
#   --no-classify          Skip barcode classification. Only demux based on existing classification in reads. Cannot be used with --kit-name or --sample-sheet. 
#   -t, --threads          Combined number of threads for barcoding and output generation. Default uses all available threads. [nargs=0..1] [default: 0]
#   -n, --max-reads        Maximum number of reads to process. Mainly for debugging. Process all reads by default. [nargs=0..1] [default: 0]
#   -l, --read-ids         A file with a newline-delimited list of reads to demux. [nargs=0..1] [default: ""]
#   -v, --verbose          [may be repeated]
#   --emit-fastq           Output in fastq format. Default is BAM. 
#   --emit-summary         If specified, a summary file containing the details of the primary alignments for each read will be emitted to the root of the output folder. 
#   --barcode-both-ends    Require both ends of a read to be barcoded for a double ended barcode. 
#   --no-trim              Skip barcode trimming. If this option is not chosen, trimming is enabled. Note that you should use this option if your input data is mapped and you want to preserve the mapping in the output files, as trimming will result in any mapping information from the input file(s) being discarded. 
#   --sort-bam             Sort any BAM output files that contain mapped reads. Using this option requires that the --no-trim option is also set. 
#   --barcode-arrangement  Path to file with custom barcode arrangement. 
#   --barcode-sequences    Path to file with custom barcode sequences. 


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

