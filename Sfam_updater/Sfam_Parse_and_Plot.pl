#!/usr/bin/perl -w

use strict;
use Getopt::Long;


my $domtblDir; 
my $catDomtblDir;
my $cat;		#option to cat a directory of gzipped hmms to the catDomtblDir 
my $parse;		# parse or no
my $plot;		# plot or no
# my $gz


GetOptions(
    "cat"			 =>	\$cat,
    "domtblDir:s" 	 => 	\$domtblDir, 
    "catDomtblDir:s" => 	\$catDomtblDir,
    "p"				 =>	\$parse,		# flag to indicate whether to parse or not
    "r"				 =>	\$plot,
    );




if ( !defined($domtblDir) ) {
	$domtblDir = "./domtblout/";
}
print "domtblDir = $domtblDir\n";

if ( !defined($catDomtblDir) ) {
	$catDomtblDir = "./catDomtbl/";
}
print "catDomtblDir = $catDomtblDir\n";


my $domtblFile;

my @files = <$domtblDir*.gz>;
# print "$files[0]\n";
my $domtblFile = (split/\//,$files[0])[-1]; 
# print "basefile\t$basefile\n";
# $_ = $basefile ;
$domtblFile =~ s/-\d\./\./;
# print "basefile\t$basefile\n";

if($cat){
	print "cat-ing together all files in $domtblDir and putting the result in $catDomtblDir\n";

	##cat files together

	makeResultFile(

		domtblDir		=>	$domtblDir,
		catDomtblDir	=>	$catDomtblDir,
		domtblFile 		=>	$domtblFile,
	);
}

my $ResultsFileName = "$catDomtblDir/ResultFile.gz";
## call parse 

print "finished making $ResultsFileName\n";





## takes a directory of HMMS and an output directory, cats together a the hmms and returns the filename of the cat ed files and then 
## rezipps up the files

sub makeResultFile {
	my %args = @_;
	my $domtblDir = $args{domtblDir};
	my $catDomtblDir = $args{catDomtblDir};
	my $domtblFile = $args{domtblFile};

	my $outFile  = "$catDomtblDir$domtblFile"; 
	# print "$catDomtblDir\n";
	#check if folder exists; makes it if not
	if (!(-d $catDomtblDir)){
		print "$catDomtblDir doesn't exits\n";
		mkdir $catDomtblDir;
	}
	
	if (-e $outFile){
		system("rm $outFile");
	}

	#make batch file

	system("cat $domtblDir/* >> $outFile");

	return $outFile;

}
