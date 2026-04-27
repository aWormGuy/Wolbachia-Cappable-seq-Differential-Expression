#!/bin/bash
#$ -cwd
#$ -j y
#$ -S /bin/bash
#$ -l m_mem_free=4G
#$ -pe smp 4 
#	# To get an e-mail when the job is done:
#	#$ -m e
#	#$ -M asinha@neb.com
# export all environment variables to SGE
#$ -V
#$ -t 1-3

################################################
set -ue;
micromamba activate my_base_bioinfo;
################################################
NUMCPU=4;
################################################

base_dir="/mnt/home/asinha/data/cappable-seq-manuscript-2026";
experiment_base_dir="${base_dir}/__v2026_04_02.Final_Clean/exp_01.walbb_elutions";

samples_list="${experiment_base_dir}/list.samples.exp_01.list";
current_BARCODE=$((SGE_TASK_ID));
echo "current_BARCODE = ${current_BARCODE}";
sample_name=`awk -v current_BARCODE=${current_BARCODE} 'NR==current_BARCODE { print $0 }' $samples_list`;


READS_DIR="${base_dir}/01.processed_remove_FlucGlucPhiX__fastp";
reads_suffix="fastp-no-dedup-no-FLucGluc";
READS1="${READS_DIR}/${sample_name}.${reads_suffix}.r1.fastq.gz";
READS2="${READS_DIR}/${sample_name}.${reads_suffix}.r2.fastq.gz";

NUM_SUBSAMPLED=130000000; # 130 Mio : get this from README.v2026_04_02
NUM_SUBSAMPLED_SUFFIX="130_million";

SEED=100;
OUT_R1="${sample_name}.subsample_${NUM_SUBSAMPLED_SUFFIX}.r1.fastq.gz";
OUT_R2="${sample_name}.subsample_${NUM_SUBSAMPLED_SUFFIX}.r2.fastq.gz";
# :<<'PE_reads'
echo;echo "######################################################";
CMD="reformat.sh in1=$READS1 in2=$READS2 out1=$OUT_R1 out2=$OUT_R2 sampleseed=$SEED samplereadstarget=$NUM_SUBSAMPLED";
echo;echo "Running: $CMD [`date`]";eval ${CMD};
# PE_reads

:<<'SE_reads'
READS1="combinedReads.wMel.fastq";
BASENAME=`basename $READS1 .r1.fastq`;
OUT_R1=$BASENAME"_subsample"$NUM_SUBSAMPLED_SUFFIX".fastq.gz";
CMD="reformat.sh in=$READS1 out=$OUT_R1 sampleseed=$SEED samplereadstarget=$NUM_SUBSAMPLED";
echo;echo "Running: $CMD [`date`]";eval ${CMD};
SE_reads

echo "DONE: `date`";
############### END OF SCRIPT #################################

