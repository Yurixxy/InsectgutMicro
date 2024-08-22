#!/bin/bash

bioproject_ids=($(awk 'NF {gsub(/^\s+|\s+$/, ""); print}' /home/xinyu/Desktop/bioproject_dada.txt))

for bioproject_id in "${bioproject_ids[@]}"; do

    # define your SRR_Acc_List.txt path
    ACC_LIST_PATH="/home/xinyu/Bioproject/${bioproject_id}.txt"

    # define your output path
    OUTPUT_DIR="/home/xinyu/${bioproject_id}"

    # Check and create output directory if it doesn't exist
    mkdir -p "$OUTPUT_DIR"

    # read every single row of SRR number
    while IFS= read -r srr_id; do
        echo "Downloading $srr_id"
        prefetch $srr_id
        # option: use fasterq-dump convert to FASTQ file
        echo "Converting $srr_id"
        fasterq-dump $srr_id -O "$OUTPUT_DIR"
    done < "$ACC_LIST_PATH"

    rm -r SRR* ERR* DRR*

    # Enter the directory containing FASTQ files
    cd /home/xinyu/${bioproject_id} || exit

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
            continue 2 # Skip to the next bioproject_id
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

    # Define the list of sample IDs
    samples=$(cat /home/xinyu/${bioproject_id}.txt)

    # Create output directory
    output_dir="/home/xinyu/${bioproject_id}"
    mkdir -p ${output_dir}

    # Define the primer sequences for 16S rRNA
    forward_primers=("AGAGTTTGATCMTGGCTCAG" "CCTACGGGNGGCWGCAG" "GTGCCAGCMGCCGCGGTAA")
    reverse_primers=("GGACTACHVGGGTWTCTAAT" "TTACCGCGGCKGCTGGCAC" "GACTACHVGGGTATCTAATCC")

    # Create a string of primers for Cutadapt
    forward_primer_args=""
    reverse_primer_args=""
    for primer in "${forward_primers[@]}"; do
        forward_primer_args="${forward_primer_args} -g ${primer}"
    done
    for primer in "${reverse_primers[@]}"; do
        reverse_primer_args="${reverse_primer_args} -G ${primer}"
    done

    # Loop through each sample
    for sample in ${samples}; do
        echo "Processing sample ${sample}..."

        # Define input and output file paths
        input_forward="/home/xinyu/${bioproject_id}/${sample}_1.fastq"
        input_reverse="/home/xinyu/${bioproject_id}/${sample}_2.fastq"
        output_forward="${output_dir}/${sample}_tr_R1.fastq"
        output_reverse="${output_dir}/${sample}_tr_R2.fastq"

        # Run Cutadapt for quality trimming and primer removal
        cutadapt -q 30,30 -m 120 --trim-n \
            ${forward_primer_args} ${reverse_primer_args} \
            -o ${output_forward} -p ${output_reverse} \
            ${input_forward} ${input_reverse}

        # Check if Cutadapt ran successfully
        if [[ $? -eq 0 ]]; then
            # Remove the original fastq files if Cutadapt was successful
            rm ${input_forward} ${input_reverse}
            echo "Removed original files: ${input_forward}, ${input_reverse}"
        else
            echo "Cutadapt failed for sample ${sample}. Original files not removed."
        fi

        echo "Finished processing sample ${sample}."
        echo "Output files: ${output_forward}, ${output_reverse}"
    done

    echo "All samples processed."
done
