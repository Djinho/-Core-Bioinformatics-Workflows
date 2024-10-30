#!/bin/bash
# This is a shell script for automating the read cleaning process. It's designed for advanced users who understand the commands
# and may need to customize parameters like sample IDs, quality thresholds, k-mer settings, or directories.
# 
# Script Overview:
# - Sets up directories for data input, temporary files, and final results.
# - Installs required tools (SRA Toolkit, Seqtk, FastQC, Cutadapt, KMC, and Firefox).
# - Downloads sequencing data and performs quality checks with FastQC.
# - Trims low-quality bases and unwanted sequences using Cutadapt.
# - Filters rare k-mers with KMC to improve read quality.
# - Final trimming removes 'N's and short reads, and outputs cleaned reads ready for analysis.

# Step 1: Create Directory Structure
mkdir -p read_cleaning/input
mkdir -p read_cleaning/tmp
mkdir -p read_cleaning/results

# Step 2: Install Required Software
sudo apt-get install sra-toolkit -y
sudo apt-get install seqtk -y
sudo apt-get install fastqc -y
sudo apt-get install cutadapt -y
sudo apt-get install kmc -y
sudo apt-get install firefox -y

# Step 3: Download Data (replace 'SRR26936709' with actual sample ID if needed)
cd read_cleaning
fastq-dump --split-files --gzip SRR26936709 -O input

# Step 4: Initial Quality Check
fastqc --nogroup --outdir tmp input/SRR26936709_1.fastq.gz
fastqc --nogroup --outdir tmp input/SRR26936709_2.fastq.gz

# Step 5: View FastQC Reports
firefox tmp/SRR26936709_1_fastqc.html &
firefox tmp/SRR26936709_2_fastqc.html &

# Step 6: Read Trimming with Cutadapt
cutadapt --cut 4 --quality-cutoff 8 input/SRR26936709_1.fastq.gz -o tmp/SRR26936709_1.trimmed.fq
cutadapt --cut 4 --quality-cutoff 8 input/SRR26936709_2.fastq.gz -o tmp/SRR26936709_2.trimmed.fq

# Step 7: K-mer Filtering with KMC
ls tmp/SRR26936709_1.trimmed.fq tmp/SRR26936709_2.trimmed.fq > tmp/file_list_for_kmc
kmc -m2 -k21 @tmp/file_list_for_kmc tmp/21-mers tmp

# Filter out rare k-mers
kmc_tools -t1 filter -hm tmp/21-mers tmp/SRR26936709_1.trimmed.fq -ci2 tmp/SRR26936709_1.trimmed.norare.fq
kmc_tools -t1 filter -hm tmp/21-mers tmp/SRR26936709_2.trimmed.fq -ci2 tmp/SRR26936709_2.trimmed.norare.fq

# Step 8: Final Trimming and Cleaning
cutadapt --trim-n --minimum-length 21 -o tmp/SRR26936709_1.clean.fq -p tmp/SRR26936709_2.clean.fq tmp/SRR26936709_1.trimmed.norare.fq tmp/SRR26936709_2.trimmed.norare.fq

# Step 9: Save Cleaned Reads
cp tmp/SRR26936709_1.clean.fq tmp/SRR26936709_2.clean.fq results/

# Completion message
echo "Read cleaning pipeline completed successfully. Cleaned files are in the 'results' directory."
