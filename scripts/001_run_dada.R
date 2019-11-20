# Be sure to install these packages before running this script
# They can be installed either with the intall.packages() function
# or with the 'Packages' pane in RStudio

# load general-use packages
library("dplyr")
library("tidyr")
library("knitr")
library("ggplot2")

# this package allows for the easy inclusion of literature citations in our Rmd
# more info here: https://github.com/crsh/citr
# and here:
# http://rmarkdown.rstudio.com/authoring_bibliographies_and_citations.html
library("citr")

# These are the primary packages well use to clean and analyze the data
# this package needs to be installed from bioconductor -- it's not on CRAN
# see info here: https://benjjneb.github.io/dada2/dada-installation.html
library("dada2")

# This to export a fasta of our final denoised sequence variants
library("seqinr")

# To install this you have to install from GitHub
# See more info here: https://github.com/leffj/mctoolsr
# run this -- install.packages("devtools")
# and then this -- devtools::install_github("leffj/mctoolsr")
library("mctoolsr")

# And this to visualize our results
# it also needs to be installed from bioconductor
library("phyloseq")

# NOTE: Much of the following follows the DADA2 tutorials available here:
# https://benjjneb.github.io/dada2/tutorial.html
# Accessed October 19, 2017

# set the base path for our input data files
path <- "/data/my-illumina-sequences/unzipped"

# Sort ensures samples are in order
filenames_forward_reads <- sort(list.files(path, pattern = ".fastq"))

# Extract sample names, assuming filenames have format: SAMPLENAME.fastq
sample_names <- sapply(strsplit(filenames_forward_reads, "\\."), `[`, 1)

# Specify the full path to each of the filenames_forward_reads
filenames_forward_reads <- file.path(path, filenames_forward_reads)

# Plots the quality profiles of first 14 samples
# Average quality score and position across the read.
# As the read quality goes lower, it drops off.
# However the green line stays high so it's super good quality.
plotQualityProfile(filenames_forward_reads[1:14])

# BEGINNING OF TRIMMOMATIC VERSION R

# Place filtered files in filtered/ subdirectory
# note this will fail if the directory doesn't exist
filter_path <- file.path("/home", "Chen_Jacinda", "filtered")
filtered_reads_path <- file.path(filter_path,
                                 paste0(sample_names,
                                        "_filt.fastq"))

# See ?filterAndTrim for details on the parameters
# See here for adjustments for 454 data:
# https://benjjneb.github.io/dada2/
#     faq.html#can-i-use-dada2-with-my-454-or-ion-torrent-data
filtered_output <- filterAndTrim(fwd = filenames_forward_reads,
                                 filt = filtered_reads_path,
                                 maxN = 0, # discard any seqs with Ns
                                 maxEE = 3, # allow w/ up to 3 expected errors
                                 truncQ = 2, # cut off if quality gets this low
                                 rm.phix = TRUE,
                                 compress = TRUE,
                                 multithread = TRUE)

# produce nicely-formatted markdown table of read counts
# before/after trimming
kable(filtered_output,
      col.names = c("Reads In",
                    "Reads Out"))

# get paths of all files that made it through trimming
filtered_reads_path <- list.files(filter_path, full.names = TRUE)

# this build error models from each of the samples
errors_forward_reads <- learnErrors(filtered_reads_path,
                                    multithread = TRUE)

# quick check to see if error models match data
# (black lines match black points) and are generally decresing left to right
# JC: there's noise in the process. Can't assume every one of your sequences
# are accurate. Fitting these models "black lines" to all of the different
# ways in which sequences switch if everything in the same for all of the
# sequences but one G turns into a T, then it calculates the error for
# that switch based on the quality of the base
# looking for the black lines, as the x goes up (higer quality), error goes
# down
# looks funny because most of our sequences were so high quality, this was
# meant to work with dirtier data
plotErrors(errors_forward_reads,
           nominalQ = TRUE)

# get rid of any duplicated sequences
# JC: creating a unique list of sequences ("I have this thing a thousand times")
dereplicated_forward_reads <- derepFastq(filtered_reads_path,
                                         verbose = TRUE)

# get names of all files that made it through trimming
filenames_filtered_reads <- list.files(filter_path)

