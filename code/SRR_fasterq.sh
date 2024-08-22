#!/bin/bash

# define output path
OUTPUT_DIR="/Users/SUO/ncbi/SRP017096/fastq"

# check and create output directory
mkdir -p "$OUTPUT_DIR"

# confirm SRR_list.txt file full path
SRR_LIST="/Users/SUO/Desktop/SRP017096/SRR_Acc_List.txt"

# cycle every single SRR file
while read -r SRR_ID; do
    echo "Processing $SRR_ID"
    fasterq-dump "$SRR_ID" -O "$OUTPUT_DIR"
done < "$SRR_LIST"

