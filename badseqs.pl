#!/usr/bin/perl -w
# use Sfam_updater::DB_op;
use strict;
use Getopt::Long;
use Data::Dumper;
use Storable;
use DBI;

# my $fciseqdir = "seqs";
my $fciseqdir = "/mnt/data/work/pollardlab/sharpton/sifting_families/fci_2/seqs";
my $badTaxIdHash = {};


my $username = "laurentt";
my $password = "sqlpass1";
my $DB_pointer = "DBI:mysql:Sfams";# unless defined($DB_pointer);
my $IDHash = build_id_hash($fciseqdir);


# $badTaxIdHash = build_bad_id_hash($fciseqdir);

store \%{$IDHash}, 'IDHash.txt';

# $badTaxIdHash = retrieve('badTaxIdHash.txt');
$badTaxIDHash = extract_bad_id_hash($IDHash);


my @badTaxIdArray = keys( %{ $badTaxIdHash } );

my $arraySize = @badTaxIdArray;

print "There are $arraySize elements in the array outside\n";

my $taxaArrayRef = get_taxa_from_taxid(
	taxArrayRef 	=> 	\@badTaxIdArray,
	username		=>	$username,
	password		=>	$password,
	DB_pointer		=> 	$DB_pointer,
	 ); 


sub build_bad_id_hash{
	my $path = shift;
	
	my @hmmFiles = glob("$path/*.gz");
	my $badTaxIDHash = {};

	for my $file (@hmmFiles){
		open FAM, "zmore $file |" || die "Can't read $file: $!\n";
		print "searching $file\n";
		while(<FAM>){
			print $_."\n";
			if( $_ =~ m/^>TX(\d+)ID_/ ){
				# print "Bad TaxID\t$1\n";
				$badTaxIDHash->{$1} = 0 ;
			}
		}
		close FAM;
	}
	return $badTaxIDHash;
}

sub extract_bad_id_hash{
	my $IDHash = shift;
	my $badTaxIdHash = {};
	for my $id ( keys( %{ $IDHash } ) ){
		print $id."\n";
		if ( $id =~ m/TX(\d+)ID_/ ){
			print "adding $1 to \$badTaxIdHash\n";
			$badTaxIdHash->{$_} = 0;
		}
	}


}



sub build_id_hash{
	my $path = shift;
	
	my @hmmFiles = glob("$path/*.gz");
	my $IDHash = {};

	for my $file (@hmmFiles){
		open FAM, "zmore $file |" || die "Can't read $file: $!\n";
		print "searching $file\n";
		while(<FAM>){
			print $_."\n";
			if( $_ =~ m/^>(.+)$/ ){
				# print "Bad TaxID\t$1\n";
				$IDHash->{$1} = 0 ;
			}
		}
		close FAM;
	}
	return $IDHash;
}


sub get_taxa_from_taxid{
	my $rootdir = "/mnt/data/work/pollardlab/JGI_IMG_genomes/";
	my %args       = @_;
	my $taxArrayRef = $args{taxArrayRef};
	my $DB_pointer = $args{DB_pointer};
	my $username = $args{username};
	my $password = $args{password};
	my $DB = DBI->connect( $DB_pointer, "$username", "$password" ) or die "Couldn't connect to database:\t".DBI->errstr;
	my @taxArray = @{ $taxArrayRef };
	my $arraySize = @taxArray;

	print "There are $arraySize elements in the array\n";
	for my $id ( @{ $taxArrayRef } ){
		my $prepare_statement = "SELECT directory from genomes where taxon_oid = '$id'";
		# print STDERR "prepare_statement: $prepare_statement\n";
		my $query = $DB->prepare($prepare_statement);
		$query->execute();
		# print "query executed\n";
		while ( my @row = $query->fetchrow() ){
			print $row[0]."\n";
			my $querydir = $rootdir.$row[0];

		
		}
	}

}