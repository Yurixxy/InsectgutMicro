import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import re

# Load the CSV file
file_path_new = "/Users/SUO/Desktop/data_alpha.csv"
data_new = pd.read_csv(file_path_new, low_memory=False)

# Helper function to clean up taxonomic names by removing non-alphanumeric characters and handling uncultured/None
def clean_name(name):
    if name is None:
        return 'Others'  # Handle cases where name is None
    name = re.sub(r'\W+', '', name)  # Remove non-alphanumeric characters
    name = re.sub(r'_+', '', name)  # Remove underscores
    if 'uncultured' in name or name == 'None':
        return 'Others'
    return name

# Helper function to extract and clean up the relevant taxonomic level names
def extract_level_name(col_name, level):
    if level in col_name:
        start_idx = col_name.find(level)
        name = col_name[start_idx + len(level):]  # Extract the name after the level prefix
        return name
    return None

# Extract and filter columns based on the requested levels

phylum_cols = [col for col in data_new.columns if 'p__' in col and 'c__' not in col]

family_cols = [col for col in data_new.columns if 'f__' in col and 'g__' not in col]

# Group and sum by the relevant insect taxonomic rank

data_by_phylum_all = data_new.groupby('InsectOrder')[phylum_cols].sum().T

data_by_family_all = data_new.groupby('InsectOrder')[family_cols].sum().T

# Normalize to relative abundance across all categories

data_by_phylum_all = data_by_phylum_all.div(data_by_phylum_all.sum(axis=0), axis=1)

data_by_family_all = data_by_family_all.div(data_by_family_all.sum(axis=0), axis=1)

# Select top N groups

top_phyla = data_by_phylum_all.sum(axis=1).sort_values(ascending=False).head(10).index

top_families = data_by_family_all.sum(axis=1).sort_values(ascending=False).head(50).index

# Filter the data for top groups, other groups will be summed as "Others"
def filter_top_groups(data, top_groups):
    others = data.loc[~data.index.isin(top_groups)].sum()
    data_filtered = data.loc[top_groups]
    data_filtered.loc['Others'] = others  # Sum the remaining as "Others"
    return data_filtered

# Combine "Others" entries into one
def combine_others(data):
    if 'Others' in data.index:
        others_total = data.loc[data.index.str.contains('Others')].sum()
        data = data[~data.index.str.contains('Others')]
        data.loc['Others'] = others_total
    return data


data_by_phylum = filter_top_groups(data_by_phylum_all, top_phyla)

data_by_family = filter_top_groups(data_by_family_all, top_families)


data_by_phylum.index = [clean_name(extract_level_name(col, 'p__')) for col in data_by_phylum.index]

data_by_family.index = [clean_name(extract_level_name(col, 'f__')) for col in data_by_family.index]


data_by_phylum = combine_others(data_by_phylum)

data_by_family = combine_others(data_by_family)

# Function to save individual plots as PDF
# Function to save individual plots as PDF with specified customizations
def save_plot(data, title, filename, color_palette, ncol_legend=1, 
              title_size=16, label_size=14, tick_size=10, legend_size=10, bar_width=0.8):
    fig, ax = plt.subplots(figsize=(12, 8))
    
    # 数据乘以100，转换为百分比
    data = data * 100
    
    # 绘制条形图，并设置条形的宽度
    data.T.plot(kind='bar', stacked=True, ax=ax, color=color_palette, width=bar_width)
    
    # 设置标题和轴标签的字号
    ax.set_title(title, fontsize=title_size)
    ax.set_ylabel('Relative Abundance (%)', color='black', fontsize=label_size)  # 将单位改为%
    #ax.set_xlabel('Insect Order', color='black', fontsize=label_size)
    
    # 设置坐标轴刻度标签颜色和字号
    ax.tick_params(axis='x', colors='black', labelsize=tick_size)
    ax.tick_params(axis='y', colors='black', labelsize=tick_size)

    # 设置Y轴范围为0-100，单位为百分比
    ax.set_ylim(0, 100)  # 设置Y轴范围为0-100

    # 设置边框颜色
    ax.spines['top'].set_color('none')
    ax.spines['right'].set_color('none')
    ax.spines['bottom'].set_color('black')
    ax.spines['left'].set_color('black')

    # 设置图例为正方形标志，并设置图例字号
    ax.legend(title='', bbox_to_anchor=(1.02, 0.5), loc='center left', fontsize=legend_size, 
              ncol=ncol_legend, frameon=False, handlelength=1.5, handleheight=1.5)

    # 设置X轴标签的旋转角度和对齐方式
    plt.xticks(rotation=45, ha='right')
    
    plt.tight_layout()
    
    # 保存图像为PDF文件
    plt.savefig(filename, format='pdf', bbox_inches='tight', dpi=600)
    plt.close(fig)




# Generate and save individual plots as PDF
# order_colors = sns.color_palette("magma", len(data_by_order.index))
# class_colors = sns.color_palette("inferno", len(data_by_class.index))
# phylum_colors = sns.color_palette("viridis", len(data_by_phylum.index))
# kingdom_colors = sns.color_palette("plasma", len(data_by_kingdom.index))
# family_colors = sns.color_palette("cividis", len(data_by_family.index))


phylum_colors = plt.cm.get_cmap('Paired', len(data_by_phylum.index)).colors

family_colors = plt.cm.get_cmap('tab20b', len(data_by_family.index)).colors


# 调用save_plot函数，并自定义各个参数的大小



save_plot(data_by_phylum, 
          title='', 
          filename='phylum.pdf', 
          color_palette=phylum_colors, 
          ncol_legend=1, 
          title_size=10, 
          label_size=14, 
          tick_size=12, 
          legend_size=8, 
          bar_width=0.5)

save_plot(data_by_family, 
          title='', 
          filename='family.pdf', 
          color_palette=family_colors, 
          ncol_legend=2, 
          title_size=14, 
          label_size=16, 
          tick_size=12, 
          legend_size=10, 
          bar_width=0.5)



# 导出计算完relative abundance的表格

# 定义导出数据的函数
def export_relative_abundance(data, filename):
    data.to_csv(filename, index=True)

# 导出每个层级的relative abundance数据

export_relative_abundance(data_by_phylum, 'data_by_phylum_relative_abundance.csv')

export_relative_abundance(data_by_family, 'data_by_family_relative_abundance.csv')

import seaborn as sns

print(sns.palettes.SEABORN_PALETTES)
