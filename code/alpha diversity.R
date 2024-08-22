# 加载必要的包
library(ggplot2)
library(readxl)
library(dplyr)
library(tidyr)
library(patchwork)
library(vegan)
library(ggplot2)
library(dbscan)
library(patchwork)


# 读取数据
data <- read.csv("/Users/SUO/Desktop/data_alpha.csv")  # 更换为你的文件路径


# 查看合并后的数据
numeric_data <- data[, sapply(data, is.numeric)]
data$Shannon <- diversity(numeric_data, index = "shannon")

data$Richness <- specnumber(numeric_data)
# 计算Simpson指数
data$Simpson <- diversity(numeric_data, index ="simpson")# 计算Pielou均匀度（Pielou's Evenness）# 需要先计算Shannon指数和物种丰富度
data$PielouEvenness <- data$Shannon /log(data$Richness)

# 计算每个昆虫目的样本数量和比例
summary_data <- data %>%
  group_by(InsectOrder)%>%
  summarise(
    Shannon_mean = mean(Shannon, na.rm =TRUE),
    Shannon_sd = sd(Shannon, na.rm =TRUE),
    Simpson_mean = mean(Simpson, na.rm =TRUE),
    Simpson_sd = sd(Simpson, na.rm =TRUE),
    Richness_mean = mean(Richness, na.rm =TRUE),
    Richness_sd = sd(Richness, na.rm =TRUE),
    PielouEvenness_mean = mean(PielouEvenness, na.rm =TRUE),
    PielouEvenness_sd = sd(PielouEvenness, na.rm =TRUE),
    Count = n(),# 计算每个昆虫目的样本数量
    Proportion = n()/ nrow(data))# 计算比例# 查看结果
print(summary_data)



data$LogRichness <- log1p(data$Richness)

Q1_Shannon <- quantile(data$Shannon, 0.25, na.rm = TRUE)
Q3_Shannon <- quantile(data$Shannon, 0.75, na.rm = TRUE)
IQR_Shannon <- Q3_Shannon - Q1_Shannon

Q1_LogRichness <- quantile(data$LogRichness, 0.25, na.rm = TRUE)
Q3_LogRichness <- quantile(data$LogRichness, 0.75, na.rm = TRUE)
IQR_LogRichness <- Q3_LogRichness - Q1_LogRichness

# 根据IQR原则定义异常值范围
data_clean <- data %>%
  filter(
    Shannon >= (Q1_Shannon - 1.5 * IQR_Shannon) & Shannon <= (Q3_Shannon + 1.5 * IQR_Shannon),
    LogRichness >= (Q1_LogRichness - 1.5 * IQR_LogRichness) & LogRichness <= (Q3_LogRichness + 1.5 * IQR_LogRichness),

  )




# 计算 Shannon 指数的平均值并排序
shannon_order <- data_clean %>%
  group_by(InsectOrder) %>%
  summarise(Shannon_mean = mean(Shannon, na.rm = TRUE)) %>%
  arrange(desc(Shannon_mean)) %>%
  pull(InsectOrder)

# 计算 LogRichness 的平均值并排序
logrichness_order <- data_clean %>%
  group_by(InsectOrder) %>%
  summarise(LogRichness_mean = mean(LogRichness, na.rm = TRUE)) %>%
  arrange(desc(LogRichness_mean)) %>%
  pull(InsectOrder)

# 创建第一个图，Shannon Entropy
plot1 <- ggplot(data_clean, aes(x = InsectOrder, y = Shannon)) +
  geom_boxplot(outlier.shape = NA) +  # 去除离群值
  geom_point(aes(color = InsectSpecies), position = position_jitter(width = 0.2), size = 1.5, alpha = 0.4) +
  scale_color_viridis_d() +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 14),
        axis.title.x = element_blank(),
        axis.title.y = element_text(size = 16),
        axis.text.y = element_text(size = 12),
        legend.position = "none") +
  labs(
       x = "Insect Order",
       y = "Shannon Entropy") +
  scale_x_discrete(limits = shannon_order)  # 使用 Shannon 指数排序

# 创建第二个图，Log-Family-level Richness
plot2 <- ggplot(data_clean, aes(x = InsectOrder, y = LogRichness)) +
  geom_boxplot(outlier.shape = NA) +  # 去除离群值
  geom_point(aes(color = InsectSpecies), position = position_jitter(width = 0.2), size = 1.5, alpha = 0.4) +
  scale_color_viridis_d() +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 14),
        axis.title.x = element_blank(),
        axis.title.y = element_text(size = 16),
        axis.text.y = element_text(size = 12),
        legend.position = "none") +
  labs(
       x = "Insect Order",
       y = "Log Richness") +
  scale_x_discrete(limits = logrichness_order)  # 使用 LogRichness 排序

