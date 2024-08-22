#!/bin/bash

# 检查文件是否存在
if [[ ! -f "final_16s.csv" ]]; then
    echo "Error: final_16s.csv not found!"
    exit 1
fi

if [[ ! -f "pcoa.csv" ]]; then
    echo "Error: pcoa.csv not found!"
    exit 1
fi

# 使用 csvjoin 合并 CSV 文件
# 假设两个文件都有一个共同的列，比如 'SampleID'
csvjoin -c "SampleID" final_16s.csv pcoa.csv > merged_final_16s_pcoa.csv

# 检查合并是否成功
if [[ $? -eq 0 ]]; then
    echo "Data has been successfully merged and saved to 
merged_final_16s_pcoa.csv"
else
    echo "Error: Failed to merge CSV files."
    exit 1
fi