# Extract sample names, assuming filenames have format: SAMPLENAME.fastq
sample_names <- sapply(strsplit(filenames_filtered_reads, "\\."), `[`, 1)

# Name the derep-class objects by the sample names
names(dereplicated_forward_reads) <- sample_names

# run dada2 -- more info here:
# https://benjjneb.github.io/dada2
# JC: taking dereplicated reads and error model and create a "true" list
# of sequences
dada_forward_reads <- dada(dereplicated_forward_reads,
                           err = errors_forward_reads,
                           multithread = TRUE)

# check dada results
# JC: I only think that there are 110 different things in 5A
# a lot of the diversity are just artifacts. Biological truth without copies.
dada_forward_reads

# produce the 'site by species matrix'
sequence_table <- makeSequenceTable(dada_forward_reads)

# Quick check to look at distribution of trimmed and denoised sequences
# JC: looking for is that most of the things are appropriately long at 140
# and 150 from left corner
# low bp mean that it trimmed a lot
hist(nchar(getSequences(sequence_table)),
     main = "Histogram of final sequence variant lengths",
     xlab = "Sequence length in bp")

# Check for and remove chimeras
# JC: look for PCR chimeras. Sometimes if a PCR sequence doesn't finish
# all the way can get hybrid PCR that contains two templates. Major error
# Can have half from Bacillus and half from Streptococcus
sequence_table_nochim <- removeBimeraDenovo(sequence_table,
                                            method = "consensus",
                                            multithread = TRUE,
                                            verbose = TRUE)

# What percent of our reads are non-chimeric?
# JC: 90.36% survived; good
non_chimeric_reads <- round(sum(sequence_table_nochim) / sum(sequence_table),
                            digits = 4) * 100

# Build a table showing how many sequences remain at each step of the pipeline
get_n <- function(x) sum(getUniques(x)) # make a quick function
track <- cbind(sapply(dada_forward_reads, get_n),
               rowSums(sequence_table),
               rowSums(sequence_table_nochim))

# add nice meaningful column names
colnames(track) <- c("Denoised",
                     "Sequence Table",
                     "Non-chimeric")

# set the proper rownames
rownames(track) <- sample_names

# produce nice markdown table of progress through the pipeline
kable(track)

# Remove any sequences shorter than 50 because can't assign their taxonomy
sequence_table_nochim <-
  sequence_table_nochim[, nchar(colnames(sequence_table_nochim)) > 50]

# assigns taxonomy to each sequence variant based on a supplied training set
# made up of known sequences
taxa <- assignTaxonomy(sequence_table_nochim,
                       "data/training/rdp_train_set_16.fa.gz",
                       multithread = TRUE,
                       tryRC = TRUE) # also check with seq reverse compliments

# show the results of the taxonomy assignment
unname(taxa)

# we want to export the cleaned, trimmed, filtered, denoised sequence variants
# so that we can build a phylogeny - we'll build the phylogeny outside of R
# but we need the fasta file to do so. We keep the names of each sequence as the
# sequence itself (which is rather confusing), because that's how DADA2 labels
# it's columns (e.g. 'species')
# function taken from https://github.com/benjjneb/dada2/issues/88
export_taxa_table_and_seqs <- function(sequence_table_nochim,
                                       file_seqtab,
                                       file_seqs) {
  seqtab_t <- as.data.frame(t(sequence_table_nochim)) # transpose to data frame
  seqs <- row.names(seqtab_t) # extract rownames
  row.names(seqtab_t) <- seqs # set rownames to sequences
  outlist <- list(data_loaded = seqtab_t)
  mctoolsr::export_taxa_table(outlist, file_seqtab) # write out an OTU table
  seqs <- as.list(seqs)
  seqinr::write.fasta(seqs, row.names(seqtab_t), file_seqs) # write out fasta
}

# actually run the function, with the names of the files we want it to create
# and where to put them
export_taxa_table_and_seqs(sequence_table_nochim,
                           "output/sequence_variants_table.txt",
                           "output/sequence_variants_seqs.fa")

# save necessary files from dada pipeline to use with phyloseq
save(sequence_table_nochim, file = "output/dada-results/seqtable.Rda")
save(taxa, file = "output/dada-results/taxatable.Rda")