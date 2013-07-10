#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use Data::Dumper;

use Storable;

sub make_seq_to_id_hash{
	my $path = shift;
	my $seqToIdHash = {};
	my @hmmFiles = glob("$path/*.gz");
	

	for my $file (@hmmFiles){
		open( HMMS, "zmore $file |" ) || die "Can't read $file: $!\n";	
		print "opening $file\n\n";
		my $seq = '';
		my $id;
		while(my $line = <HMMS>){
			if ( $line =~ m/^----/){
				next;
			}
			chomp $line ;
			if( $line =~ m/^>(.+)$/ ){
				
				if($seq ne ''){
					print "seq\t$seq\tid\t$id\n"; 
					$seqToIdHash->{$seq} = $id;
					$seq = '';
				}
				$id = $1;
			}	else {
				
				$seq .= $line;

			}
		}
		print "seq\t$seq\tid\t$id\n";
		$seqToIdHash->{$seq} = $id;
		$seq = '';
	}
	return $seqToIdHash;
}



my $fciseqdir = "./seqs";

my $seqToIdHash = make_seq_to_id_hash($fciseqdir);

store \%{ $seqToIdHash }, 'seqToId.hash';