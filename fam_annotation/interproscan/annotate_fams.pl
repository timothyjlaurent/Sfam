#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use Data::Dumper;
use sfamTools::annot_tools;
use Storable;

my $annotfile = "img_interprot_hits_cut.txt.gz";
my $fciseqdir = "../seqs";
my $outDir 	  = "annotOut";
my $outPrefix   = "fci2";




GetOptions(
	"annot:s"	=>		\$annotfile,
	"outPrefix"	=>		\$outPrefix,
	"outDir"	=>		\$outDir,
	);
# print "$annotfile\n";
my $geneAnnotHash;
# $geneAnnotHash = annot_tools::buildGeneIdToAnnotHash($annotfile);


# store \%{$geneAnnotHash}, 'geneAnnot.hash';

# die;
# $geneAnnotHash = retrieve('geneAnnotHash.txt');
my $famGeneAnnotHash;
# $famGeneAnnotHash = annot_tools::buildFamGeneAnnotHash($fciseqdir, $geneAnnotHash);

# store \%{$famGeneAnnotHash}, 'famGeneAnnotHash.hash';

$famGeneAnnotHash = retrieve('famGeneAnnotHash.hash');

annot_tools::buildFamAnnotFractionTable( {
	famHash => $famGeneAnnotHash,
	outPrefix =>	$outPrefix,
	outDir    =>    $outDir,
	} );