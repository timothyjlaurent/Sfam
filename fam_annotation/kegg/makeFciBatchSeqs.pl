#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use POSIX;
use File::Glob;

#my $DB_pointer  = "DBI:mysql:Sfams:lighthouse.ucsf.edu";
 


my $baseFolder = "/mnt/data/home/sharpton/pollardlab/sharpton/20130401";
print "ls ${baseFolder}/FC*/seqs_all/*.faa";
my @fams = <${baseFolder}/FC*/seqs_all/*.faa>;

my $outDir = "kegFamFasta";

system("mkdir -p $outDir");

my $outfilebase = "famSeq_";
my $count = 0;
my $num = 1;

open OUTFILE, ">$outfilebase.$num";


for my $fam (@fams){
	my $famid;
	open FILE, "<$fam";
	chomp $fam;
	$count++;
	if ( $count % 1000 == 0 ){
		close (OUTFILE);
		$num++;
		open OUTFILE, ">$outfilebase.$num";
	}
	if ($fam =~ m/\/(\d+).faa$/ ){
		$famid = $1;
		# print $famid."\n";
	} else {
		die "no id for family $fam";
	}
	while( (my $line = <FILE>) ){
		if ($line=~ m/>\d+/){
			chomp($line);
			$line = $line."-$famid\n";
		}
		print $line;
		print OUTFILE $line;
	}
	close (FILE);
}
close (OUTFILE);

