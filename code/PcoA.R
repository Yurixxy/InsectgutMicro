# 加载必要的包
library(ggplot2)
library(dbscan)
library(dplyr)
library(viridis)

data <- read.csv("/Users/SUO/Desktop/data_alpha_PcoA.csv")  # 更换为你的文件路径

PcoA_plot_1 <- ggplot(data, aes(x = PC1, y = PC2)) +
  stat_ellipse(aes(group = InsectOrder, color = InsectOrder), type = "t", linetype = 5) +
  theme_minimal() +
  labs(
       x = "PC1(8.68%)",
       y = "PC2(5.74%)") +

  scale_color_brewer(palette = "Set1") +
  theme(
    axis.text.x = element_text(size = 14),  # 修改x轴刻度字体大小
    axis.text.y = element_text(size = 14),  # 修改y轴刻度字体大小
    axis.title.x = element_text(size = 16), # 修改x轴标题字体大小
    axis.title.y = element_text(size = 16),  # 修改y轴标题字体大小
    legend.text = element_text(size = 12),  # 修改图例标签的字体大小
    legend.title = element_text(size = 14)  # 修改图例标题的字体大小
  
  )


# 2. 使用DBSCAN进行聚类
db_1 <- dbscan(data[, c("PC1", "PC2")], eps = 0.02, minPts = 5)  # 调整 eps 以控制点的合并数量

# 将聚类结果添加到数据框中
data$cluster <- db_1$cluster

# 对每个簇进行统计，计算簇的中心位置和点的数量
clustered_data <- data %>%
  group_by(cluster, InsectOrder) %>%
  summarize(PC1 = mean(PC1), PC2 = mean(PC2), n = n(), .groups = 'drop')

# 3. 将聚类后的点叠加到原始 PCoA 图上
PcoA_plot_1 <- PcoA_plot_1 +
  geom_point(data = clustered_data, aes(x = PC1, y = PC2, color = InsectOrder, size = n), alpha = 0.7) +
  scale_size_continuous(name = "Count", range = c(1, 10)) + # 调整点的大小范围
  guides(color = guide_legend(order = 1), size = guide_legend(order = 2)) 

# 显示图形
print(PcoA_plot_1)



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
  select(InsectSpecies, InsectOrder, lifestage, PC1,PC2)

# 再次检查 lifestage 列中的唯一值
unique(filtered_data$lifestage)

PcoA_plot_2 <- ggplot(filtered_data, aes(x = PC1, y = PC2)) +
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
       x = "PC1(8.68%)",
       y = "PC2(5.74%)") +
  scale_color_brewer(palette = "Set2")


db_2 <- dbscan(filtered_data[, c("PC1", "PC2")], eps = 0.02, minPts = 5)  # 调整 eps 以控制点的合并数量

# 将聚类结果添加到数据框中
filtered_data$cluster <- db_2$cluster

# 对每个簇进行统计，计算簇的中心位置和点的数量
clustered_data <- filtered_data %>%
  group_by(cluster, lifestage) %>%
  summarize(PC1 = mean(PC1), PC2 = mean(PC2), n = n(), .groups = 'drop')

# 3. 将聚类后的点叠加到原始 PCoA 图上
PcoA_plot_2 <- PcoA_plot_2 +
  geom_point(data = clustered_data, aes(x = PC1, y = PC2, color = lifestage, size = n), alpha = 0.7) +
  scale_size_continuous(name = "Count", range = c(1, 10)) # 调整点的大小范围



print(PcoA_plot_2)






# 保存图形
ggsave(filename = "~/Desktop/PcoA_Insect.png", plot = PcoA_plot_1, 
       bg = "white", width = 8, height = 6, units = "in", dpi = 600)

# 你也可以保存为 PDF 文件
ggsave(filename = "~/Desktop/PcoA_Insect.pdf", plot = PcoA_plot_1 ,
       width = 8, height = 6, units = "in",dpi = 600)


# 保存图形
ggsave(filename = "~/Desktop/PcoA_Lifestage.png", plot = PcoA_plot_2, 
       bg = "white", width = 8, height = 6, units = "in", dpi = 600)

# 你也可以保存为 PDF 文件
ggsave(filename = "~/Desktop/PcoA_Lifestage.pdf", plot = PcoA_plot_2 ,
       width = 8, height = 6, units = "in", dpi=600)



# 1. 根据order level 聚合数据
order_data <- data %>%
  group_by(Order) %>%
  summarize(across(everything(), sum))

# 2. 计算距离矩阵
library(vegan)
distance_matrix <- vegdist(order_data[, -1], method = "bray")  # 假设第1列是分类标签

# 3. 执行PCoA分析
pcoa_result <- cmdscale(distance_matrix, eig = TRUE, k = 2)

# 4. 计算方差解释比例
eigenvalues <- pcoa_result$eig
variance_explained <- eigenvalues / sum(eigenvalues) * 100

# 5. 可视化
order_data$PC1 <- pcoa_result$points[, 1]
order_data$PC2 <- pcoa_result$points[, 2]

ggplot(order_data, aes(x = PC1, y = PC2, color = Order)) +
  geom_point() +
  labs(title = "PCoA Plot at Order Level",
       x = paste("PC1 (", round(variance_explained[1], 2), "%)", sep = ""),
       y = paste("PC2 (", round(variance_explained[2], 2), "%)", sep = "")) +
  theme_minimal()
