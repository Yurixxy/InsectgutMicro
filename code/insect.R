# 加载必要的包
library(ggplot2)
library(readxl)
library(dplyr)
library(tidyr)
library(patchwork)


# 读取数据
data <- read.csv("/Users/SUO/Desktop/data_alpha.csv")  # 更换为你的文件路径


# 查看合并后的数据
print(head(data))
numeric_data <- data[, sapply(data, is.numeric)]
data$Shannon <- diversity(numeric_data, index = "shannon")

data$Richness <- specnumber(numeric_data)
data$LogRichness <- log1p(data$Richness)





# 修改后的两个图的代码（与之前相同）
plot1 <- ggplot(data, aes(x = InsectOrder, y = Shannon)) +
  geom_boxplot() +
  geom_point(aes(color = InsectSpecies), position = position_jitter(width = 0.2), size = 1.0, alpha = 0.3) +
  scale_color_viridis_d() +
  theme_minimal() +
  theme(axis.text.x = element_blank(),
        axis.title.x = element_blank(),
        text = element_text(size = 10),
        legend.position = "none") +
  labs(title = "Distribution of Shannon Entropy across Insect Orders",
       y = "Shannon Entropy")

plot2 <- ggplot(data, aes(x = InsectOrder, y = LogRichness)) +
  geom_boxplot() +
  geom_point(aes(color = InsectSpecies), position = position_jitter(width = 0.2), size = 1.0, alpha = 0.3) +
  scale_color_viridis_d() +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        text = element_text(size = 10),
        legend.position = "none") +
  labs(title = "Distribution of Log-Family-level Richness across Insect Orders",
       x = "Insect Order",
       y = "Log(Family-level Richness)")


# 使用 patchwork 将两个图合并
combined_plot <- plot1 / plot2

print(combined_plot)

# 保存图形，指定大小和分辨率
ggsave(filename = "~/Desktop/combined_plot.png", plot = combined_plot, 
       width = 8, height = 10, units = "in", dpi = 600)

# 你也可以保存为 PDF 文件
ggsave(filename = "~/Desktop/combined_plot.pdf", plot = combined_plot, 
       width = 8, height = 6, units = "in")


#删除异常值
Q1_Shannon <- quantile(data$ShannonEntropy, 0.25, na.rm = TRUE)
Q3_Shannon <- quantile(data$ShannonEntropy, 0.75, na.rm = TRUE)
IQR_Shannon <- Q3_Shannon - Q1_Shannon

Q1_Pielou <- quantile(data$PielouEvenness, 0.25, na.rm = TRUE)
Q3_Pielou <- quantile(data$PielouEvenness, 0.75, na.rm = TRUE)
IQR_Pielou <- Q3_Pielou - Q1_Pielou

# 根据IQR原则定义异常值范围
data_clean <- data %>%
  filter(
    ShannonEntropy >= (Q1_Shannon - 1.5 * IQR_Shannon) & ShannonEntropy <= (Q3_Shannon + 1.5 * IQR_Shannon),
    PielouEvenness >= (Q1_Pielou - 1.5 * IQR_Pielou) & PielouEvenness <= (Q3_Pielou + 1.5 * IQR_Pielou)
  )


# 假设您的数据有一个分类列，比如 'Group'
# 加载必要的库
library(ggplot2)

# 计算每个组的圆心位置
centroids <- data_clean %>%
  group_by(InsectOrder) %>%
  summarize(PC1 = median(PC1), PC2 = median(PC2))

# 使用Insect Order作为分组变量
ggplot(data_clean, aes(x = PC1, y = PC2, color = factor(InsectOrder))) +
  geom_point(alpha = 0.6, size = 0.2) +  # 显示原始点
  stat_ellipse(level = 0.95, aes(fill = factor(InsectOrder)), geom = "polygon", alpha = 0.2) +  # 添加95%置信椭圆
  theme_minimal() +
  labs(title = "PCoA Scatter Plot with Insect Order Ellipses", x = "PC1", y = "PC2") +
  scale_color_discrete(name = "Insect Order") +
  geom_point(data = centroids, aes(x = PC1, y = PC2), color = "purple", size = 3, shape = 4) +  
  scale_fill_discrete(name = "Insect Order")

ggplot(centroids, aes(x = PC1, y = PC2, color = factor(InsectOrder))) +
  geom_point(alpha = 0.6, size = 0.2) +
  geom_point(data = centroids, aes(x = PC1, y = PC2), color = "purple", size = 3, shape = 4) 


