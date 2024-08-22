import requests
import xml.etree.ElementTree as ET
import pandas as pd

# 读取 BioProject ID 文件
with open('perdect.txt', 'r') as file:
    bioproject_ids = [line.strip() for line in file.readlines()]

# 初始化元数据列表
metadata_list = []

# 获取每个 BioProject 的元数据
for bioproject_id in bioproject_ids:
    url = f'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=bioproject&id={bioproject_id}&retmode=xml'
    response = requests.get(url)
    if response.status_code == 200:
        root = ET.fromstring(response.content)
        docsum = root.find('DocSum')
        if docsum is not None:
            metadata = {item.find('Name').text: item.find('Value').text for item in docsum.findall('Item')}
            metadata_list.append(metadata)
    else:
        print(f"Failed to retrieve metadata for BioProject ID {bioproject_id}")

# 将元数据列表保存为CSV文件
df = pd.DataFrame(metadata_list)
df.to_csv('bioproject_metadata.csv', index=False)
