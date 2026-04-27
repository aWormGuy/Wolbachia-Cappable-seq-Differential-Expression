#!/bin/bash
#$ -cwd
#$ -j y
#$ -S /bin/bash
#$ -pe smp 8
#$ -l m_mem_free=4G
#	# To get an e-mail when the job is done:
#	#$ -m e
#	#$ -M asinha@neb.com
# export all environment variables to SGE
#$ -V
#$ -t 1-3

################################################
set -ue;
micromamba activate subread_env;
################################################
NUMCPU=8;
################################################

core_aedes_walbb_data_dir="/mnt/home/asinha/data/core_data/Aedes_albopictus/AalbF5_Foshan_2024/Ae_AlbB5Foshan_and_wAlbB.combined_ref";
my_annotations_gtf="${core_aedes_walbb_data_dir}/Ae_AlbB5Foshan_and_wAlbB.combined_ref.genomic.v1.sorted.gtf";
my_annotations_gtf="${core_aedes_walbb_data_dir}/wAlbB_annots_only.refseq.v3.sorted.gtf";

base_dir="/mnt/home/asinha/data/cappable-seq-manuscript-2026";
experiment_base_dir="${base_dir}/__v2026_04_02.Final_Clean/exp_01.walbb_elutions";

samples_list="${experiment_base_dir}/list.samples.exp_01.list";
sample_name=`awk -v current_line_number=${SGE_TASK_ID} 'NR==current_line_number { print $0 }' $samples_list`;

strandedness=2; strandedness_string="reversely";

echo;echo "######################################################";
in_bam="../03.bwa_normalized_reads/_bams/bwa2refV6.normedReads.${sample_name}.bam";

out_prefix="${sample_name}.wAlbB_featureCounts";
out_prefix="${sample_name}.wAlbB.${strandedness_string}featureCounts";
######################################
	
## In feature counts, use strand option s as -2
CMD="featureCounts $in_bam -a $my_annotations_gtf -F GTF -f -p -s $strandedness -t gene -o $out_prefix";
echo;echo "Running: $CMD [`date`]";eval ${CMD};

out_counts_file="${out_prefix}";
out_summary_file="${out_prefix}.summary";

mv ${out_counts_file} ${out_counts_file}.tsv; 
mv ${out_summary_file} ${out_summary_file}.tsv; 


echo;echo "Step : DONE: `date`";echo;
############### END OF SCRIPT #################################

