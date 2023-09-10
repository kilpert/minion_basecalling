#find results/ont-guppy_6.4.6/ -name "*.fastq.gz" | grep _sup | grep "/fastq/" >FAME3_fastq.tsv

echo -e "current_sample_name\trun\tfastq" >FAME3_fastq.tsv
for f in $(find results/ont-guppy_6.4.6/ -name "*.fastq.gz" | grep _sup | grep "/fastq/"); do bname=$(basename ${f%.fastq.gz}); run=$(basename $(dirname $(dirname $(dirname $f)))); echo -e "$bname\t$run\t$f"; done | sort -k2,2 -k1,1 >>FAME3_fastq.tsv

