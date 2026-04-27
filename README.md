# Wolbachia-Cappable-seq-Differential-Expression
Commands, scripts and metadata corresponding to the manuscript `Sinha et al. "Cappable-seq enrichment of endosymbiont mRNA reveals dynamic Wolbachia effector expression during host cell passage" (2026)`.

## Authors:
- Amit Sinha (New England Biolabs, Ipswich, MA, US)

#### Step 1: QC and adapter trimming of raw reads:
- Remove : sequencing adapters, phiX carryover if any, synthetic spike-in sequences (Fluc, Gluc).
- Key tool: `fastp`
- Script: `job-fastp-no-dedupe.no-GlucFluc.parallel.sh`

#### Step 2: Normalize processed reads to the same total counts within one experiment
- Collect read count stats per read in the above step.
- Determine the smallest read-count observed within each experiment (Ns)
- Subsample reads to the smallest count Ns for each sample.
- Script: `job-subsample-reads.parallel.sh`
- Metadata required: table of samples-per-experiment, table of reads per sample.

#### Step 3: Map processed and normalized reads to a combined reference genome 
 - Combined reference genomes include the host Aedes albopictus, Wolbachia wAlbB and 5 ssRNA viruses.
 - Generate coverage stats and idxstats from the bam file
 - Script: `job-reads2assembly-bwa.parallel.sh`

#### Step 4: Generate featureCounts for all annotated gene features in the reference genome
- Metadata required: GTF files from NCBI corresponding to all the reference genomes.
- Script: `job-featureCounts.wAlbB.parallel.sh`

### Step 5: Plot read distribution per species
- Generate barplots for Figutre 1A etc.
- Metadata: table of each contig and its source species.
- Perl script: Merge `*.bam2idxstats.tsv` outputs from bams of different samples into one table using `perl.merge_idxstats.pl`.
- Rscript: `r.Fig-1A.idxtstats.exp-01.R`

### Step 6: Plot distribution of featureCounts for each gene_biotype within Wolbachia wAlbB
- Generate barplots for Figutre 1B etc.
- Metadata: table of each `feature` and its `gene_biotype`, obtained from the GTF file.
- Perl script: Merge `*.featureCounts.tsv` outputs from different samples into one table using `perl.merge_featureCounts.wAlbB_only.pl`
- Rscript: `r.featureCounts.walbb.exp01.R`
- 