# 使用 patchwork 将两个图合并
combined_plot <- plot1 / plot2

# 打印合并的图
print(combined_plot)

# 保存图形，指定大小和分辨率
ggsave(filename = "~/Desktop/diversity_order.png", plot = combined_plot, 
       width = 8, height = 10, units = "in", dpi = 600)

# 你也可以保存为 PDF 文件
ggsave(filename = "~/Desktop/diversity_order.pdf", plot = combined_plot, 
       width = 8, height = 10, units = "in", dpi = 600)





# 加载 dplyr 包
library(dplyr)

# 创建一个新的数据框，筛选出 lifestage 为 "Adult" 的数据
filtered_data <- data_clean %>%
  filter(lifestage == "Adult") %>%  # 筛选出 lifestage 为 "Adult" 的数据
  dplyr::select(InsectSpecies, InsectOrder, LogRichness, Shannon)  # 选择特定列


# 查看新数据框的前几行以确认结果
head(filtered_data)

Mass_data <- read.csv("/Users/SUO/Desktop/insect.csv")  # 更换为你的文件路径


combined_data <- filtered_data %>%
  left_join(Mass_data, by = "InsectSpecies")

# 查看新数据框的前几行以确认结果
head(combined_data)

combined_data$LogMass <- log1p(combined_data$Mean_Converted_Value)



# 首先，使用 na.omit() 函数去除包含 NA 值的行
clean_data <- na.omit(combined_data)


# 加载必要的包
library(ggplot2)



clean_data$weights <- 1 / (clean_data$LogMass + 0.01)  # 添加一个小常数
adult_SM <- lm(Shannon ~ LogMass, data = clean_data, weights = weights)
summary(adult_SM)

# 使用 ggplot2 绘制 LogRichness 与 LogBodyMass 之间的关系，并添加回归线
adult_R <- ggplot(clean_data, aes(x = LogMass, y = LogRichness)) +
  geom_point(aes(color = InsectOrder), size = 2, alpha = 0.6) +  # 绘制数据点
  geom_smooth(method = "lm", formula = y ~ x, se = TRUE, color = "blue", size = 1) +  # 添加回归线和置信区间
  theme_minimal() +
  labs(title = "adult Relationship between Log Richness and Log Body Mass",
       x = "Log Body Mass",
       y = "Log Richness") +
  theme(legend.position = "none") 


adult_S <- ggplot(clean_data, aes(x = LogMass, y = Shannon)) +
  geom_point(aes(color = InsectOrder), size = 2, alpha = 0.6) +  # 绘制数据点
  geom_smooth(method = "lm", formula = y ~ x, se = TRUE, color = "blue", size = 1) +  # 添加回归线和置信区间
  theme_minimal() +
  labs(title = "adult Relationship between Shannon and Log Body Mass",
       x = "Log Body Mass",
       y = "Shannon Diversity") +
  theme(legend.position = "none") 

combined_adult <- adult_S /adult_R 

print(combined_adult)

# 创建一个新的数据框，筛选掉 lifestage 为pupa 和larva 的数据


data_1 <- read.csv("/Users/SUO/Desktop/data_alpha.csv")  # 更换为你的文件路径


# 查看合并后的数据
numeric_data_1 <- data_1[, sapply(data_1, is.numeric)]
data_1$Shannon <- diversity(numeric_data_1, index = "shannon")

data_1$Richness <- specnumber(numeric_data_1)
data_1$LogRichness <- log1p(data_1$Richness)

data_1$average_weight <- (data_1$weight_min + data_1$weight_max) / 2


filtered_data_1 <- data_1 %>%
  filter(lifestage == "Pupa" | lifestage == "larva") %>%
  dplyr::select(InsectSpecies, InsectOrder, LogRichness, Shannon, average_weight, lifestage)


filtered_data_1$LogMass <- log1p(filtered_data_1$average_weight)


# 查看新数据框的前几行以确认结果
head(filtered_data_1)

