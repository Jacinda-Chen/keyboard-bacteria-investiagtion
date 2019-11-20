# The following is some example code that you can use for a starting
# point in your own analyses within the chunks of your rmarkdown
# report

# Be sure to install these packages before running this script
# They can be installed either with the intall.packages() function
# or with the 'Packages' pane in RStudio

# load general-use packages
library("dplyr")
library("tidyr")
library("knitr")
library("ggplot2")
library("lubridate")
library("forcats")

# These are the primary packages well use to clean and analyze the data
# this package needs to be installed from bioconductor -- it's not on CRAN
# see info here: https://benjjneb.github.io/dada2/dada-installation.html
library("dada2")

# And this to visualize our results
# it also needs to be installed from bioconductor
library("phyloseq")

# load in the saved phyloseq object to work with
load("output/phyloseq_obj.Rda")

##########################################
# Phyloseq-native analyses
##########################################

# alpha diversity metrics -- see many more
# examples here, under 'Tutorials': https://joey711.github.io/phyloseq
# JC: For r checkpoint, load phyloseq_obj, which is our processed data
# and summarizing it. Starter code in order to modify these.
# otu_table, tax_table, sam_data included.
plot_richness(phyloseq_obj,
              x = "type",
              measures = c("Shannon")) +
  xlab("Type of sample") +
  geom_boxplot() +
  theme_bw() +
  ggtitle("Diversity of Samples")

# bar plot of taxa my month sampled
plot_bar(phyloseq_obj,
         x = "type",
         fill = "Phylum")

##########################################
# dplyr and ggplot analyses
##########################################

# melt phyloseq obj into a data frame for dplyr/ggplot
# analysis and visualization
melted_phyloseq <- psmelt(phyloseq_obj)

# turn all factor columns into character columns for dplyr
melted_phyloseq <- melted_phyloseq %>%
  mutate_if(is.factor, as.character)

# create a summary table of sequence counts for each Phylum
melted_phyloseq %>%
  group_by(student_initials, Phylum) %>%
  summarize(sum_abundance = sum(Abundance,
                                  na.rm = TRUE))

# create a summary table of abundance summary for each Phylum
melted_phyloseq %>%
  group_by(student_initials, Phylum) %>%
  summarize(sum_abundance = sum(Abundance,
                                na.rm = TRUE)) %>%
  ggplot(aes(x = Phylum,
             y = sum_abundance)) +
  geom_col() +
  theme(axis.text.x = element_text(angle = 90,
                                   hjust = 1,
                                   vjust = 0.5))
