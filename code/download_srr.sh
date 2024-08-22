#!/bin/bash
bioproject_id = $1

# define your SRR_Acc_List.txt path
ACC_LIST_PATH="/Users/SUO/${bioproject_id}.txt"

# define your output path
OUTPUT_DIR="/Users/SUO/result/${bioproject_id}"

# Check and create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# read every single row of SRR number
while IFS= read -r srr_id
do
    echo "Downloading $srr_id"
    prefetch $srr_id
    # option: use fasterq-dump convert to FASTQ file
    echo "Converting $srr_id"
    fasterq-dump $srr_id -O "$OUTPUT_DIR"


# Check if fasterq-dump was successful
    if [[ $? -eq 0 ]]; then
        # Define the SRA file path
        sra_file="${HOME}/ncbi/public/sra/${srr_id}.sra"
        
        # Remove the original SRA file
        if [[ -f "$sra_file" ]]; then
            rm "$sra_file"
            echo "Removed original SRA file: $sra_file"
        else
            echo "SRA file not found: $sra_file"
        fi
    else
        echo "fasterq-dump failed for $srr_id. SRA file not removed."
    fi
done < "$ACC_LIST_PATH"

#get one specific SRR file to certain path:
#prefetch SRR616206 -O /Users/SUO/ncbi/SRP017096