# 使用 ggplot2 绘制 LogRichness 与 LogBodyMass 之间的关系，并添加回归线
lp_R <- ggplot(filtered_data_1, aes(x = LogMass, y = LogRichness)) +
  geom_point(aes(color = InsectSpecies), size = 2, alpha = 0.6) +  # 绘制数据点
  geom_smooth(method = "lm", formula = y ~ x, se = TRUE, color = "blue", size = 1) +  # 添加回归线和置信区间
  theme_minimal() +
  labs(title = "larva pupa Relationship between Log Richness and Log Body Mass",
       x = "Log Body Mass",
       y = "Log Richness") +
  theme(legend.position = "none") 
loess_model <- loess(Shannon ~ LogMass, data = clean_data)
summary(loess_model)

lp_s <- ggplot(filtered_data_1, aes(x = LogMass, y = Shannon)) +
  geom_point(aes(color = InsectOrder), size = 2, alpha = 0.6) +  # 绘制数据点
  geom_smooth(method = "lm", formula = y ~ x, se = TRUE, color = "blue", size = 1) +  # 添加回归线和置信区间
  theme_minimal() +
  labs(title = "larva pupa Relationship between Shannon and Log Body Mass",
       x = "Log Body Mass",
       y = "Shannon Diversity") +
  theme(legend.position = "none") 


combined_lp <- lp_s / lp_R 

print(combined_lp)












#比较同时拥有larva/pupa/adult的昆虫

data_2 <- read.csv("/Users/SUO/Desktop/data_alpha.csv")  # 更换为你的文件路径


# 查看合并后的数据
numeric_data_2 <- data_2[, sapply(data_2, is.numeric)]
data_2$Shannon <- diversity(numeric_data_2, index = "shannon")

data_2$Richness <- specnumber(numeric_data_2)
data_2$LogRichness <- log1p(data_2$Richness)

data_2$average_weight <- (data_2$weight_min + data_2$weight_max) / 2


filtered_data_2 <- data_2 %>%
  # 将空字符串替换为 NA
  mutate(lifestage = ifelse(lifestage == "", NA, lifestage)) %>%
  # 过滤掉空的 lifestage
  filter(!is.na(lifestage)) %>%
  # 计算每个 InsectSpecies 的唯一 lifestage 数量
  group_by(InsectSpecies) %>%
  filter(n_distinct(lifestage) > 1) %>%
  ungroup() %>%
  # 选择所需的列
  dplyr::select(InsectSpecies, InsectOrder, LogRichness, Shannon, average_weight, lifestage)

filtered_data_2 <- filtered_data_2 %>%
  mutate(lifestage = ifelse(lifestage == "larva", "Larva", lifestage))

# 再次检查 lifestage 列中的唯一值
unique(filtered_data_2$lifestage)



filtered_data_2 <- filtered_data_2 %>%
  mutate(lifestage = reorder(lifestage, -Shannon, FUN = median))  # 对 Shannon 值按中位数从大到小排序

# 创建第一个图，Shannon Entropy
plot1_ls <- ggplot(filtered_data_2, aes(x = lifestage, y = Shannon)) +
  geom_boxplot(outlier.shape = NA) +  # 去除离群值
  geom_point(aes(color = InsectSpecies), position = position_jitter(width = 0.2), size = 2, alpha = 0.5) +
  scale_color_viridis_d() +
  theme_minimal() +
 theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 14),
        axis.title.x = element_blank(),
        axis.title.y = element_text(size = 16),  # 控制y轴字体大小
        axis.text.y = element_text(size = 14),
        legend.position = "none") +
  labs(
       x = "Life Stage",
       y = "Shannon Entropy")

filtered_data_2 <- filtered_data_2 %>%
  mutate(lifestage = reorder(lifestage, -LogRichness, FUN = median))  # 对 LogRichness 值按中位数从大到小排序



filtered_data_2$LogMass <- log1p(filtered_data_2$average_weight)


plot2_ls <- ggplot(filtered_data_2, aes(x = lifestage, y = LogRichness)) +
  geom_boxplot(outlier.shape = NA) +  # 去除离群值
  geom_point(aes(color = InsectSpecies), position = position_jitter(width = 0.2), size = 2, alpha = 0.5) +
  scale_color_viridis_d() +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 14),
        axis.title.x = element_blank(),
        axis.title.y = element_text(size = 16),  # 控制y轴字体大小
        axis.text.y = element_text(size = 14),
        legend.position = "none") +
  labs(
       x = "Life Stage",
       y = "Log Richness")
combined_plot_ls <- plot1_ls / plot2_ls

