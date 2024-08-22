import pandas as pd
import seaborn as sns
import os
import matplotlib.pyplot as plt
from scipy.cluster.hierarchy import dendrogram, linkage
from scipy.spatial.distance import pdist
from sklearn.preprocessing import StandardScaler

# 载入数据集
file_path = 'data_by_phylum_relative_abundance.csv'
data = pd.read_csv(file_path, index_col=0)

# 数据标准化
scaler = StandardScaler()
data_scaled = scaler.fit_transform(data)

# 计算树状图的链接矩阵
linkage_matrix = linkage(pdist(data_scaled), method='average')

# 调整图例和轴标签的字体大小
sns.set(font_scale=1.2)  # 全局设置字体大小比例

# 创建带有树状图的热图，并调整图例位置和字体大小
g = sns.clustermap(
    data, 
    method='average', 
    cmap="viridis", 
    figsize=(14, 14),  # 增大图表尺寸
    dendrogram_ratio=(0.2, 0.2),  # 增加树状图的比例
    linewidths=0.5  # 设置单元格之间的白色分割线宽度
)

# 使用 plt.setp 调整 x 轴和 y 轴标签的字体大小并旋转 x 轴标签
plt.setp(g.ax_heatmap.get_xticklabels(), fontsize=16, rotation=45, ha="right")  # 调整 x 轴标签的字体大小并旋转45度
plt.setp(g.ax_heatmap.get_yticklabels(), fontsize=16)  # 调整 y 轴标签的字体大小

plt.subplots_adjust(left=0.1, right=0.85, top=0.9, bottom=0.1)


g.ax_cbar.set_position((0.05, 0.1, 0.03, 0.3))  # 调整颜色条位置和大小


# 保存图像到桌面
output_path = os.path.expanduser('~/Desktop/heatmap_with_dendrogram.pdf')
plt.savefig(output_path, dpi=600, format='pdf')

plt.show()
