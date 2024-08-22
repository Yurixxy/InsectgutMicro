import subprocess

# conda activate qiime2-amplicon-2024.5

# Read Bioproject IDs from the bioproject_result.txt file
with open('/home/xinyu/Desktop/bioproject_cut.txt', 'r') as file:
    bioproject_ids = [line.strip() for line in file if line.strip()]



# Loop through each Bioproject ID
for bioproject_id in bioproject_ids:
    try:
        print(f"Starting processing for Bioproject ID: {bioproject_id}")
        # RUN SRA runinfo FILE
        output_file = f"/home/xinyu/{bioproject_id}.txt"
        esearch_command = f'esearch -db sra -query "{bioproject_id}[bioproject]" | efetch -format runinfo | cut -f 1 -d \',\' | sed \'1d\' > {output_file}'
        subprocess.run(esearch_command, shell=True, check=True)
        
        # RUN download_srr.sh
        print(f"Running download_srr.sh for {bioproject_id}")
        subprocess.run(["bash", "download_srr.sh", bioproject_id], check=True)
        
        # RUN cutadapt.sh
        print(f"Running cutadapt.sh for {bioproject_id}")
        subprocess.run(["bash", "cutadapt.sh", bioproject_id], check=True)
        
        # RUN trmanifest.sh
        print(f"Running trmanifest.sh for {bioproject_id}")
        subprocess.run(["bash", "trmanifest.sh", bioproject_id], check=True)
        
        # RUN qiime.sh
        print(f"Running qiime.sh for {bioproject_id}")
        subprocess.run(["bash", "qiime.sh", bioproject_id], check=True)

        # RUN .fastq FILE
        print(f"Cleaning up .fastq files for {bioproject_id}")
        subprocess.run("rm *.fastq", shell=True, check=True, cwd=f"/home/xinyu/{bioproject_id}")
        
        print(f"Processed {bioproject_id}")
    except subprocess.CalledProcessError as e:
        print(f"Error processing {bioproject_id}: {e}")



