import subprocess

# conda activate qiime2-amplicon-2024.5

# Read Bioproject IDs from the bioproject_result.txt file
with open('/home/xinyu/Desktop/bioproject_dada.txt', 'r') as file:
    bioproject_ids = [line.strip() for line in file if line.strip()]

# 处理每个bioproject ID
for bioproject_id in bioproject_ids:
    try:
        print(f"Starting processing for Bioproject ID: {bioproject_id}")
         # RUN SRA runinfo FILE
        output_file = f"/home/xinyu/Bioproject/{bioproject_id}.txt"
        esearch_command = f'esearch -db sra -query "{bioproject_id}[bioproject]" | efetch -format runinfo | cut -f 1 -d \',\' | sed \'1d\' > {output_file}'
        subprocess.run(esearch_command, shell=True, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error processing {bioproject_id}: {e}")
    
