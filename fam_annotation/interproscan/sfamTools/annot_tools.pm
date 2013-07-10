#!/usr/bin/perl -w
package annot_tools;
use strict;
use Getopt::Long;
use Data::Dumper;






# this subroutine takes a path to a annotation table file and two optional
# arguments specifying the indices the gene_id column, and a pattern to identify of the annotation id
# it defaults to "IPR".

sub buildGeneIdToAnnotHash{

	my $file = shift;
	my $geneCol = shift;
	my $annotpattern = shift;

	$geneCol //= 0;

	$annotpattern //= "IPR";
	print "$file\n";
	print "geneCol\t$geneCol\n";
	
	open( IN, "zmore $file |" ) || die "Can't open $file for read: $!\n";
	my $line = 0;
	my $geneAnnotHash = {};

	while(<IN>){
		chomp $_;
		my @data 	=	split( "\t", $_);
		my $i = 0;
		# print "$_\n";
		# for my $entry(@data){
		# 	print "$line\tentry\t$i\t$entry\n";
		# 	$i++;
		# }
		my $gene_id = 	$data[$geneCol];
		my $annot_id;
		# if(!$data[$annotCol]){
		# 	print "$line\tno annotationId\n";
		# 	next;
		# }
		# my $annot_id =  $data[$annotCol];
		if( $_ =~ m/\s($annotpattern\d+)\s/ ){
			print "$line\tmatched $1\n";
			$annot_id = $1;
		} else {
			print "no matching annotations on line $line\n";
			next;
		}

		if(!($geneAnnotHash->{$gene_id}->{$annot_id})){
			print "$line\tnew annotation for gene: $gene_id\tannotation\t$annot_id\n";
		
			$geneAnnotHash->{$gene_id}->{$annot_id} = 1;
		} else {
			print "$line\tduplicate annotation for gene: $gene_id\tannotation\t$annot_id\n";
			($geneAnnotHash->{$gene_id}->{$annot_id})++;
		}
		print "$line\t\$geneAnnotHash->{$gene_id}->{$annot_id}=$geneAnnotHash->{$gene_id}->{$annot_id}\n";
		$line++;
	}

	return $geneAnnotHash;
}

# This subroutine takes the path to a directory of gzipped files where 
# the name of the file is the family name and this file contains the 
# fasta sequences of the family members and a hash reference to of form
# {gene_id}->{annotation_id}->{num_hits} . The function outputs a hash
# reference of form {fam_id}->{gene_id}->{annotation_id}->{num_hits}.

sub buildFamGeneAnnotHash{
	my $path = shift;
	my @hmmFiles = glob("$path/*.gz");
	my $geneAnnotHash = shift;
	my $famhash = {};
	my $fam_id;
	my $gene_id;

	for my $file (@hmmFiles){
		if( $file =~ m/\/(\d+).+\.gz/ ){
			print "\$id = $1\n";
			$fam_id = $1;
		}
		open( HMMS, "zmore $file |" ) || die "Can't read $file: $!\n";
		while(<HMMS>){
			chomp $_;
			if( $_ =~ m/^>(.+)$/ ){
				$gene_id = $1;
				$gene_id =~ s/TX\d+ID_//;
				print "$fam_id\t";
				print "$gene_id\n";
				if( $geneAnnotHash->{$gene_id} ){
					print "$gene_id is in geneAnnotHash\n";
					$famhash->{$fam_id}->{$gene_id} = $geneAnnotHash->{$gene_id};
				} else {
					print "$gene_id is not in geneAnnotHash\n";
					$famhash->{$fam_id}->{$gene_id} = "NoAnnot";
				}
			}
		}
	}

	return $famhash;
}

# This subroutine takes a hash like one made by buildFamGeneAnnotHash
# and a outpath and outputs a file <outPrefix>_famid_annotationFraction.tab

