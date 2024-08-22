import os
import pandas as pd

# 输入和输出目录
input_dir = '/Users/SUO/Desktop/Bioproject_16s'
output_dir = '/Users/SUO/Desktop/bio_excel_16s'

# 如果输出目录不存在，则创建它
os.makedirs(output_dir, exist_ok=True)

# 列出输入目录中的所有 TXT 文件
txt_files = [f for f in os.listdir(input_dir) if f.endswith('.txt')]

# 处理每个 TXT 文件
for txt_file in txt_files:
    # 构建完整的文件路径
    txt_path = os.path.join(input_dir, txt_file)
    
    # 检查文件是否为空
    if os.path.getsize(txt_path) == 0:
        print(f"文件为空: {txt_path}")
        continue
    
    try:
        # 尝试将 TXT 文件读入 DataFrame
        df = pd.read_csv(txt_path, sep=',')  # 根据需要调整分隔符
    except pd.errors.EmptyDataError:
        print(f"文件没有数据: {txt_path}")
        continue
    except pd.errors.ParserError:
        print(f"解析错误: {txt_path}")
        continue
    except Exception as e:
        print(f"读取文件时发生错误: {txt_path}, 错误: {e}")
        continue
    
    # 构建输出 Excel 文件路径
    excel_file = os.path.splitext(txt_file)[0] + '.xlsx'
    excel_path = os.path.join(output_dir, excel_file)
    
    try:
        # 尝试将 DataFrame 保存为 Excel 文件
        df.to_excel(excel_path, index=False)
    except Exception as e:
        print(f"保存 Excel 文件时发生错误: {excel_path}, 错误: {e}")

print("所有文件已成功转换并保存到 'bio_excel_16s' 文件夹中。")
