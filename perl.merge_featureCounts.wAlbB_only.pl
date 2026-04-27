#! /usr/bin/env perl -w

##########
# perl.merge_featureCounts.wAlbB_only.pl
# skip the rows with non-wAlbB features

##########
use strict;
use Getopt::Long;

## Options to get from command-line ideally (OR hard-coded values for debug/quick runs etc)
my $experiment_name;
my $samples_list;
my $in_dir;


sub usage {
	print("Usage: $0 -samples_list=VALUE -in_dir=VALUE -experiment_name=VALUE\n");
	print "$0 requires at least the first 3 command-line arguments listed above\n";
}

##--- Set-up from CLI arguments

################################################################
####--------- 0. input validation and set-up --------------
my $numArgs = $#ARGV + 1;

## The full-colon within GetOptions assignmmets indicates optional arguments
GetOptions("samples_list=s" => \$samples_list,
            "in_dir=s"   => \$in_dir,
            "experiment_name=s"   => \$experiment_name)
or die usage; # ("Error in command line arguments\n");

die usage unless $numArgs == 3;

if (!(-d $in_dir)) { die "Could not find in_dir = $in_dir\n";	}
if (!(-f $samples_list)) { die "Could not find samples_list = $samples_list\n";	}


###--------------------------------------------------------------------------------
	##--- Set-up from hard-coded values : Comment out CLI-arguments section
	## $experiment_name = "exp_03";
	## $samples_list = "../list.samples.exp_03.list";
	## $in_dir = ".";
	# $experiment_name = $samples_list; # e.g. table.featureCounts.experiment_01.tsv
	# $experiment_name =~ s/^table.featureCounts.//g;
	# $experiment_name =~ s/.tsv//g; # e.g. experiment_01
# 
###--------------------------------------------------------------------------------

### processing
my $out_dir = "out_featureCounts.walbb.".$experiment_name;
if (!(-d $out_dir)) { `mkdir $out_dir` }

my $out_file = $out_dir."/"."merged_featureCounts.walbb.".$experiment_name.".tsv";
open (OUT_FC, ">" , $out_file) or die $!;
print OUT_FC "Geneid", "\t", "Sample", "\t", "CPM", "\n";

my $out_log = $out_dir."/"."merged_featureCounts.walbb.".$experiment_name.".runlog.log";
open (LOGS, ">" , $out_log) or die $!;

####
print "Received samples_list = $samples_list\n";
print "Received in_dir = $in_dir\n";
print "Created out_dir = $out_dir\n";
print "Created out_file = $out_file\n";
print "Created log_file = $out_log\n";

print LOGS "Received samples_list = $samples_list\n";
print LOGS "Received in_dir = $in_dir\n";
print LOGS "Created out_dir = $out_dir\n";
print LOGS "Created out_file = $out_file\n";
print LOGS "Created log_file = $out_log\n";

### 
open(SAMPLES_LIST, "<", $samples_list) or die $!;
while (my $sample_name = <SAMPLES_LIST>) {
	chomp($sample_name);
# 	my ($sample_name, $tsv_file) = split("\t", $info);
	my $tsv_file = $in_dir."/".$sample_name.".wAlbB.reverselyfeatureCounts.tsv";
# 	$tsv_file = $in_dir."/".$tsv_file;
	if (!(-f $tsv_file)) { die "Could not find tsv_file = $tsv_file\n";	}
	my %hash_featureCounts;
	open (TSV_FILE, "<", $tsv_file) or die $!;
	my $sum_featureCounts = 0;
	while (my $tsv_line = <TSV_FILE>) {
		chomp($tsv_line);
		next if ($tsv_line =~ m/# Program/);
		next if ($tsv_line =~ m/Geneid/);
		## Only work on wAlbB lines
		if ($tsv_line =~ m/^DEJ70_RS/) {
			my @x = split("\t", $tsv_line);
			my $geneid = $x[0];
			my $featureCounts = $x[6];
			$sum_featureCounts = $sum_featureCounts + $featureCounts;
			my $hashkey = $geneid."\t".$sample_name;
			$hash_featureCounts{$hashkey} = $featureCounts;
		}	
	}	
	close(TSV_FILE);

	### calculate RPMs and write to output-file
	print "sample_name = $sample_name; sum_featureCounts (wAlbB_only)= $sum_featureCounts\n";
	print LOGS "sample_name = $sample_name; sum_featureCounts (wAlbB_only)= $sum_featureCounts\n";
	keys %hash_featureCounts; #reset before looping through
	while (my ($key, $fcounts) = each %hash_featureCounts) {
		my $cpm = 1e6 * $fcounts/$sum_featureCounts;
		print OUT_FC $key, "\t", $cpm, "\n";
	}
	
}
print "\n";
