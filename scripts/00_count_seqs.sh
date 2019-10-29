#!/bin/bash

# a script to ocunt the number of sequences in a set of gzipped fastq files

# Jacinda Chen
# October 29, 2019
# jrchen@dons.usfca.edu

# Count the number of sequences using zgrep
zgrep -c "^+$" /iseq/control-neg*
zgrep -c "^+$" /iseq/JC*R1*
