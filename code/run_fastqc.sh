#!/bin/bash

# define input and output paths
INPUT_DIR="/Users/SUO/ncbi/test/fastq"
OUTPUT_DIR="/Users/SUO/ncbi/FASTQC"

# Check and create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# read evry single FASTQ file and run FastQC
for fastq_file in "$INPUT_DIR"/*.fastq; do
    echo "Processing $fastq_file"
    fastqc -o "$OUTPUT_DIR" "$fastq_file"
done

echo "All files have been processed."

