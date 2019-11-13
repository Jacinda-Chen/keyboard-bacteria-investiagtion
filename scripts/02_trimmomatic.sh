#!/bin/bash

# run trimmomatic to throw out bad sequences, trim when quality gets low, or if
# sequences are too short you will need to turn this into a for loop to process
# all of your files
# Create for loops for trimming the data one at a time

# Jacinda Chen
# November 11, 2019
# jrchen@dons.usfca.edu

for file in /data/my-illumina-sequences/unzipped/JC*.fastq
do
	echo Now trimming "$file"
	TrimmomaticSE -threads 4 -phred33 "$file" /data/my-illumina-sequences/trimmed/"$(basename -s .fastq "$file")".trim.fastq LEADING:5 TRAILING:5 SLIDINGWINDOW:8:25 MINLEN:140
	echo Done
done
