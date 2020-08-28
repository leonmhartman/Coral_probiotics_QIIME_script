#!/bin/sh

# Execution times are based on an environment with 16 cores and 64 Gb RAM.

#---------------------------------------------------------#

#Set the TMPDIR variable.
rm -r /mnt/readwrite
mkdir /mnt/readwrite
export TMPDIR='/mnt/readwrite'

#---------------------------------------------------------#

# Process the read data from RUN 1

#Import the run 1 files.
#Execution time: 1-2 hours

qiime tools import \
--type SampleData[PairedEndSequencesWithQuality] \
--input-path /mnt/run1/run1_manifest.txt \
--input-format PairedEndFastqManifestPhred33V2 \
--output-path /mnt/run1/seqs/demuxed1.qza

#---------------------------------------------------------#

#Remove primers and indices.
#Execution time: 2-3 hours

qiime cutadapt trim-paired \
--i-demultiplexed-sequences /mnt/run1/seqs/demux1.qza \
--p-front-f AGGATTAGATACCCTGGTA \
--p-front-r CRRCACGAGCTGACGAC \
--p-error-rate 0.3 \
--output-dir /mnt/run1/seqs/ \
--verbose

#Rename output file.
mv /mnt/run1/seqs/trimmed_sequences.qza /mnt/run1/seqs/trimmed1.qza

#---------------------------------------------------------#

#Create a viewable summary file to check the data quality.
#Execution time: 5-10 mins

qiime demux summarize \
--i-data /mnt/run1/seqs/trimmed1.qza \
--o-visualization /mnt/run1/seqs/trimmed1.qzv

#Download the qzv file and view on https://view.qiime2.org
#Use the quality plots to determine the dada2 trim settings.

#---------------------------------------------------------#

#Use dada2 for denoising, chimera checking, trimming, dereplication and to generate a feature table.
#Execution time: 1.5 hours
rm -r /mnt/run1/seqs/dada2out

qiime dada2 denoise-paired \
--i-demultiplexed-seqs /mnt/run1/seqs/trimmed1.qza \
--p-trunc-len-f 242 \
--p-trunc-len-r 136 \
--p-trim-left-f 0 \
--p-trim-left-r 0 \
--p-n-threads 14 \
--output-dir /mnt/run1/seqs/dada2out \
--verbose

#Give the output files more recognisable names.
mv /mnt/run1/seqs/dada2out/table.qza /mnt/run1/seqs/dada2out/run1_table.qza
mv /mnt/run1/seqs/dada2out/representative_sequences.qza /mnt/run1/seqs/dada2out/run1_rep_seqs.qza
mv /mnt/run1/seqs/dada2out/denoising_stats.qza /mnt/run1/seqs/dada2out/run1_denoising_stats.qza

#---------------------------------------------------------#

#Generate summary files to check whether processing has worked okay.
rm /mnt/run1/seqs/dada2out/run1_table.qzv
rm /mnt/run1/seqs/dada2out/run1_rep_seqs.qzv
rm /mnt/run1/seqs/dada2out/run1_denoising_stats.qzv

qiime feature-table summarize \
--i-table /mnt/run1/seqs/dada2out/run1_table.qza \
--m-sample-metadata-file /mnt/run1/run1_map.txt \
--o-visualization /mnt/run1/seqs/dada2out/run1_table.qzv \
--verbose

qiime feature-table tabulate-seqs \
--i-data /mnt/run1/seqs/dada2out/run1_rep_seqs.qza \
--o-visualization /mnt/run1/seqs/dada2out/run1_rep_seqs.qzv \
--verbose

qiime metadata tabulate \
--m-input-file /mnt/run1/seqs/dada2out/run1_denoising_stats.qza \
--o-visualization /mnt/run1/seqs/dada2out/run1_denoising_stats.qzv \
--verbose

#Download the qzv files and view on https://view.qiime2.org

#---------------------------------------------------------#
#---------------------------------------------------------#

# Process the read data from RUN 2

#Import the run 2 files.
#Execution time: 1-2 hours

qiime tools import \
--type SampleData[PairedEndSequencesWithQuality] \
--input-path /mnt/run2/run2_manifest.txt \
--input-format PairedEndFastqManifestPhred33V2 \
--output-path /mnt/run2/seqs/demuxed2.qza

#---------------------------------------------------------#

#Remove primers and indices.
#Execution time: 2-3 hours

qiime cutadapt trim-paired \
--i-demultiplexed-sequences /mnt/run2/seqs/demuxed2.qza \
--p-front-f AGGATTAGATACCCTGGTA \
--p-front-r CRRCACGAGCTGACGAC \
--p-error-rate 0.25 \
--o-trimmed-sequences /mnt/run2/seqs/trimmed2.qza \
--verbose

#---------------------------------------------------------#

#Create a viewable summary file to check the data quality.
#Execution time: 5-10 mins

qiime demux summarize \
--i-data /mnt/run2/seqs/trimmed2.qza \
--o-visualization /mnt/run2/seqs/trimmed2.qzv

#Download the qzv file and view on https://view.qiime2.org
#Use the quality plots to determine the dada2 trim settings.

#---------------------------------------------------------#

#Use dada2 for denoising, chimera checking, trimming, dereplication and to generate a feature table.
#Execution time: 1.5 hours
rm -r /mnt/run2/seqs/dada2out
mkdir /mnt/run2/seqs/dada2out

