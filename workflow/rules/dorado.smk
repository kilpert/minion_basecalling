rule pod5:
    input:
        config["run"]["input_dir"]
    output:
        pod5="{results}/{run}/pod5/{run}.pod5",
        summary="{results}/{run}/pod5/{run}.summary.tsv.gz"
    log:
        "{results}/{run}/pod5/{run}.pod5.log"
    benchmark:
        "{results}/{run}/.benchmark/pod5.{run}.benchmark.txt"
    conda:
        "../envs/pod5.yaml"
    threads:
        8
    shell:
        "pod5 convert fast5 "
        "--strict "
        "--threads {threads} "
        "$(find {input} -name '*.fast5' | sort | head -2) "
        "--output {output.pod5} "
        ">{log} 2>&1; "
        "pod5 view "
        "{output.pod5} "
        "| pigz --best -p {threads} "
        ">{output.summary} "


rule dorado:
    input:
        rules.pod5.output.pod5
    output:
        "{results}/{run}/{dorado}/{mode}/{run}.{mode}.dorado.bam"
    params:
        bin=lambda wildcards: config["dorado_basecaller"][wildcards.dorado]["bin"]
    log:
        "{results}/{run}/{dorado}/{mode}/{run}.{mode}.dorado.log"
    benchmark:
        "{results}/{run}/.benchmark/dorado.{dorado}.{run}.{mode}.benchmark.txt"
    resources:
        gpu_requests=1
    shell:
        ##"touch {output} "
        "{params.bin} basecaller "
        "{wildcards.mode} "
        "{input} "
        ">{output} "
        "2>{log} "