# 打印合并的图
print(combined_plot_ls)

# 保存图形，指定大小和分辨率
ggsave(filename = "~/Desktop/combined_plot.png", plot = combined_plot_ls, 
       width = 8, height = 10, units = "in", dpi = 600)

# 你也可以保存为 PDF 文件
ggsave(filename = "~/Desktop/lifestage_boxplot.pdf", plot = combined_plot_ls, 
       width = 7 , height = 10, units = "in", dpi = 600)





plot_ls_all_R <- ggplot(filtered_data_2 , aes(x = LogMass, y = LogRichness)) +
  geom_point(aes(color = lifestage), size = 2, alpha = 0.6) +
  geom_smooth(method = "lm", formula = y ~ x, se = TRUE, color = "blue", size = 1) +
  theme_minimal() +
  labs(
       x = "Log Body Mass",
       y = "Log Richness") +
  theme(legend.position = "none")

plot_ls_all_S <- ggplot(filtered_data_2 , aes(x = LogMass, y = Shannon)) +
  geom_point(aes(color = lifestage), size = 2, alpha = 0.6) +
  geom_smooth(method = "lm", formula = y ~ x, se = TRUE, color = "blue", size = 1) +
  theme_minimal() +
  labs(
       x = "Log Body Mass",
       y = "Shannon Entropy ") +
  theme(legend.position = "none")

combined_plot_ls_all <- plot_ls_all_S / plot_ls_all_R

# 保存图形，指定大小和分辨率
ggsave(filename = "~/Desktop/all_lifestage_combined_plot.png", plot = combined_plot_ls, 
       width = 8, height = 10, units = "in", dpi = 600)

# 你也可以保存为 PDF 文件
ggsave(filename = "~/Desktop/all_lifestage_combined_plot.pdf", plot = combined_plot_ls, 
       width = 8, height = 6, units = "in")


# 获取所有的 InsectOrder
insect_orders <- unique(filtered_data_2$InsectOrder)

# 循环生成每个 InsectOrder 的图
for (order in insect_orders) {
  # 筛选数据
  subset_data <- filtered_data_2 %>%
    filter(InsectOrder == order)
  
  # 绘制图表
  plot <- ggplot(subset_data, aes(x = LogMass, y = LogRichness)) +
    geom_point(aes(color = lifestage), size = 2, alpha = 0.6) +
    geom_smooth(method = "lm", formula = y ~ x, se = TRUE, color = "blue", size = 1) +
    theme_minimal() +
    labs(title = paste("Lifestage Relationship between Log Richness and Log Body Mass for", order),
         x = "Log Body Mass",
         y = "Log Richness") +
    theme(legend.position = "none")
  
  # 显示图表
  print(plot)
  
  # 可选：保存图表到文件
  # ggsave(filename = paste0("plot_", order, ".png"), plot = plot)
}




# linear model compare

# 建立四个模型
model1 <- lm(Shannon ~ LogMass, data = filtered_data_2)
model2 <- lm(Shannon ~ LogMass + lifestage, data = filtered_data_2)


# 比较 AIC 和 BIC
aic_values <- AIC(model1, model2)
bic_values <- BIC(model1, model2)

# 打印 AIC 和 BIC 结果
print("AIC values:")
print(aic_values)

print("BIC values:")
print(bic_values)

# 比较 Adjusted R²
adj_r2_model1 <- summary(model1)$adj.r.squared
adj_r2_model2 <- summary(model2)$adj.r.squared


print("Adjusted R² values:")
print(paste("Model 1:", adj_r2_model1))
print(paste("Model 2:", adj_r2_model2))


# 进行 F 检验，比较模型1和模型2, 模型2和模型3
anova_model12 <- anova(model1, model2)


print("F-test between Model 1 and Model 2:")
print(anova_model12)


library(lm.beta)

# 计算标准化回归系数
model_standardized <- lm.beta(model2)

# 查看标准化系数
summary(model_standardized)
# 假设 filtered_data_2 已经包含了所需的变量
# 包括 Shannon, LogMass, 和 Lifestage



model3 <- lm(LogRichness ~ LogMass, data = filtered_data_2)
model4 <- lm(LogRichness ~ LogMass + lifestage, data = filtered_data_2)


# 比较 AIC 和 BIC
aic_values <- AIC(model3, model4)
bic_values <- BIC(model3, model4)

# 打印 AIC 和 BIC 结果
print("AIC values:")
print(aic_values)

