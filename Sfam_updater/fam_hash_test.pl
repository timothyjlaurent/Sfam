#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use Class::Struct;

my $resultfile = "./domtblout/fci_2.HMMs-1.Vs.ALL.SEQS.domtblout.gz";

open( IN, "zmore $resultfile |" )  || die "Can't open $resultfile for read: $!\n";


my $famhash = {}; 
my $c = 0;
while(<IN>){
    
    #are we at the end of the file? eof wasn't working on bueno for some reason
    next if $_ =~ m/\#/;
    next if $_ =~ m/^\-\-\-/; #first zmore line
    chomp $_;
	my @data        = split( " ", $_ );
	#gets the gene and family for each gene 
    my @gene_fam	= split( "-", $data[0]);
   
    my $gene_id 	= $gene_fam[0];
    print "gene_id\t$gene_id\n";
    my $fam_id 		= $gene_fam[1];
    print "fam_id\t$fam_id\n";

    print "$gene_id\t$fam_id\n";

    $famhash->{$fam_id}{$gene_id} = $gene_id;
    print 	"fam_id\t%$famhash->{$fam_id}\n";
    # my @keys = 	keys(%{$famhash->{$fam_id}});
    # for my $key (@keys){
    # 	print "$key\n";
    # } 
    print  "\n";
    my $n_members = keys( %{ $famhash->{$fam_id} } );
    print "$n_members\n";
 #    $c++;
	
	# if($c >= 50){
	# 	last;
	# }
}

close IN;