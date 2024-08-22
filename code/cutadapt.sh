#!/bin/bash
bioproject_id = $1

# Define the list of sample IDs
samples=$(cat /Users/SUO/${bioproject_id}.txt)
# Create output directory
output_dir="/Users/SUO/result/${bioproject_id}"
mkdir -p ${output_dir}

# Loop through each sample
for sample in ${samples}; do
  echo "Processing sample ${sample}..."

  # Define input and output file paths
  input_forward="/Users/SUO/result/${sample}_1.fastq"
  input_reverse="/Users/SUO/result/${sample}_2.fastq"
  output_forward="${output_dir}/${sample}_tr_R1.fastq"
  output_reverse="${output_dir}/${sample}_tr_R2.fastq"

  # Run Cutadapt for quality trimming
  cutadapt -q 30,30 -m 100 --trim-n \
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