print("BIC values:")
print(bic_values)

# 比较 Adjusted R²
adj_r2_model3 <- summary(model3)$adj.r.squared
adj_r2_model4 <- summary(model4)$adj.r.squared


print("Adjusted R² values:")
print(paste("Model 3:", adj_r2_model3))
print(paste("Model 4:", adj_r2_model4))


# 进行 F 检验，比较模型1和模型2, 模型2和模型3
anova_model34 <- anova(model3, model4)


print("F-test between Model 3 and Model 4:")
print(anova_model34)


library(lm.beta)

# 计算标准化回归系数
model_standardized <- lm.beta(model4)

# 查看标准化系数
summary(model_standardized)

r_squared <- round(summary_model$r.squared, 3)
p_value <- round(summary_model$coefficients[2, 4], 3)


# 3. 计算线性模型的预测值和置信区间
pred_lm <- predict(model3, newdata = filtered_data_2, interval = "confidence")
filtered_data_2$fit_lm <- pred_lm[, "fit"]
filtered_data_2$upr_lm <- pred_lm[, "upr"]
filtered_data_2$lwr_lm <- pred_lm[, "lwr"]

library(ggplot2)

plot <- ggplot(filtered_data_2, aes(x = LogMass, y = Shannon, color = lifestage)) +
  geom_point() +
  geom_line(aes(y = fit_lm), linetype = "solid") +
  geom_ribbon(aes(ymin = lwr_lm, ymax = upr_lm), alpha = 0.2) +
  labs(title = "Shannon vs LogMass with Predicted Values and Confidence Intervals",
       x = "LogMass", y = "Shannon") +
  theme_minimal()

# 5. 打印图形
print(plot)


# 1. 构建新的线性模型，只考虑 LogMass 对 Shannon 的影响
model_single_line <- lm(Shannon ~ LogMass, data = filtered_data_2)
summary_model <- summary(model_single_line)

#model_single_line <- lm(Shannon ~ LogMass+lifestage, data = filtered_data_2)

# 2. 计算线性模型的预测值和置信区间
pred_single_line <- predict(model_single_line, newdata = filtered_data_2, interval = "confidence")
filtered_data_2$fit_single_line <- pred_single_line[, "fit"]
filtered_data_2$upr_single_line <- pred_single_line[, "upr"]
filtered_data_2$lwr_single_line <- pred_single_line[, "lwr"]

r_squared <- round(summary_model$r.squared, 3)
p_value <- round(summary_model$coefficients[2, 4], 3)

# 3. 使用 ggplot2 绘制散点图和单一的回归线
library(ggplot2)

plotsingle <- ggplot(filtered_data_2, aes(x = LogMass, y = Shannon)) +
  geom_point() +
  geom_line(aes(y = fit_single_line), color = "brown", linetype = "solid") +
  geom_ribbon(aes(ymin = lwr_single_line, ymax = upr_single_line), alpha = 0.2, fill = "orange") +
  labs(title = "Shannon vs LogMass with Single Predicted Line and Confidence Interval",
       x = "LogMass", y = "Shannon") +
  theme_minimal() +
  annotate("text", x = Inf, y = Inf, label = paste("R² =", r_squared, "\n", "p =", p_value),
           hjust = 1.1, vjust = 2, size = 5, color = "black")





# 1. 构建新的线性模型，只考虑 LogMass 对 Shannon 的影响
model_single <- lm(LogRichness ~ LogMass, data = filtered_data_2)
summary(model_single)

#model_single_line <- lm(Shannon ~ LogMass+lifestage, data = filtered_data_2)

# 2. 计算线性模型的预测值和置信区间
pred_single <- predict(model_single, newdata = filtered_data_2, interval = "confidence")
filtered_data_2$fit_single <- pred_single[, "fit"]
filtered_data_2$upr_single <- pred_single[, "upr"]
filtered_data_2$lwr_single <- pred_single[, "lwr"]

# 3. 使用 ggplot2 绘制散点图和单一的回归线
library(ggplot2)

plotsingle2 <- ggplot(filtered_data_2, aes(x = LogMass, y = LogRichness)) +
  #geom_point() +
  geom_line(aes(y = fit_single), color = "brown", linetype = "solid") +
  geom_ribbon(aes(ymin = lwr_single, ymax = upr_single), alpha = 0.2, fill = "orange") +
  labs(title = "Shannon vs LogMass with Single Predicted Line and Confidence Interval",
       x = "LogMass", y = "LogRichness") +
  theme_minimal()





