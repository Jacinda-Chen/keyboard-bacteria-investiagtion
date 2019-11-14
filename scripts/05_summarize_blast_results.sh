#!/bin/bash

# use cut, sort, and uniq -c to help you summarize the results from the
# BLAST search.

# Jacinda Chen
# November 11, 2019
# jrchen@dons.usfca.edu

for blast in /data/my-illumina-sequences/blast_output/JC*.csv
do
	echo Now sorting "$blast"
	cut -d, -f1 "$blast" | sort | uniq -c | sort -n
	echo Done
done
