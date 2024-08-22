#!/bin/bash

# 定义列表文件目录和输出目录
LIST_DIR="/Users/SUO/Desktop/lists"
OUTPUT_DIR="/Users/SUO/data/sra"

# 检查并创建输出目录
mkdir -p "$OUTPUT_DIR"

# 遍历每个列表文件
for acc_list in "$LIST_DIR"/*.txt; do
    echo "Processing file: $acc_list"
    
    # 读取每个文件中的SRA ID
    while IFS= read -r srr_id; do
        echo "Downloading $srr_id"
        prefetch "$srr_id"
        
        echo "Converting $srr_id"
        fasterq-dump "$srr_id" -O "$OUTPUT_DIR"
    done < "$acc_list"
done

echo "All downloads and conversions are complete."
