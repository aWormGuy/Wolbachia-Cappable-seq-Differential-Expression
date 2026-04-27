#! /usr/bin/env perl -w

##########
# perl.merge_idxstats.pl

##########
use strict;
use Getopt::Long;

# sub usage {
# 	print("Usage: $0 -samples_info=VALUE -in_dir=VALUE \n");
# 	print "$0 requires at least the first 2 command-line arguments listed above\n";
# 	# example perl perl.merge_idxstats.pl -samples_info=table.idxstats.experiment_03.tsv -in_dir=_idxstats_and_coverages 
# }
# 
# ################################################################
# ####--------- 0. input validation and set-up --------------
# my $numArgs = $#ARGV + 1;
# 
## Options to get from command-line
# my $samples_info;
# my $in_dir;

# ## The full-colon within GetOptions assignmmets indicates optional arguments
# GetOptions("samples_info=s" => \$samples_info,
#             "in_dir=s"   => \$in_dir)
# or die usage; # ("Error in command line arguments\n");
# 
# die usage unless $numArgs == 2;

##--- Set-up
my $in_dir = "_idxstats_and_coverages";
if (!(-d $in_dir)) { die "Could not find in_dir = $in_dir\n";	}
my $samples_info; # populate according to need


## experiment_0x
my $experiment_name = "exp_01"; #

$samples_info = "table.idxstats.".$experiment_name.".tsv";
if (!(-f $samples_info)) { die "Could not find samples_info = $samples_info\n";	}

# my $experiment_name = $samples_info; # e.g. table.experiment-01.tsv
# $experiment_name =~ s/^table.//g;
# $experiment_name =~ s/.tsv//g; # returns e.g. experiment-01
# 
# my $out_dir = "results_idxstats.".$experiment_name;
my $out_dir = "out_idxstats.".$experiment_name;
if (!(-d $out_dir)) { `mkdir $out_dir` }


my $out_file = $out_dir."/"."merged_idxstats.".$experiment_name.".tsv";
open (OUT_IDX, ">" , $out_file) or die $!;
# print OUT_IDX "chromosome", "\t", "chr_len", "\t", "nMappedReads", "\t", "nUnmappedReads"),
print OUT_IDX "chromosome", "\t", "sample_name", "\t", "RPM", "\n";

####
print "Received samples_info = $samples_info\n";
print "Received in_dir = $in_dir\n";
print "Created out_dir = $out_dir\n";
print "Created out_file = $out_file\n";


### 
open(samples_info, "<", $samples_info) or die $!;
while (my $info = <samples_info>) {
	chomp($info);
	my ($sample_name, $tsv_file) = split("\t", $info);
	$tsv_file = $in_dir."/".$tsv_file;
	if (!(-f $tsv_file)) { die "Could not find tsv_file = $tsv_file\n";	}
	my %hash_idxstats;
	open (TSV_FILE, "<", $tsv_file) or die $!;
	my $sum_idxstats = 0;
	while (my $tsv_line = <TSV_FILE>) {
		chomp($tsv_line);
		my @x = split("\t", $tsv_line);
		my $chromosome = $x[0];
		my $numReads = $x[2];
		my $num_unmapped_reads = $x[3];
		if ($chromosome eq "*") {
			$chromosome = "Unmapped_bin";
			$numReads = $num_unmapped_reads;
		}
		$sum_idxstats = $sum_idxstats + $numReads;
		my $hashkey = $chromosome."\t".$sample_name;
		$hash_idxstats{$hashkey} = $numReads;
	}	
	close(TSV_FILE);

	### calculate RPMs and write to output-file
	print "sample_name = $sample_name; sum_idxstats = $sum_idxstats\n";
	keys %hash_idxstats; #reset before looping through
	while (my ($key, $readCounts) = each %hash_idxstats) {
		my $rpm = 1e6 * $readCounts/$sum_idxstats;
		print OUT_IDX $key, "\t", $rpm, "\n";
	}
	
}
print "\n";
