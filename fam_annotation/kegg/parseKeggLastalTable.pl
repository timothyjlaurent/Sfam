#!/usr/bin/perl -w



use strict;
use diagnostics;
# test file
# my $tableFile = "lastout/7tblout.gz";
# full file
my $tableFile = "lastout/lastal.out.all.gz";
my $outfile = "sfamKoEcTab.txt";

my $koMembersPath = "/mnt/data/home/sharpton/pollardlab/KEGG/ko_members.txt";
my $koListPath = "/mnt/data/home/sharpton/pollardlab/KEGG/ko_list.txt";

my $koToEcHash = makeKoToEcHash($koListPath);
my $geneToKoHash = {};
$geneToKoHash = makeGeneToKoHash($koMembersPath);

open( TAB, "zmore $tableFile |" ) || die "cannot open $tableFile";
open(OUTTAB, "> $outfile") || die "cannot open $outfile";

# example of the fields of the table file
# 0       894
# 1       bcz:BCZK2285
# 2       2
# 3       376
# 4       +
# 5       381
# 6       650274894-10481
# 7       5
# 8       379
# 9       +
# 10      396
# 11      174,1:0,137,0:4,64

my $headerString = "Sfam\t";
$headerString .= "Fam_member\t";
$headerString .= "Qbeg_Cov\t";
$headerString .= "Qnum_Cov\t";
$headerString .= "Q_size\t";
$headerString .= "Q_percent_cov\t";
$headerString .= "Score\t";
$headerString .= "RefID\t";
$headerString .= "Rbeg_Cov\t";
$headerString .= "Rnum_Cov\t";
$headerString .= "R_size\t";
$headerString .= "R_percent_cov\t";
$headerString .= "R_KO\t";
$headerString .= "R_EC\t";
$headerString .= "R_desc";
$headerString .= "\n";

while (defined (my $line = <TAB>)){
	if ($line =~ m/^#/){
		print "comment line\t$line\n";
	} else {
		print "$line\n";
		my @splitLine = split('\t', $line);
		if (@splitLine < 2 ){
			next;
		}
		for my $field (@splitLine){
			chomp($field);
			# print "$i\t$field\n";
			# $i++;
		}
		my $refCov = $splitLine[3]/$splitLine[5];
		my $querCov = $splitLine[8]/$splitLine[10];
		if ($splitLine[0] > 100 && $refCov > 0.8 && $querCov > 0.8){
			print "$line\nPassed Filtering step\n";
			my @id_fam = split("-", $splitLine[6]);
			my $rowString = $id_fam[1]."\t";
			$rowString .= $id_fam[0]."\t";
			$rowString .= $splitLine[7]."\t";
			$rowString .= $splitLine[8]."\t";
			$rowString .= $splitLine[10]."\t";
			$rowString .= $querCov."\t";
			$rowString .= $splitLine[0]."\t";
			$rowString .= $splitLine[1]."\t";
			$rowString .= $splitLine[2]."\t";
			$rowString .= $splitLine[3]."\t";
			$rowString .= $splitLine[5]."\t";
			$rowString .= $refCov."\t";
			my @kos = (keys($geneToKoHash->{$splitLine[1]}));
			$rowString .= join(',', @kos)."\t";
			my @ecs;
			my @desc;
			for my $ko (@kos){
				push (@ecs, $koToEcHash->{$ko}->{EC});
				push (@desc, $koToEcHash->{$ko}->{DESC});
			}
			$rowString .= join(',', @ecs)."\t";
			$rowString .= join(',', @desc)."\n";

			print OUTTAB $rowString;
		} else {
			print "print didn't pass Filtering step\n";
		}
		
	}
}   
close(TAB);
close(OUTTAB);
system("mv $outfile tmp.txt");

open(OUTTAB, "> $outfile") || die "cannot open $outfile";
print OUTTAB $headerString;
close(OUTTAB);

system("sort tmp.txt >> $outfile");

system("rm tmp.txt");

system("gzip $outfile");

print "finished\n";



sub makeGeneToKoHash{
	my $outhash = {};
	my $path = shift;
	open( IN, "<$path" ) || die "cannot open $path";
	while (defined (my $line = <IN> ) ){
		print "line\n";
		my @splitLine = split("\t", $line );
		for my $entry ( @splitLine ){
			chomp($entry); 
		}
		$outhash->{$splitLine[1]}->{$splitLine[0]} = 1 ;
	} 
	close(IN);
	for my $key (keys($outhash)){
		print "$key->\n";
		for my $key2 (keys($outhash->{$key})){
			print "$key2 = ".$outhash->{$key}->{$key2}."\n";
		}
	}
	return $outhash;
}

sub makeKoToEcHash{
	my $outhash = {};
	my $path = shift;
	open( IN, "<$path") || die "cannot open $path";
	while (my $line = <IN>){
		print "$line\n";
		my @splitLine = split("\t", $line);
		for my $entry ( @splitLine ){
			chomp($entry); 
		}
		if($splitLine[1] =~ m/\[(EC.+)\]/){
			$outhash->{$splitLine[0]}->{EC} = $1;
		} else {
			$outhash->{$splitLine[0]}->{EC} = "NA";
		}
		$splitLine[1] =~ s/\[.+\]//;
		chomp($splitLine[1]);
		$outhash->{$splitLine[0]}->{DESC} = $splitLine[1];
	}
	return $outhash;
}