nohup qiime dada2 denoise-paired \
--i-demultiplexed-seqs /mnt/run2/seqs/trimmed2.qza \
--p-trunc-len-f 258 \
--p-trunc-len-r 140 \
--p-trim-left-f 0 \
--p-trim-left-r 0 \
--p-n-threads 0 \
--o-table /mnt/run2/seqs/dada2out/run2_table.qza \
--o-representative-sequences /mnt/run2/seqs/dada2out/run2_rep_seqs.qza \
--o-denoising-stats /mnt/run2/seqs/dada2out/run2_denoising_stats.qza \
--verbose &

#---------------------------------------------------------#

#Generate summary files to check whether processing has worked okay.
rm /mnt/run2/seqs/dada2out/run2_table.qzv
rm /mnt/run2/seqs/dada2out/run2_rep_seqs.qzv
rm /mnt/run2/seqs/dada2out/run2_denoising_stats.qzv

qiime feature-table summarize \
--i-table /mnt/run2/seqs/dada2out/run2_table.qza \
--m-sample-metadata-file /mnt/run2/run2_map.txt \
--o-visualization /mnt/run2/seqs/dada2out/run2_table.qzv \
--verbose

qiime feature-table tabulate-seqs \
--i-data /mnt/run2/seqs/dada2out/run2_rep_seqs.qza \
--o-visualization /mnt/run2/seqs/dada2out/run2_rep_seqs.qzv \
--verbose

qiime metadata tabulate \
--m-input-file /mnt/run2/seqs/dada2out/run2_denoising_stats.qza \
--o-visualization /mnt/run2/seqs/dada2out/run2_denoising_stats.qzv \
--verbose

#Download the qzv files and view on https://view.qiime2.org

#---------------------------------------------------------#
#---------------------------------------------------------#

# Merge the output files

qiime feature-table merge \
  --i-tables /mnt/run1/seqs/dada2out/run1_table.qza \
  --i-tables /mnt/run2/seqs/dada2out/run2_table.qza \
  --o-merged-table /mnt/allruns_table.qza

qiime feature-table merge-seqs \
  --i-data /mnt/run1/seqs/dada2out/run1_rep_seqs.qza \
  --i-data /mnt/run2/seqs/dada2out/run2_rep_seqs.qza \
  --o-merged-data /mnt/allruns_rep_seqs.qza

qiime feature-table tabulate-seqs \
--i-data /mnt/allruns_rep_seqs.qza \
--o-visualization /mnt/allruns_rep_seqs.qzv \
--verbose

#---------------------------------------------------------#
#---------------------------------------------------------#

# Assign taxonomy
#Execution time: 1 hour
qiime feature-classifier classify-sklearn \
--i-classifier /mnt/SILVA_132_v5v6/silva_132_16s_v5v6_classifier.qza \
--i-reads /mnt/allruns_rep_seqs.qza \
--p-n-jobs -8 \
--o-classification /mnt/allruns_taxonomy.qza \
--verbose

#---------------------------------------------------------#

#Generate a viewable summary file of the taxonomic assignments.

qiime metadata tabulate \
--m-input-file /mnt/allruns_taxonomy.qza \
--o-visualization /mnt/allruns_taxonomy.qzv \
--verbose

#Download the qzv files and view on https://view.qiime2.org

#---------------------------------------------------------#

#Filter out mitochondria, chloroplasts, and any features not taxonomically identified to at least the phylum level.

qiime taxa filter-table \
--i-table /mnt/allruns_table.qza \
--i-taxonomy /mnt/allruns_taxonomy.qza \
--p-exclude Mitochondria,Chloroplast \
--p-include D_1__ \
--o-filtered-table /mnt/allruns_table_filtered.qza \
--verbose

#---------------------------------------------------------#
#---------------------------------------------------------#

# Create phylogenetic tree

#Perform an alignment on the representative sequences.
mkdir /mnt/16s/seqs/aligntree

qiime alignment mafft \
--i-sequences /mnt/allruns_rep_seqs.qza \
--p-n-threads 15 \
--o-alignment /mnt/16s/seqs/aligntree/aligned_16s_rep_seqs.qza \
--verbose

#--------------------------------------------------#

#Mask/filter highly variable regions of the alignment.
rm /mnt/16s/seqs/aligntree/masked_aligned_16s_rep_seqs.qza

qiime alignment mask \
--i-alignment /mnt/16s/seqs/aligntree/aligned_16s_rep_seqs.qza \
--o-masked-alignment /mnt/16s/seqs/aligntree/masked_aligned_16s_rep_seqs.qza \
--verbose

#--------------------------------------------------#

#Generate a phylogenetic tree.
#Use single thread (which is the default action) so that identical results can be produced if rerun.
rm /mnt/16s/seqs/aligntree/16s_unrooted_tree.qza

qiime phylogeny fasttree \
--i-alignment /mnt/16s/seqs/aligntree/masked_aligned_16s_rep_seqs.qza \
--p-n-threads 1 \
--o-tree /mnt/16s/seqs/aligntree/16s_unrooted_tree.qza \
--verbose


#--------------------------------------------------#

#Apply mid-point rooting to the tree.
rm /mnt/16s/seqs/aligntree/16s_rooted_tree.qza

qiime phylogeny midpoint-root \
--i-tree /mnt/16s/seqs/aligntree/16s_unrooted_tree.qza \
--o-rooted-tree /mnt/16s/seqs/aligntree/16s_rooted_tree.qza \
--verbose

#--------------------------------------------------#

