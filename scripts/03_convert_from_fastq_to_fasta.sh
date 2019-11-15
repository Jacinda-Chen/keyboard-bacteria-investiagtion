#!/bin/bash

# convert to fasta for BLAST
# you need to modify this to save the converted fasta file to a file
# instead of printing to the screen
# create a new directory with trimmed fasta files
# you'll need to turn this into a for loop too

# Jacinda Chen
# November 11, 2019
# jrchen@dons.usfca.edu

for fastqfile in /data/my-illumina-sequences/trimmed/JC*.fastq
do
	echo Now converting "$fastqfile" to fasta file
	bioawk -c fastx '{print ">"$name"\n"$seq}' "$fastqfile" > /data/my-illumina-sequences/trimmed-fasta/"$(basename -s .trim.fastq "$fastqfile")".trim.fasta
	echo Done
done
