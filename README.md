---

### The Role of Body Size in Shaping Insect Microbiomes Across Life Stages  

---

## Main Purpose  

1. Could there be a positive relationship between body weight (body size) and insect gut microbial diversity?  
2. Does the influence of body weight (body size) on the diversity and composition of insect gut microbiota vary significantly across different life stages?  

---

## Main Methods  

1. **Download**  
   Download 16S rRNA sequence data of insect gut microbiomes from the NCBI website.  

2. **Analysis**  
   Use Qiime2 for OTU (Operational Taxonomic Unit) table generation and Alpha Diversity Analysis.  

3. **Modeling**  
   Use Python or R Studio for model fitting to evaluate the linear relationship between body size and diversity.  

---

## NCBI Data Structure  

1. **Search Strategy**  
   - Use the NCBI Taxonomy Browser to search for “insect gut metagenome” as the organism.  

2. **BioProjects**  
   - Total: 641 BioProjects (filename: `Final_Updated_Project_Data.csv/.xlsx`).  
   - Usable data: 541 BioProjects with raw data available.  

3. **SRA Files**  
   - Each BioProject contains multiple SRA files, typically named `SRR…`, `ERR…`, or `DRR…`. 
   - Download these files and convert them into FASTQ format for Qiime2 analysis.  

---

## Code Descriptions  

Before read up every single code, I suggest you to read these codes first:

   `XieMasterProjectPipeline.ipynb`
  
   `dataprocess.ipynb`
   
   `run_pipeline.py`
   
   `download_srr.sh` 
   
   `cutadapt.sh`
   
   `manifest.sh` 
   
   `qiime.sh`
   
   `alpha diversity.R`
   
   `pcoanmsd.R` 
   
After reading them you will have a breif understanding of the workflow.


1. **PcoA.R**  
   - Input data file: `data_alpha_PcoA.csv`.  
   - Conducts PCoA using distance matrices from Qiime2. Since only distance matrices within the same BioProject were analyzed, the explanatory power of the results was low. It is recommended to use the `vegan` package in R to compute distance matrices and perform PCoA analysis. See lines 128–153 in this file or refer to `pcoanmsd.R` for further details.  

2. **SRR_fasterq.sh**  
   - This code is used to download the SRA files listed in `SRR_Acc_List.txt` and convert them into FASTQ format. This script is similar to `download_srr.sh`, so it can be ignored in favor of `download_srr.sh`.  

3. **XieMasterProjectPipeline.ipynb**  
   - Start with this file to understand the overall project process. It can be read alongside the `pipeline.pptx` in the `documents` folder.  

4. **accessionlist.py**  
   - Each BioProject contains an accession list with the names of all SRA files in the project. This list is needed for downloading the corresponding SRA files.  

5. **alpha diversity.R**  
   - Input data file: `data_alpha.csv`.  
   - This file already includes data from Qiime2 diversity analysis. The data is imported into R for plotting and linear model construction and comparison.  

6. **convertexcel.py**  
   - This code converts TXT data into Excel format. This file is not very useful as CSV is faster and easier to use for data analysis.  

7. **cutadapt.sh**  
   - Used for initial filtering of raw data.  

8. **dataprocess.ipynb**  
   - A simplified version of the pipeline, retaining only the most important code steps for reference.  

9. **dataprocess.sh**  
   - This bash file was an attempt to combine multiple steps (cutadapt + primer sequence removal) into a single script. Due to the large data volume and varied primers, it ultimately failed.  

10. **download_Biopj.py**  
    - This script downloads the SRA list for each BioProject. Its function is similar to `accessionlist.py`.  

11. **download_and_convert.sh**  
    - Downloads the SRA files and converts them to FASTQ format.  

12. **download_srr.sh**  
    - This file includes the content of scripts 2, 8, 9, and 11, with some duplicated parts.  
13. **excel.py**  
    - Combines columns from multiple TXT files into a single Excel file. It is recommended to use CSV or TSV for more space-efficient and programming-friendly data handling.  

14. **fil.py**  
    - Reads a file and filters data based on a specified column name.  

15. **generate_sra_lists.py**  
    - Generates an SRA ID list. This file reflects my lengthy process of downloading data.  

16. **insect.R**  
    - Input data file: `data_alpha.csv`.  
    - Contains some overlapping content with `alpha diversity.R` and `PcoA.R`; use them together for reference.  

