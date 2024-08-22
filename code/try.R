library(qiime2R)
library(phyloseq)


# if (!requireNamespace("devtools", quietly = TRUE)){install.packages("devtools")}
# devtools::install_github("jbisanz/qiime2R")


metadata <- read.csv("/Users/SUO/Desktop/master project/final_16s.csv", header = TRUE, sep = ",", row.names = 1)
sv<-read_qza('/Users/SUO/Desktop/master project/final-merged-table.qza')
feature_table<-sv$data
taxonomy <- read.table("/Users/SUO/Desktop/master project/tax.tsv", header = TRUE, sep = "\t", row.names = 1, fill = TRUE)

# 先读取文件，但不设置行名
taxonomy <- read.table("/Users/SUO/Desktop/tax.tsv", header = TRUE, sep = "\t", row.names = NULL)

# 检查哪些行名是重复的
duplicated_ids <- taxonomy[duplicated(taxonomy[, 1]), 1]
print(duplicated_ids)

# 只保留第一个出现的行，删除后续的重复行
taxonomy <- taxonomy[!duplicated(taxonomy[, 1]), ]

colnames(feature_table)
rownames(metadata)

samples_to_keep <- intersect(colnames(feature_table), rownames(metadata))
samples_to_remove <- setdiff(colnames(feature_table), samples_to_keep)

feature_table_filtered <- feature_table[, samples_to_keep]






# 加载必要的包
library(ggplot2)
library(dplyr)
library(tidyr)

# 读取CSV文件
data <- read.table("/Users/SUO/Desktop/tax.tsv")  # 更新为您的文件路径

# 查看数据结构
str(data)
head(data)

# 假设数据中有样本ID列和不同taxa级别的丰度数据
# 数据整理（根据数据格式调整此步骤）
# 将数据转换为长格式，方便ggplot2绘图
data_long <- data %>%
  pivot_longer(cols = starts_with("taxa_"),  # 假设taxa列是以"taxa_"开头
               names_to = "Taxa", 
               values_to = "Abundance") %>%
  mutate(Taxa = factor(Taxa, levels = unique(Taxa)))  # 将Taxa转换为因子


all.data <- read.csv("/Users/SUO/Desktop/updated_merged_level-4.csv", row.names = 1, header = T)  # load the data
dim(all.data)
all.data[1:3, 1:4]

# 选择数值型列
all.data_numeric <- all.data[, sapply(all.data, is.numeric)]

# 计算每个样品中各个物种的相对丰度
data.prop <- all.data_numeric / rowSums(all.data_numeric)

data.prop[1:3, 1:3]
# 选择数值型列
maxab <- apply(data.prop, 2, max)

# remove the genera with less than 1% as their maximum relative abundance
n1 <- names(which(maxab < 0.01))
data.prop.1 <- data.prop[, -which(names(data.prop) %in% n1)]
dim(data.prop.1)
#[1] 24 62