sub buildFamAnnotFractionTable{
	my ($args) = @_;
	my $famhash = $args->{famHash};
	my $outPrefix = $args->{outPrefix};
	my $outDir = $args->{outDir};
	system("mkdir -p $outDir");
	$outPrefix = $outDir."/".$outPrefix;
	my $TABsuff = "_famid_annotation_Fraction_scratch.tab";
	my $TAB2suff = "_famid_gene_annotation_count_scratch.tab";
	my $TAB3suff = "_famid_nonAnnot_tot_scratch.tab";
	
	open TAB, ">${outPrefix}$TABsuff";
	open TAB2, ">${outPrefix}$TAB2suff";
	open TAB3, ">${outPrefix}$TAB3suff";

	my $numMembers;
	my $annotHash = {};
	my $nonAnnot;
	my $numAnnot;
	# print TAB "famid\tannotation_id\tannotation_fraction\n";

	for my $fam (keys(%{$famhash})){
		$numAnnot = 0;
		$nonAnnot = 0;
		$numMembers = keys( %{ $famhash->{$fam} } );
		print "fam\t$fam\thas\t$numMembers\tmembers\n";
		for my $member (keys( %{ $famhash->{$fam} } )){
			# print "family\t$fam\n";
			# print "member\t$member\n";
			unless ( $famhash->{$fam}->{$member} eq "NoAnnot" ){
				print %{ $famhash->{$fam}->{$member}}."\n";
				for my $annot ( keys( %{ $famhash->{$fam}->{$member} } ) ){
					if(!( $annotHash->{$fam}->{$annot} )){
						$annotHash->{$fam}->{$annot} = 1;
					} else {
						$annotHash->{$fam}->{$annot}++;
					}
					$numAnnot++;
					print "adding to gene annotation count table\n$fam\t$member\t$annot\t$famhash->{$fam}->{$member}->{$annot}\n\n";
					print TAB2 "$fam\t$member\t$annot\t$famhash->{$fam}->{$member}->{$annot}\t$numMembers\n";
				}
			} else{
					print "adding to gene annotation count table\n$fam\t$member\t$famhash->{$fam}->{$member}\t0\t$numMembers\n\n";
					print TAB2 "$fam\t$member\t$famhash->{$fam}->{$member}\t0\t$numMembers\n";
					$nonAnnot++;
			}
		}
		print TAB3 "$fam\t$nonAnnot\t$numAnnot\t$numMembers\t".($nonAnnot/$numMembers)."\n";
		for my $annot( keys( %{ $annotHash->{ $fam } } ) ){
			my $fraction = ($annotHash->{ $fam }->{ $annot })/$numMembers;
			print TAB "$fam\t$annot\t$fraction\n";
		}
	}
	close TAB;
	close TAB2;
	close TAB3;

	system("sort ${outPrefix}$TABsuff -o ${outPrefix}$TABsuff");
	system("sort ${outPrefix}$TAB2suff -o ${outPrefix}$TAB2suff");
	system("sort ${outPrefix}$TAB3suff -o ${outPrefix}$TAB3suff");

	open TAB, ">${outPrefix}_famid_annotation_Fraction.tab";
	print TAB "fam_id\tannotation_id\tannotation_fraction\n";
	close TAB;
	open TAB2, ">${outPrefix}_famid_gene_annotation_count.tab";
	print TAB2 "fam_id\tgene_id\tannotation\tcount\ttotal_fam_members\n";
	close TAB2;
	open TAB3, ">${outPrefix}_famid_stats.tab";
	print TAB3 "fam_id\tnum_nonAnnot\tnum_annotations\ttotal_fam_members\tproportion_nonAnnot\n";
	close TAB3;
	system ("cat ${outPrefix}$TABsuff >> ${outPrefix}_famid_annotation_Fraction.tab");
	system ("rm ${outPrefix}$TABsuff");
	system ("cat ${outPrefix}$TAB2suff >> ${outPrefix}_famid_gene_annotation_count.tab");
	system ("rm ${outPrefix}$TAB2suff");
	system ("cat ${outPrefix}$TAB3suff >> ${outPrefix}_famid_stats.tab");
	system ("rm ${outPrefix}$TAB3suff");

}	



return 1;