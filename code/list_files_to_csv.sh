#!/bin/bash

# Specify the directory path
directory="/Users/SUO/ncbi/test/fastq"

# Specify the output CSV file path
output_csv="/Users/SUO/ncbi/test/file_list.csv"

# If the output CSV file already exists, delete it
if [ -f "$output_csv" ]; then
    rm "$output_csv"
fi

# Add the header row to the CSV file
echo "filename" > "$output_csv"

# Traverse through all files in the directory and write the filenames into 
a CSV file
for filepath in "$directory"/*
do
    if [ -f "$filepath" ]; then
        filename=$(basename "$filepath")
        echo "$filename" >> "$output_csv"
    fi
done

echo "Filenames have been saved to $output_csv"

