infile="FGF14_size_big_allele_v2_forFKil.csv"

(
cat $infile | head -1 | sed 's/old_name/alias/' | sed 's/new_name/alias2/'

cat $infile | tail -n+2
) | cut -d "," -f1,2 | sed 's/,/\t/g' >run007.alias.tsv
