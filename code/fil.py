import pandas as pd

# 读取表格数据
df = pd.read_excel('data_alpha.csv')  # 或 pd.read_csv('your_file.csv')

# 过滤数据
filtered_df = df[df['index'].isin(df['SampleID'])]

# 保存结果
filtered_df.to_csv('filtered_file.csv', index=False)  # 或 filtered_df.to_csv('filtered_file.csv', index=False)