library(dbscan)
library(dplyr)
library(ggplot2)

# 使用 DBSCAN 进行聚类
db <- dbscan(filtered_data_2[, c("LogMass", "Shannon")], eps = 0.3, minPts = 5)

# 将聚类结果添加到数据框
filtered_data_2$cluster <- as.factor(db$cluster)

# 计算每个聚类的中心点和数量
clustered_data <- filtered_data_2 %>%
  group_by(cluster) %>%
  summarise(LogMass = mean(LogMass),
            Shannon = mean(Shannon),
            count = n())

# 绘制减少后的图形，点的大小根据聚类中的样本数量调整
plotsingle_clustered <- ggplot() +
  geom_line(data = filtered_data_2, aes(x = LogMass, y = fit_single_line), color = "brown", linetype = "solid") +
  geom_ribbon(data = filtered_data_2, aes(x = LogMass, ymin = lwr_single_line, ymax = upr_single_line), alpha = 0.2, fill = "orange") +
  geom_point(data = clustered_data, aes(x = LogMass, y = Shannon, size = count), color = "orange", alpha = 0.7) +
  scale_size_continuous(range = c(2, 10)) +  # 调整点的大小范围
  labs(
       x = "Log-Scaled Mass", y = "Shannon Entropy", size = "Cluster Size") +
  theme_minimal()+
  theme(
    axis.title.x = element_blank(),
    #axis.title.x = element_text(size = 16),  # 修改x轴标题字体大小
    axis.title.y = element_text(size = 16),  # 修改y轴标题字体大小
    axis.text.x = element_text(size = 14),   # 修改x轴刻度字体大小
    axis.text.y = element_text(size = 14),    # 修改y轴刻度字体大小
    panel.grid = element_blank(),            # 删除格网线
    axis.line = element_line(color = "black"), # 添加x轴和y轴的实线
    axis.ticks = element_line(color = "black") # 添加x轴和y轴的刻度线
  
  )


print(plotsingle_clustered)
library(dbscan)
library(dplyr)
library(ggplot2)

# 使用 DBSCAN 进行聚类
db <- dbscan(filtered_data_2[, c("LogMass", "LogRichness")], eps = 0.3, minPts = 5)

# 将聚类结果添加到数据框
filtered_data_2$cluster <- as.factor(db$cluster)

# 计算每个聚类的中心点和数量
clustered_data <- filtered_data_2 %>%
  group_by(cluster) %>%
  summarise(LogMass = mean(LogMass),
            LogRichness = mean(LogRichness),
            count = n())

# 确保在同一个数据集上进行预测计算和绘图
filtered_data_2 <- filtered_data_2 %>%
  mutate(fit_single = predict(model_single, newdata = filtered_data_2))

# 绘制减少后的图形，点的大小根据聚类中的样本数量调整
plotsingle2_clustered <- ggplot(filtered_data_2, aes(x = LogMass, y = LogRichness)) +
  geom_line(aes(y = fit_single), color = "brown", linetype = "solid") +
  geom_ribbon(aes(ymin = lwr_single, ymax = upr_single), alpha = 0.2, fill = "orange") +
  geom_point(data = clustered_data, aes(x = LogMass, y = LogRichness, size = count), color = "orange", alpha = 0.7) +
  scale_size_continuous(range = c(2, 10)) +  # 调整点的大小范围
  labs(
       x = "Log-Scaled Mass", y = "Log Richness", size = "Cluster Size") +
  theme_minimal()+
  theme(
    axis.title.x = element_text(size = 16),  # 修改x轴标题字体大小
    axis.title.y = element_text(size = 16),  # 修改y轴标题字体大小
    axis.text.x = element_text(size = 14),   # 修改x轴刻度字体大小
    axis.text.y = element_text(size = 14) ,   # 修改y轴刻度字体大小
    panel.grid = element_blank(),            # 删除格网线
    axis.line = element_line(color = "black"), # 添加x轴和y轴的实线
    axis.ticks = element_line(color = "black") # 添加x轴和y轴的刻度线
  )

print(plotsingle2_clustered)

combine_plot_line_all <- plotsingle_clustered/plotsingle2_clustered

# 你也可以保存为 PDF 文件
ggsave(filename = "~/Desktop/combine_plot_line_all.pdf", plot = combine_plot_line_all, 
       width = 7, height = 10, dpi=600, units = "in")





summary()