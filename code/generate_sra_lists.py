import pandas as pd
import os

# 定义文件路径
excel_path = '/Users/SUO/Desktop/sratest.xlsx'
output_dir = '/Users/SUO/data/sra'
list_dir = '/Users/SUO/Desktop/lists'

# 读取Excel文件
sra_data = pd.read_excel(excel_path)

# 检查并创建输出目录
os.makedirs(output_dir, exist_ok=True)
os.makedirs(list_dir, exist_ok=True)

# 按Bioproject ID分组
grouped = sra_data.groupby('Bioproject ID')

# 遍历每个Bioproject ID
for bioproject_id, group in grouped:
    print(f"Processing Bioproject ID: {bioproject_id}")
    
    # 生成一个临时文件，包含该Bioproject ID的所有SRA ID
    acc_list_path = os.path.join(list_dir, 
f"{bioproject_id}_Acc_List.txt")
    group['SRA ID'].to_csv(acc_list_path, index=False, header=False)

print("SRA ID lists have been generated.")

