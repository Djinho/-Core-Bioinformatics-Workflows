#!/bin/bash
# This is a shell script for automating genome assembly using SPAdes and Quast.
# This script builds off the cleaned reads from the previous `read_cleaning` tutorial.
# Advanced users may customize paths, sample IDs, and parameters as needed.

# Step 1: Set Up Directory Structure for Genome Assembly
# Create folders for input data, temporary files, and results.
mkdir -p genome_assembly/input
mkdir -p genome_assembly/tmp
mkdir -p genome_assembly/results

# Step 2: Link Cleaned Reads
# Replace "SRR26936709" with your specific sample ID if different.
ln -s /mnt/c/Users/Djinh/bioinformaic/read_cleaning/results/SRR26936709_1.clean.fq genome_assembly/input/
ln -s /mnt/c/Users/Djinh/bioinformaic/read_cleaning/results/SRR26936709_2.clean.fq genome_assembly/input/

# Step 3: Install SPAdes (if not already installed)
# sudo apt update
# sudo apt install spades -y

# Step 4: Assemble Reads with SPAdes
# Replace "SRR26936709" with the correct sample ID if different.
spades.py -o genome_assembly/tmp -1 genome_assembly/input/SRR26936709_1.clean.fq -2 genome_assembly/input/SRR26936709_2.clean.fq

# Step 5: Move Key Output to Results Directory
# Copy the final scaffolds file to the results directory for further analysis.
cp genome_assembly/tmp/scaffolds.fasta genome_assembly/results/

# Step 6: Install Quast for Assembly Quality Assessment
# Uncomment if Quast is not installed.
sudo apt install python3-pip -y
sudo pip3 install quast

# Step 7: Run Quast to Assess Assembly Quality
# The command below runs Quast with a minimum contig length of 400 bp. Adjust if necessary.
quast.py genome_assembly/results/scaffolds.fasta --min-contig 400 -o genome_assembly/results/quast_report

# Step 8: View Assembly Results
# Check the first and last lines of the scaffolds to confirm assembly structure.
echo "Viewing the first 10 lines of scaffolds.fasta:"
head genome_assembly/results/scaffolds.fasta
echo "Viewing the last 10 lines of scaffolds.fasta:"
tail genome_assembly/results/scaffolds.fasta

# Completion message
echo "Genome assembly pipeline completed successfully. Results and quality assessment are available in the 'genome_assembly/results' directory."
