#!/bin/bash
#$ -cwd
#$ -j y
#$ -S /bin/bash
#$ -l m_mem_free=6G
#$ -pe smp 8 
# To get an e-mail when the job is done:
# #$ -m e
# #$ -M asinha@neb.com
# export all environment variables to SGE
#$ -V
#$ -t 1-3

################################################
set -ue;
micromamba activate my_base_bioinfo;
################################################
NUMCPU=8;
################################################

base_dir="/mnt/home/asinha/data/cappable-seq-manuscript-2026";
work_dir="${base_dir}/__v2026_04_02.Final_Clean/exp_01.walbb_elutions";
samples_list="${work_dir}/list.samples.exp_01.list";
#sample_name=$1; # get from command line

current_BARCODE=$((SGE_TASK_ID));
echo "current_BARCODE = ${current_BARCODE}";
sample_name=`awk -v current_BARCODE=${current_BARCODE} 'NR==current_BARCODE { print $0 }' $samples_list`;

REF_FASTA_DIR="/mnt/home/asinha/data/core_data/Aedes_albopictus/AalbF5_Foshan_2024/ref_genomes.v6";
REF_FASTA_FILE="aa23_walbb_5viruses6segments.ref_genomes.v6.fasta";
REF_IDX="${REF_FASTA_DIR}/bwa_index_out/${REF_FASTA_FILE}";


READS_DIR="${base_dir}/01.processed_remove_FlucGlucPhiX__fastp";
READS1="${READS_DIR}/${sample_name}.fastp-no-dedup-no-FLucGluc.r1.fastq.gz";
READS2="${READS_DIR}/${sample_name}.fastp-no-dedup-no-FLucGluc.r2.fastq.gz";

PREFIX="bwa2refV6.${sample_name}";

OUT_BAM=$PREFIX".bam";
OUT_FLAGSTAT=$OUT_BAM".flagstat";
#OUT_BAM_ALIGNED=$PREFIX".aligned.bam";
#OUT_BAM_ALIGNED=$PREFIX".aligned.bam";
OUT_BAM_UNMAPPED=$PREFIX".unaligned.bam";

#OUT_DEPTH=$PREFIX".bam2depth.tsv";
OUT_COVERAGE=$PREFIX".bam2coverage.tsv";
OUT_IDXSTATS=$PREFIX".bam2idxstats.tsv";

CMD="bwa mem -t $NUMCPU $REF_IDX $READS1 $READS2 | samtools view --threads $NUMCPU -bh | samtools sort --threads $NUMCPU -m 4G -o $OUT_BAM";
echo;echo "Running: $CMD [`date`]";eval ${CMD};

CMD="samtools index $OUT_BAM"; # Needed for blobplot
echo;echo "Running: $CMD [`date`]";eval ${CMD};

CMD="samtools flagstat $OUT_BAM > $OUT_FLAGSTAT";
echo;echo "Running: $CMD [`date`]";eval ${CMD};

#CMD="samtools depth -a $OUT_BAM > $OUT_DEPTH";
#echo;echo "Running: $CMD [`date`]";eval ${CMD};

CMD="samtools coverage $OUT_BAM > $OUT_COVERAGE";
echo;echo "Running: $CMD [`date`]";eval ${CMD};

CMD="samtools idxstats $OUT_BAM > $OUT_IDXSTATS";
echo;echo "Running: $CMD [`date`]";eval ${CMD};

:<<'skip'
# 3) retain only the mapped/aligned reads; Convert file .sam to .bam
FLAG_UNMAPPED=4;
CMD="samtools view -F $FLAG_UNMAPPED -bh $OUT_BAM | samtools sort --threads $NUMCPU -m 4G -o $OUT_BAM_ALIGNED";
echo;echo "Running: $CMD [`date`]";eval ${CMD};

CMD="samtools index $OUT_BAM_ALIGNED";
echo;echo "Running: $CMD [`date`]";eval ${CMD};
skip

# 4) Collect the un-mapped reads;
FLAG_UNMAPPED=4;
CMD="samtools view -f $FLAG_UNMAPPED -bh $OUT_BAM | samtools sort --threads $NUMCPU -m 4G -o $OUT_BAM_UNMAPPED";
echo;echo "Running: $CMD [`date`]";eval ${CMD};


:<<'skip_again'
#CMD="rm -rf $OUT_BAM";
#echo;echo "Running: $CMD [`date`]";eval ${CMD};

#OUT_BAM_BAI=$CMD".bai";
#CMD="rm -rf $OUT_BAM_BAI";
#echo;echo "Running: $CMD [`date`]";eval ${CMD};
skip
skip_again

echo;echo "Step : DONE: `date`";echo;
############### END OF SCRIPT #################################

