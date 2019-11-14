#!/bin/bash

# use cut, sort, and uniq -c to help you summarize the results from the
# BLAST search.

# Jacinda Chen
# November 11, 2019
# jrchen@dons.usfca.edu

for blast in /data/my-illumina-sequences/blast_output/JC*.csv
do
	echo Now sorting "$blast"
	cut -d, -f1 "$blast" | sort | uniq -c | sort -n | tail -15
	echo Done
done

echo Now for the controls...

for blast2 in /data/my-illumina-sequences/blast_output/control*.csv
do
	echo Now sorting "$blast2"
	cut -d, -f1 "$blast2" | sort | uniq -c | sort -n | tail -15
	echo Done
done

echo Now for the summary of JC*.csv

cut -d, -f1 /data/my-illumina-sequences/blast_output/JC*.csv | sort | uniq -c | sort -n | tail -15

echo Now for the summary of negative controls...

cut -d, -f1 /data/my-illumina-sequences/blast_output/control-neg*.csv | sort | uniq -c | sort -n | tail -15

echo Now for the summary of positive controls...

cut -d, -f1 /data/my-illumina-sequences/blast_output/control-zy*.csv | sort | uniq -c | sort -n | tail -15

echo Now for the summary of everything...

cut -d, -f1 /data/my-illumina-sequences/blast_output/*.csv | sort | uniq -c | sort -n | tail -15
