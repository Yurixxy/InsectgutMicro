#!/bin/bash
bioproject_id = $1

# Enter the directory containing FASTQ files
cd /Users/SUO/result/${bioproject_id} || exit


# Create the manifest file header
{
    echo "sample-id	forward-absolute-filepath	reverse-absolute-filepath"
} > tr_manifest1.txt

# Create a text file containing IDs and paths for forward and reverse reads
ls *.fastq | cut -d "_" -f 1 | sort | uniq | while read sample; do
    forward="${PWD}/${sample}_tr_R1.fastq"
    reverse="${PWD}/${sample}_tr_R2.fastq"
    if [[ -f "$forward" && -f "$reverse" ]]; then
        echo -e "${sample}\t${forward}\t${reverse}"
    else
        echo "Warning: Files for sample $sample not found. Skipping."
    fi
done > tr_manifest2.txt

# Merge files
cat tr_manifest1.txt tr_manifest2.txt > tr_manifest.tsv

if [[ $? -eq 0 ]]; then
  # Remove the original manifest files if merging was successful
  rm tr_manifest1.txt tr_manifest2.txt
  echo "Removed original manifest files: tr_manifest1.txt, tr_manifest2.txt"
else
  echo "Merging manifest files failed. Original files not removed."
fi

# Return to the previous directory
cd -


