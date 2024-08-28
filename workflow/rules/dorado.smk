rule pod5:
    input:
        config["run"]["input_dir"]
    output:
        pod5="{results}/{guppy}/{run}/pod5/{run}.pod5",
        summary="{results}/{guppy}/{run}/pod5/{run}.summary.tsv.gz"
    log:
        "{results}/{guppy}/{run}/pod5/{run}.pod5.log"
    benchmark:
        "{results}/{guppy}/{run}/.benchmark/pod5.{run}.benchmark.txt"
    conda:
        "../envs/pod5.yaml"
    threads:
        8
    shell:
        "pod5 convert fast5 "
        "--threads {threads} "
        "$(find {input} -name '*.fast5' | sort) "
        "--output {output.pod5} "
        ">{log} 2>&1; "
        "pod5 view "
        "{output.pod5} "
        "| pigz --best -p {threads} "
        ">{output.summary} "

