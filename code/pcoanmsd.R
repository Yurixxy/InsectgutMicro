library(ggplot2)
library(dbscan)
library(dplyr)
library(viridis)
library(vegan)
library(ggplot2)

# 读取过滤后的数据文件
data <- read.csv("/Users/SUO/Desktop/data_alpha1.csv")  # 请将路径替换为实际路径

# 假设前两列是非数值列（如样本ID、分类信息），其余列为数值数据
# 根据实际数据结构，调整列索引
numeric_data <- data[, -c(1, 2)]  # 移除前两列（样本ID和Insect Order），只保留数值数据

numeric_data <- numeric_data[, sapply(numeric_data, is.numeric)]

# 计算Bray-Curtis距离矩阵
distance_matrix <- vegdist(numeric_data, method = "bray")

# 执行PCoA分析
pcoa_result <- cmdscale(distance_matrix, eig = TRUE, k = 2)



# 提取特征值并计算方差解释比例
eigenvalues <- pcoa_result$eig
variance_explained <- eigenvalues / sum(eigenvalues) * 100

# 打印PC1和PC2的解释方差比例
cat("PC1 explains", round(variance_explained[1], 2), "% of the variance\n")
cat("PC2 explains", round(variance_explained[2], 2), "% of the variance\n")

# 添加PC1和PC2结果到原始数据框中
data$PCoa1 <- pcoa_result$points[, 1]
data$PCoa2 <- pcoa_result$points[, 2]



PcoA_plot_1 <- ggplot(data, aes(x = PCoa1, y = PCoa2)) +
  stat_ellipse(aes(group = InsectOrder, color = InsectOrder), type = "t", linetype = 5) +
  theme_minimal() +
  labs(
    x = "PC1(7.38%)",
    y = "PC2(4.72%)") +
  
  scale_color_brewer(palette = "Set1") +
  theme(
    axis.text.x = element_text(size = 14),  # 修改x轴刻度字体大小
    axis.text.y = element_text(size = 14),  # 修改y轴刻度字体大小
    axis.title.x = element_text(size = 16), # 修改x轴标题字体大小
    axis.title.y = element_text(size = 16),  # 修改y轴标题字体大小
    legend.text = element_text(size = 12),  # 修改图例标签的字体大小
    legend.title = element_text(size = 14)  # 修改图例标题的字体大小
    
  )

db_1 <- dbscan(data[, c("PCoa1", "PCoa2")], eps = 0.02, minPts = 5)  # 调整 eps 以控制点的合并数量

# 将聚类结果添加到数据框中
data$cluster <- db_1$cluster

# 对每个簇进行统计，计算簇的中心位置和点的数量
clustered_data <- data %>%
  group_by(cluster, InsectOrder) %>%
  summarize(PCoa1 = mean(PCoa1), PCoa2 = mean(PCoa2), n = n(), .groups = 'drop')

# 3. 将聚类后的点叠加到原始 PCoA 图上
PcoA_plot_1 <- PcoA_plot_1 +
  geom_point(data = clustered_data, aes(x = PCoa1, y = PCoa2, color = InsectOrder, size = n), alpha = 0.7) +
  scale_size_continuous(name = "Count", range = c(1, 10)) + # 调整点的大小范围
  guides(color = guide_legend(order = 1), size = guide_legend(order = 2)) 


filtered_data <- data %>%
  # 将空字符串替换为 NA
  mutate(lifestage = ifelse(lifestage == "", NA, lifestage)) %>%
  # 过滤掉空的 lifestage
  filter(!is.na(lifestage)) %>%
  # 计算每个 InsectSpecies 的唯一 lifestage 数量
  group_by(InsectSpecies) %>%
  filter(n_distinct(lifestage) > 1) %>%
  ungroup() %>%
  # 选择所需的列
  select(InsectSpecies, InsectOrder, lifestage, PCoa1,PCoa2)

filtered_data <- filtered_data %>%
  mutate(lifestage = ifelse(lifestage == "larva", "Larva", lifestage)) %>%
  mutate(lifestage = ifelse(lifestage == "egg", "Egg", lifestage)) %>%


# 再次检查 lifestage 列中的唯一值
unique(filtered_data$lifestage)

PcoA_plot_2 <- ggplot(filtered_data, aes(x = PCoa1, y = PCoa2)) +
  #geom_point(aes(color = lifestage), size = 0.1, alpha = 0.7) +
  stat_ellipse(aes(group = lifestage, color = lifestage), type = "t", linetype = 5) + 
  theme_minimal() +
  scale_color_brewer(palette = "Set1") +
  theme(
    axis.text.x = element_text(size = 14),  # 修改x轴刻度字体大小
    axis.text.y = element_text(size = 14),  # 修改y轴刻度字体大小
    axis.title.x = element_text(size = 16), # 修改x轴标题字体大小
    axis.title.y = element_text(size = 16), # 修改y轴标题字体大小
    legend.text = element_text(size = 12),  # 修改图例标签的字体大小
    legend.title = element_text(size = 14)  # 修改图例标题的字体大小
    
  ) +
  labs(
    x = "PC1(7.38%)",
    y = "PC2(4.72%)") +
  scale_color_brewer(palette = "Set2")


db_2 <- dbscan(filtered_data[, c("PCoa1", "PCoa2")], eps = 0.02, minPts = 5)  # 调整 eps 以控制点的合并数量

# 将聚类结果添加到数据框中
filtered_data$cluster <- db_2$cluster

# 对每个簇进行统计，计算簇的中心位置和点的数量
clustered_data <- filtered_data %>%
  group_by(cluster, lifestage) %>%
  summarize(PCoa1 = mean(PCoa1), PCoa2 = mean(PCoa2), n = n(), .groups = 'drop')

# 3. 将聚类后的点叠加到原始 PCoA 图上
PcoA_plot_2 <- PcoA_plot_2 +
  geom_point(data = clustered_data, aes(x = PCoa1, y = PCoa2, color = lifestage, size = n), alpha = 0.7) +
  guides(color = guide_legend(order = 1), size = guide_legend(order = 2))+
  scale_size_continuous(name = "Count", range = c(1, 10)) # 调整点的大小范围



print(PcoA_plot_2)


# 你也可以保存为 PDF 文件
ggsave(filename = "~/Desktop/PcoA_Insect.pdf", plot = PcoA_plot_1 ,
       width = 8, height = 6, units = "in",dpi = 600)


# 你也可以保存为 PDF 文件
ggsave(filename = "~/Desktop/PcoA_Lifestage.pdf", plot = PcoA_plot_2 ,
       width = 8, height = 6, units = "in", dpi=600)