17. **Insectorder.py**  
    - Input data file: `昆虫.xlsx`.  
    - Matches common insect names to their respective scientific order names.  

18. **list_files_to_csv.sh**  
    - Retrieves a list of all filenames in a specified path.  

19. **manifest.sh**  
    - After obtaining FASTQ files, a `manifest.txt` file is needed for importing them into Qiime2. This file contains IDs and paths for paired forward and reverse reads. This step is crucial as different data types require different manifest files and import commands. My study used double reads (e.g., sequencing by Illumina is double; sequencing by PacBio is single).  

20. **merge.sh**  
    - Merges two tables with the same columns.  

21. **meta.py**  
    - Each BioProject webpage includes a metadata table (e.g., sample collection location, food source, insect life stage). This Python code downloads and saves it as a CSV file.  

22. **pcoanmsd.R**  
    - Input data file: `data_alpha1.csv`.  
    - Recalculates PCoA and distance matrices based on results from Qiime2 analysis. This is a more detailed code version of the last lines of `PcoA.R`.  

23. **qiime.sh**  
    - This bash file includes specific Qiime2 operations: data import, denoising, clustering, taxonomy annotation, OTU table creation, and Alpha and Beta diversity analysis. (Qiime2 can also construct Phylogenetic trees and is a powerful platform, though slow with large datasets).  

24. **run_fastqc.sh**  
    - FastQC is a useful tool for checking sequence quality and generates a webpage-like output displaying sequence information. It overlaps in functionality with Qiime2 and was not used in my research.  

25. **run_pipeline.py**  
    - A comprehensive Python script that loops through the complete workflow, including `download_srr.sh`, `cutadapt.sh`, `manifest.sh`, `qiime.sh`, and final deletion of redundant raw FASTQ files.  

26. **run_pipeline_download.py**  
    - Nearly identical to `run_pipeline.py`.  

27. **sciencename.py**  
    - Adds the scientific names of insects. Not essential for the analysis.  

28. **single.py**  
    - Filters single sequence files. Refer to the explanation in code 19 for details.  

29. **singlefilter.py**  
    - Similar content to `single.py`.  

30. **taxa.py**  
    - Input data file: `data_by_phylum_relative_abundance.csv`.  
    - Generates tree diagrams and heatmaps.  

31. **taxafamily.py**  
    - Input data file: `data_alpha.csv`.  
    - Calculates and exports the relative abundance data for each level and generates corresponding bar charts (`pic/microbiome_stacked_barplots_custom_size.png`).  

32. **trmanifest.sh**  
    - Similar to `manifest.sh`, but used in actual operations.  

33. **try.R**  
    - Attempts to import Qiime2 files into R for further diversity analysis. Although this attempt failed, it demonstrates that diversity analysis can also be conducted in R Studio (suitable for smaller datasets).  

---

## Data Description  

1. Filtered and analyzed data is saved in `data_alpha.csv`.  
2. Relevant relative abundance data can be found in files such as `data_by_phylum_relative_abundance.csv`.  
3. Details about the data collection and cleaning process can be found in the Methods section of my research document.  

---

## Summary and Future Research Directions  

This project began with discussions with my supervisor, Samraat (an amazing supervisor!!!). Our hypothesis was that： larger insects tend to have lower metabolic rates. My research findings indicated that larger insects do have richer gut microbiome diversity. This leads to questions about the relationship between an insect's metabolic rate and gut microbial diversity. However, due to the complexity of the data and the limited time frame, I could not continue this interesting line of research further. During my symposium and viva, Vincent, Samantha, and Tobias also provided some great insights.  

### Potential Future Research Directions:  
In addition to examining body size and gut microbiome diversity, future studies could explore:  
1. **Food retention time in the gut**  
2. **Insect habitat range**  
3. **Different food types (e.g., pH levels)**

and their relationship with gut microbiome diversity

My research, although a bit valuable, faced data limitations as it was based on previous experimental data with varying conditions, making it difficult to standardize comparisons. For example: the NCBI didn't provide the insect mass data, I used the insect body mass data from my lab member George (Thank you George!!). For those with the means, conducting controlled lab experiments where variables are controlled, and all the PCR and 16S rRNA analysis are performed by yourself would be better.  

Overall, despite being somewhat rudimentary, this project represents a bold attempt to explore the insect world. I hope future researchers will approach this topic with open-mindedness and continue exploring such interesting themes!  

--- 
