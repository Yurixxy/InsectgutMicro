#!/bin/bash

# Bioproject ID
bioproject_id=$1


cd /Users/SUO/result/${bioproject_id}/

qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path /Users/SUO/result/${bioproject_id}/tr_manifest.tsv \
  --output-path demux_trimmed.qza \
  --input-format PairedEndFastqManifestPhred33V2

qiime demux summarize \
  --i-data demux_trimmed.qza \
  --o-visualization demux_trimmed_summary.qzv



# dada2 denoise
qiime dada2 denoise-paired \
  --i-demultiplexed-seqs demux_trimmed.qza \
  --p-trunc-len-f 0 \
  --p-trunc-len-r 0 \
  --p-n-threads 10 \
  --o-table table.qza \
  --o-representative-sequences rep-seqs.qza \
  --o-denoising-stats denoising-stats.qza \
   #one mission multi threads


#vsearch cluster
qiime vsearch cluster-features-de-novo \
  --i-table table.qza \
  --i-sequences rep-seqs.qza \
  --p-perc-identity 0.97 \
  --p-threads 10 \
  --o-clustered-table clustered-table.qza \
  --o-clustered-sequences clustered-seqs.qza


# Taxonomy annotation
qiime feature-classifier classify-sklearn \
  --i-classifier /Users/SUO/silva-138-99-nb-classifier.qza \
  --i-reads clustered-seqs.qza \
  --o-classification taxonomy.qza \
  --p-n-jobs auto  #multi missions

qiime taxa barplot \
  --i-table clustered-table.qza  \
  --i-taxonomy taxonomy.qza \
  --o-visualization taxa-bar-plots.qzv

# Diversity analysis

qiime diversity core-metrics \
  --i-table clustered-table.qza \
  --p-sampling-depth 2000 \
  --m-metadata-file tr_manifest.tsv \
  --output-dir core-metrics-results \
  --p-n-jobs auto

# qiime diversity alpha-group-significance \
#   --i-alpha-diversity /home/xinyu/${bioproject_id}/core-metrics-results/shannon_vector.qza \
#   --m-metadata-file /home/xinyu/${bioproject_id}/tr_manifest.tsv \
#   --o-visualization /home/xinyu/${bioproject_id}/core-metrics-results/shannon-group-significance.qzv 、
#   --p-n-jobs auto

  # qiime diversity beta-group-significance \
  # --i-distance-matrix /home/xinyu/${bioproject_id}/core-metrics-results/bray_curtis_distance_matrix.qza \
  # --m-metadata-file sample-metadata.tsv \
  # --m-metadata-column TreatmentGroup \
  # --o-visualization /home/xinyu/${bioproject_id}/core-metrics-results/bray-curtis-group-significance.qzv \
  # --p-pairwise  