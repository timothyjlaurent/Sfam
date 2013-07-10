#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use POSIX;
use File::Glob;
use Storable;
use Data::Dumper;

our $debug = 0 ;

my $hitTable = "/mnt/data/work/pollardlab/laurentt/kegFamFasta/sfamKoEcTab.txt.gz";
my $fastaBaseFolder = "/mnt/data/home/sharpton/pollardlab/sharpton/20130401";
my $outfile = "./famToKoTab.txt";
open OUT, ">$outfile";

my $famSizeHash ;
$famSizeHash = countFamMembers($fastaBaseFolder);
store \%{$famSizeHash}, 'famSize.hash';
# $famSizeHash = retrieve('famSize.hash');

my $famKOhash;
$famKOhash = makefamKOhash($hitTable); 
store \%{$famKOhash}, 'famKO.hash';
# $famKOhash = retrieve('famKO.hash');


# die;

my $header = "famid\tkoID\tEC\tDESC\tMembers\thitPerMember\tnumHits\tfamSize\tproportion\n";
print OUT $header;
my @fams = sort (keys(%$famKOhash));

for my $fam (@fams){
	warn Dumper ($famKOhash->{$fam}) if ($debug);
	# readline;
	print $fam."\n" if ($debug);
	my @kos = sort(keys($famKOhash->{$fam}));
	for my $ko (@kos){
		print $ko."\n";
		my $row = $fam."\t";
		$row .= $ko."\t";
		$row .= $famKOhash->{$fam}->{$ko}->{EC}."\t";
		$row .= $famKOhash->{$fam}->{$ko}->{DESC}."\t";
		my @members = sort(keys($famKOhash->{$fam}->{$ko}->{MEM}));
		my $members = join(',', @members);
		 $row .= $members."\t";
		my @numHits;
		for (my $i = 0 ; $i < @members ; $i++){
			$numHits[$i] = $famKOhash->{$fam}->{$ko}->{MEM}->{$members[$i]};
		}
		 $row .= join(',', @numHits)."\t";
		 $row .= @members."\t";
		 $row .= $famSizeHash->{$fam}."\t";
		 $row .= @members/$famSizeHash->{$fam}."\n";
		print $row;
		print OUT $row;
	}
}
close (OUT);



print "end of script\n";



sub makefamKOhash{
	print "in makeFamKOhash\n" if ($debug);
	my $hitTable = shift; 
	my $famKOhash = {};
	open( HITS, "zmore $hitTable |" ) || die "cannot open $hitTable";
	my $i = 0 ;
	while ( my $line = <HITS> ){
		print ++$i."\n";
		print $line."\n" if ($debug);
		if ($line =~ m/^#/ ){
			next;
		}else {
			chomp($line);
			print $line."\n" if ($debug);
			my @field = split("\t", $line);
			if (@field < 12){
				next;
			}
			for my $field (@field ){
				# print $field."\n";
			}
			#fam->ko = ec
			if( !defined($famKOhash->{$field[0]}->{$field[12]}->{EC} )){
				$famKOhash->{$field[0]}->{$field[12]}->{EC} = $field[13];
			}
			# fam->ko = desc
			if( !defined($famKOhash->{$field[0]}->{$field[12]}->{DESC} )){
				$famKOhash->{$field[0]}->{$field[12]}->{DESC} = $field[14];
			}
			if( !defined($famKOhash->{$field[0]}->{$field[12]}->{MEM}->{$field[1]} ) ){
				$famKOhash->{$field[0]}->{$field[12]}->{MEM}->{$field[1]} = 1;
			}else {
				$famKOhash->{$field[0]}->{$field[12]}->{MEM}->{$field[1]}++;
			}
			# readline;
		}
	}
	return $famKOhash;
}



sub countFamMembers{
	my $baseFolder = shift;
	print "baseFolder = $baseFolder\n";
	my $dirString  = $baseFolder."/FC*/seqs_all/*.faa";
	print $dirString."\n";
	my @fams = </mnt/data/home/sharpton/pollardlab/sharpton/20130401/FC*/seqs_all/*.faa>;
	my $famSizeHash = {};

	for my $fam (@fams){
	
		chomp $fam;
		open FILE, "<$fam";
		my $count = 0;
		my $famid;
		if ($fam =~ m/\/(\d+).faa$/ ){
			$famid = $1;
			# print $famid."\n";
		} else {
			die "no id for family $fam";
		}
		while( (my $line = <FILE>) ){
			if ($line=~ m/>\d+/){
				$count++;
				print "$famid\t$count\n" if ($debug);
			}
		}
		$famSizeHash->{$famid} = $count;
	}

	return $famSizeHash;
}
