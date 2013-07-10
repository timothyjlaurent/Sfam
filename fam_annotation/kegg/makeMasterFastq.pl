#!/usr/bin/perl -w
package Sfam_gather_genes;
use Sfam_updater::DB_op;
use strict;
use Getopt::Long;
use POSIX;

#my $DB_pointer  = "DBI:mysql:Sfams:lighthouse.ucsf.edu";
 

## list of options 
my( 
	$username, 		$password,		$limit,			$fasta_out, 		$DB_pointer, 
	$famHmmDir,		$catHmmDir,		$splitNum,		$catHmmCore
	
);


GetOptions(
			"u=s"             => \$username,
			"p=s"             => \$password,
			"db=s"            => \$DB_pointer,
			"fasta-out=s"	  => \$fasta_out,	
			"limit=i"		  => \$limit,
			"fam-dir=s"	  	  => \$famHmmDir,
			"cat-fam=s"		  => \$catHmmDir,
			"split=i"		  => \$splitNum
	);

die "Please provide a username for the MySQL database using -u\n" unless defined($username);

$DB_pointer = "DBI:mysql:Sfams" 									unless defined($DB_pointer);
# die "Please provide a Database pointer for the MySQL database to use using --db\n"           unless defined($DB_pointer);
$famHmmDir = "/mnt/data/home/sharpton/sifting_families/fci_2/HMMs"	unless defined($famHmmDir);
$catHmmDir = "./catHmmDir" 											unless defined($catHmmDir);
$fasta_out = "./fasta"												unless defined($fasta_out);
$splitNum = 100														unless defined($splitNum);


if ( !defined($password) ) {
	print "Enter MySQL password :\n";
	$password = <>;
	chomp($password);
}

print "$DB_pointer\n";
my $core_family_member_file = Sfam_updater::DB_op::gather_CDS(
	output_dir	=>	$fasta_out,
	old			=>	1,
	db 			=>	$DB_pointer,
	username 	=>	$username,
	password	=>	$password,
	limit		=>	$limit

	);

print "completed the query\n";


# gather_Hmms (
# 	famHmmDir 	=>	$famHmmDir,
# 	splitNum	=>	$splitNum,
# 	catHmmDir	=>	$catHmmDir,

# 	);

# print "splitNum = $splitNum\n";

# This subroutine collects all the HMMs from a directory, cats them together,
# numbers them and puts them into the output directory.
sub gather_Hmms {
	my %args	= @_;
	my $famHmmDir = $args{famHmmDir};
	my $splitNum = $args{splitNum};
	my $catHmmDir = $args{catHmmDir};
	
	my $catHmmCore ;
	my @famHmms = <$famHmmDir/*.gz>;
	my $count = @famHmms;

	$_= $famHmmDir;
	# print "$_\n";
	## extract last of path fci_2/HMMs in out case
	if ($_ =~ /^(.*)families\/(.*)$/){
		$_ = $2;
	}
	s/\//./;
	# print "$_\n";

	$catHmmCore = $_;


	# print "$count HMMs\n";
	my $numPerBin = ceil($count/$splitNum);
	# print "num per bin = $numPerBin\n";
	my $countTot = 0;
	my $binCount ;
	my $outFile;
	my $i;
	unless(-e $catHmmDir or mkdir $catHmmDir) {
		die "Unable to create $catHmmDir\n";
	}
	# small number for testing
	# $splitNum = 10;
	print "splitnum = $splitNum\n";
	# print @famHmms;
	for ( $binCount = 1 ; $binCount <= $splitNum ; $binCount++){
		$outFile = "$catHmmDir/";
		$outFile .= $catHmmCore;
		$outFile .= "-$binCount";
		$outFile .= ".gz";
		# print "$binCount\n";
		print "$outFile\n";
		
		#Overwrite file if it exists
		system("cat $famHmms[$countTot] > $outFile");
		$countTot++;
		for($i = 1 ; $i < $numPerBin ; $i++){
			if ($countTot < $count){
				## cat the next file
				system("cat $famHmms[$countTot] >> $outFile");
				$countTot++;
			}
		} 
	}

	print "gathered HMMs\n";
}




