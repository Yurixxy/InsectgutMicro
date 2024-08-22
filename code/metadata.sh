awk -F',' 'BEGIN {OFS="\t"} 
    NR==1 {print "sample-id", "forward-absolute-filepath", "reverse-absolute-filepath"} 
    NR>1 {print $(NF-2), "your_path/"$1"_1.fastq.gz", "your_path/"$1"_2.fastq.gz"}' /Users/SUO/Desktop/SraRunTable-6.txt > /Users/SUO/Desktop/manifest.tsv
