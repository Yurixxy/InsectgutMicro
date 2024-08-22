import requests
import os

def fetch_sra_accessions(bioproject_id):
    url = f"https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=sra&term={bioproject_id}&retmode=json&retmax=1000"
    response = requests.get(url)
    if response.status_code == 200:
        result = response.json()
        if 'esearchresult' in result and 'idlist' in result['esearchresult']:
            sra_ids = result['esearchresult']['idlist']
            accessions = []
            for sra_id in sra_ids:
                accession = fetch_sra_details(sra_id)
                if accession:
                    accessions.append(accession)
            return accessions
    return []

def fetch_sra_details(sra_id):
    url = f"https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=sra&id={sra_id}&retmode=json"
    response = requests.get(url)
    if response.status_code == 200:
        result = response.json()
        if 'result' in result and sra_id in result['result']:
            if 'accession' in result['result'][sra_id]:
                return result['result'][sra_id]['accession']
    return None

# 指定Bioproject ID
bioproject_id = 'PRJNA1128369'

# 获取SRA accessions
accessions = fetch_sra_accessions(bioproject_id)

# 指定输出文件的路径，以Bioproject ID命名
output_dir = os.path.expanduser('~/Desktop/SRA')
output_file = os.path.join(output_dir, f'{bioproject_id}.txt')

# 确保输出目录存在
os.makedirs(output_dir, exist_ok=True)

# 保存到TXT文件
with open(output_file, 'w') as file:
    for accession in accessions:
        file.write(f"{accession}\n")

print("Finished fetching accession list.")
print(f"Results saved to {output_file}")
