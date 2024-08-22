import pandas as pd
import os

# 文件夹路径
folder_path = 'bio_excel_16s'

# 读取perfect.txt文件，获取bioprojectid列表
with open('folder_names.txt', 'r') as f:
    bioproject_ids = f.read().splitlines()

# 创建一个空的DataFrame来存放结果
combined_df = pd.DataFrame(columns=['BioprojectID', 'Run', 'ScientificName'])

# 遍历所有bioprojectid_SraRunTable.xlsx文件
for bioproject_id in bioproject_ids:
    file_name = os.path.join(folder_path, f"{bioproject_id}_SraRunTable.xlsx")
    if os.path.exists(file_name):
        # 读取Excel文件
        df = pd.read_excel(file_name, usecols=['Run', 'ScientificName'])
        # 添加BioprojectID列
        df['BioprojectID'] = bioproject_id
        # 将数据追加到combined_df
        combined_df = pd.concat([combined_df, df], ignore_index=True)
    else:
        print(f"文件 {file_name} 不存在。")

# 将结果保存到一个新的Excel文件中
combined_df = combined_df[['BioprojectID', 'Run', 'ScientificName']]  # 调整列顺序
combined_df.to_excel('combined_results.xlsx', index=False)

print("数据已成功合并并保存到combined_results.xlsx文件中。")

