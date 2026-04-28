#!/bin/bash
#$ -cwd
#$ -j y
#$ -S /bin/bash
#$ -l m_mem_free=6G
#$ -pe smp 12 
#	# To get an e-mail when the job is done:
#	#$ -m e
#	#$ -M your_email@server.com
# export all environment variables to SGE
#$ -V
#$ -t 1-25

################################################
set -ue;
micromamba activate my_base_bioinfo;
################################################
NUMCPU=12;
################################################

base_dir="path_to_appropriate_folder";
samples_list="${base_dir}/list_samples.00.raw_data.20260201.list";

sample_name=`awk -v current_line_number=${SGE_TASK_ID} 'NR==current_line_number { print $0 }' $samples_list`;

in_dir="${base_dir}/00.raw_data.20260201";
in_fastq1="${in_dir}/${sample_name}.r1.fastq.gz";
in_fastq2="${in_dir}/${sample_name}.r2.fastq.gz";

out_prefix="${sample_name}.fastp-no-dedup-no-FLucGluc";
#out_path="${out_dir}/${out_prefix}";
out_fq_r1="${out_prefix}.r1.fastq.gz";
out_fq_r2="${out_prefix}.r2.fastq.gz";
out_report="${out_prefix}.report.html";

trim_length=5; # 10 for PE150; 5 for PE100

##--- Renmove phiX, Gluc and Fluc first
phix_Gluc_Fluc="/path_to_appropriate_folder/GlucFlucPhixSequences-Spike-ins.fasta";
tmp_r1="tmp_${sample_name}.r1.fastq";
tmp_r2="tmp_${sample_name}.r2.fastq";
stats_phix_removal="stats_phix_FLuc_Gluc_removal.${sample_name}.txt";
CMD="bbduk.sh -Xmx4g in1=$in_fastq1 in2=$in_fastq2 out1=$tmp_r1 out2=$tmp_r2 k=31 ref=$phix_Gluc_Fluc stats=$stats_phix_removal tossbrokenreads"; # ordered cardinality";
echo;echo "Running: $CMD [`date`]";eval ${CMD};

##--- Actual fastp step
#CMD="fastp -i $in_fastq1 -I $in_fastq2 --detect_adapter_for_pe --overrepresentation_analysis --trim_poly_g --trim_poly_x --trim_front1=$trim_length --trim_front2=$trim_length --trim_tail1=1 --trim_tail2=1 --length_required 50 --html $out_report --out1 $out_fq_r1 --out2 $out_fq_r2";
CMD="fastp -i $tmp_r1 -I $tmp_r2 --detect_adapter_for_pe --overrepresentation_analysis --trim_poly_g --trim_poly_x --trim_front1=$trim_length --trim_front2=$trim_length --trim_tail1=1 --trim_tail2=1 --length_required 50 --html $out_report --out1 $out_fq_r1 --out2 $out_fq_r2";
echo;echo "Running: $CMD [`date`]";eval ${CMD};

#out_seqkit_stats="${out_prefix}.seqkit-stats";
#CMD="seqkit stats --threads $NUMCPU $out_fq_r1 $out_fq_r2 > $out_seqkit_stats";
#echo;echo "Running: $CMD [`date`]";eval ${CMD};

##-- delete the tmp files
CMD="rm -f $tmp_r1 $tmp_r2";
echo;echo "Running: $CMD [`date`]";eval ${CMD};

echo;echo "DONE: `date`";echo;
############### END OF SCRIPT #################################

