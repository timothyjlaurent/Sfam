#!/usr/bin/perl -w

use strict;
use Getopt::Long;
# use MRC;
# use MRC::Run;
# use MRC::DB;
use Data::Dumper;
no strict 'refs';

print "perl parse_hmmsearch_results.pl @ARGV\n";

#parse a domtblastout formatted hmmsearch output table. Specifically, identify models that hit sequences
#with a particular coverage and evalue threshold.

#NOTE: WE MIGHT NEED TO TILE ACROSS MANY LOCAL HITS!

my $resultfile = "./catDomtbl/fci_2.HMMs.Vs.ALL.SEQS.domtblout.gz";
# my $batchfile  = "/bueno_not_backed_up/sharpton/HMMbatches/family_batch_ALL.hmm.gz";
my $fcihmmdir = "../seqs";
my $output;
my $username = "sharpton";
my $password = "thomas";
my $evalcut  = 0.00001;
my $coverage = 0.8;
my $fci_check = 0; #do a lighthouse db lookup to ensure that sequences are from proper fci families
my @fcis      = ( 4, 6 );
my $good_fci_seqs = "../data/fci_4_6_seed_seq_ids.txt";
my $tophit           = 0;
my $screen_prom_seqs = 0; #should we filter out promiscuous sequences?
# my $prom_seq_val;         #integer - largest n fam hits we should accept 
#my $prom_seq_lookup  = "/home/sharpton/projects/protein_families/results/ALL_search_results_SEQS_fci_e10_5_c80.tab";
#my $prom_seq_lookup  = "/home/sharpton/projects/protein_families/results/ALL_search_results_SEQS_fci_e10_5_c80_wlarge.tab";
# my $prom_seq_lookup  = "/home/sharpton/projects/protein_families/results/ALL_search_results_SEQS_fci46_e10_5_c80_wlarge_COVERBOTH.tab";

GetOptions(
    "i:s"  => \$resultfile, #compressed with gzip
    # "b:s"  => \$batchfile,  #compressed with gzip
    "o=s"  => \$output,
    "e:f"  => \$evalcut,
    "c:f"  => \$coverage,
    "f:s"  => \$good_fci_seqs,
    "t"    => \$tophit,     #1/0
    "p"    => \$screen_prom_seqs,
    "fam:s" => \$fcihmmdir,
    # "pv:i" => \$prom_seq_val,
    );

# print ( "Using coverage cutoff of " . $coverage . "\n" );
# print ( "Using evalue cutoff of " . $evalcut . "\n" );

#Initialize the project
# my $project = MRC->new();
# #Get a DB connection 
# $project->set_dbi_connection( "DBI:mysql:IMG:lighthouse.ucsf.edu" );
# $project->set_username( $username );
# $project->set_password( $password );
# my $schema  = $project->build_schema();

## this function is superceded by parse_hmm_dir subroutine
# #not all hmms will have hits. we need to record data for these anyhow, so open the hmmbatchfile and get hmmids
# my @hmms = ();
# @hmms = @{ parse_batchfile( $batchfile ) };
my $hmmhash = parse_hmm_seqs_dir( $fcihmmdir );

my $famhash = build_family_hash( $resultfile );

# my %good_seqs = ();
# if( $fci_check == 1 ){
#     open( FCI, "$good_fci_seqs" ) || die "Can't open good fci seqs file $good_fci_seqs for read: $!\n";
#     while( <FCI> ){
# 	chomp $_;
# 	$good_seqs{$_}++;
#     }
# }

# my %prom_seqs = (); #These are seqs we'll filter out b/c they are promiscuous
# if( $screen_prom_seqs ){
#     print "getting promiscuous sequences\n";
#     open( PROM, $prom_seq_lookup ) || die "Can't open $prom_seq_lookup for read: $!\n";
#     while( <PROM> ){
# 	chomp $_;
# 	next if( $_ =~ m/SEQ_ID/ );
# 	my( $seqid, $nhits ) = split( "\t", $_ );
# 	if( $nhits > $prom_seq_val ){
# 	    print "$seqid hits too many families!\n";
# 	    $prom_seqs{$seqid}++;
# 	}
#     }
# }

#if we want to only count each sequence's top family hit, then we need to do the following:
##1. loop over the entire file and parse determine, for each good_seq, what its top hit is
##2. store top hit data in a hash
##3. enter the loop below and use the top hit lookup hash to make decisions about each familiy's recruitment
my %tophits = ();
if( $tophit ){
    %tophits = %{ get_good_seq_top_hits( $resultfile, \%tophits ) };
    foreach my $hit( keys( %tophits ) ){
	print join( "\t", $hit, $tophits{$hit}->{"hit"}, "\n" );
    }
}

open( OUT, ">$output" ) || die "Can't open $output for write: $!\n";
my $out = *OUT;
print $out join( "\t", "FAMILY_ID", "FAMILY_SIZE", "N_HITS", "N_MEMBER_HITS", "PRECISION", "RECALL", "\n" );

open( IN, "zmore $resultfile |" )  || die "Can't open $resultfile for read: $!\n";

#Store our parsed results in a hash
#$results->{query_id}->{target_id}->{"n_hits"}++;
#                                 ->{"top_hit"} = 1/0;

#process those hmms that have a hmmsearch result
my %has_hits = ();
my %results  = (); 
my $current_q;
#bug test var
my $have_hit = 0;

while(<IN>){
    #are we at the end of the file? eof wasn't working on bueno for some reason
    next if $_ =~ m/\#/;
    next if $_ =~ m/^\-\-\-/; #first zmore line
    chomp $_;
    my @data        = split( " ", $_ );
    my $query       = $data[3];
    my $qlen        = $data[5];
    my $target      = $data[0];
    if( $screen_prom_seqs ){
	# next if( defined( $prom_seqs{$target} ) );
    }
    # next unless( defined( $good_seqs{$target} ) );
    #if $tophit is set and if this target's top hit is not the query, pass
    next if ( $tophit && $tophits{$target}->{"hit"} != $query );

    my $tlen        = $data[2];
    my $cevalue     = $data[11];
    my $evalue      = $data[12]; #i-Evalue. Use this for now. HMMER RECOMMENDS (for single domain analyses), but might be more restrictive
    my $score       = $data[13];
    my $bias        = $data[14];
    my $q_aln_start = $data[15]; #hmm from
    my $q_aln_stop  = $data[16]; #hmm to
    my $q_coverage  = calculate_coverage( $q_aln_start, $q_aln_stop, $qlen );
    my $t_aln_start = $data[17]; #ali coord from
    my $t_aln_stop  = $data[18]; #ali coord to
    my $t_env_start = $data[19]; #env coord from HMMER RECOMMENDS USE
    my $t_env_stop  = $data[20]; #env coord to HMMER RECOMMENDS USE
    my $t_coverage  = calculate_coverage( $t_env_start, $t_env_stop, $tlen );

    if( defined( $current_q )){
		if( $query ne $current_q ){
		    $has_hits{$current_q}++;
		    process_query( $current_q, \%results, $out, $famhash, $hmmhash );
		    %results = ();
		    $current_q = $query;
		}
    }
    #if( $evalue <= $evalcut && ( $t_coverage >= $coverage || $q_coverage >= $coverage ) ){
    #note: normally we use the above! I'm turning on the switch below to test the effect!!!
    if( $evalue <= $evalcut && ( $t_coverage >= $coverage && $q_coverage >= $coverage ) ){
	if( !( exists( $results{$query} ) ) ){
	    #is this the first hit for the domain (that passes our thresholds)? Note that this is different 
	    #than the data in %tophits, which is each SEQUENCE'S top hit, not FAMILY
	    $results{$query}->{$target}->{"top_hit"} = 1;
	}
	else{
	    $results{$query}->{$target}->{"top_hit"} = 0;
	}
	$results{$query}->{$target}->{"n_hits"}++;
    }
    elsif( $evalue <= $evalcut ){
	print "Passing on $target with $t_env_stop and $t_env_stop and coverage $t_coverage and evalue of $evalue\n";
    }
    else{
	print "evalue didn't pass on $target\n";
    }
    $current_q = $query;
    if( eof ){
	print "end of file reached\n";
	process_query( $current_q, \%results, $out, $famhash, $hmmhash );
	$has_hits{$current_q}++;
    }    
}
close IN;

foreach my $hmm( keys(%{$hmmhash}) ){
    if( exists( $has_hits{$hmm} ) ){
	next;
    }
    my %results = ();
    process_query( $hmm, \%results, $out, $famhash, $hmmhash );
}
close OUT;








#
# SUBROUTINES
#

sub get_good_seq_top_hits{
    my $resultfile = $_[0];
    my %tophits    = %{ $_[1] };
    #loop over the file and build a hash of top hits for each seq. yes, we will repeat some calcs, but we have to fit this in
    #on top of the old code in a quick way
    open( IN, "zmore $resultfile |" )  || die "Can't open $resultfile for read: $!\n";    
    while(<IN>){
	#are we at the end of the file? eof wasn't working on bueno for some reason
	next if $_ =~ m/\#/;
	next if $_ =~ m/^\-\-\-/; #first zmore line
	chomp $_;
	my @data        = split( " ", $_ );
	my $query       = $data[3]; #the model
	my $qlen        = $data[5];
	my $target      = $data[0]; #the sequence
	my $tlen        = $data[2];
	my $cevalue     = $data[11];
	my $evalue      = $data[12]; #i-Evalue. Use this for now. HMMER RECOMMENDS (for single domain analyses), but might be more restrictive
	my $score       = $data[13];
	my $bias        = $data[14];
	my $q_aln_start = $data[15]; #hmm from
	my $q_aln_stop  = $data[16]; #hmm to
	my $q_coverage  = calculate_coverage( $q_aln_start, $q_aln_stop, $qlen );
	my $t_aln_start = $data[17]; #ali coord from
	my $t_aln_stop  = $data[18]; #ali coord to
	my $t_env_start = $data[19]; #env coord from HMMER RECOMMENDS USE
	my $t_env_stop  = $data[20]; #env coord to HMMER RECOMMENDS USE
	my $t_coverage  = calculate_coverage( $t_env_start, $t_env_stop, $tlen );
	if( !defined( $tophits{$target}->{"hit"} ) ){
	    %tophits = %{ store_top_hit( $target, $query, $evalue, $score, $q_coverage, \%tophits ) };
	}
	else{
	    #HMMER sorts top hits by evalue, so we will use that to find best hit. In case of tie, go to score, then coverage.
	    if( $evalue < $tophits{$target}->{"evalue"} ){
		%tophits = %{ store_top_hit( $target, $query, $evalue, $score, $q_coverage, \%tophits )};
	    }
	    elsif( $evalue == $tophits{$target}->{"evalue"} ){
		#break the tie
		if( $score > $tophits{$target}->{"score"} ){
		    %tophits = %{ store_top_hit( $target, $query, $evalue, $score, $q_coverage, \%tophits )};
		}
		elsif( $score == $tophits{$target}->{"score"} ){
		    #break the tie
		    if( $q_coverage > $tophits{$target}->{"q_coverage"} ){
			%tophits = %{ store_top_hit( $target, $query, $evalue, $score, $q_coverage, \%tophits )};
		    }
		}
	    }
	}
    }	
    close IN;
    return \%tophits;
}

sub store_top_hit{
    my( $target, $query, $evalue, $score, $q_coverage, $rh_tophits ) = @_;
    my %tophits = %{ $rh_tophits };
    $tophits{$target}->{"hit"}    = $query;
    $tophits{$target}->{"evalue"} = $evalue;
    $tophits{$target}->{"score"}  = $score;
    $tophits{$target}->{"q_coverage"} = $q_coverage;	    
    return \%tophits;
}
    

sub process_query{
    my $hmm     = shift; #family id
    my $results = shift; #ref to a hash
    my $out     = shift; #filehandle
    my $famhash = shift; #hash ref of famid->geneid->geneid
    my $hmmhash = shift; #hash ref of fci_x fam member ids famid->nseqs
    print "Processing $hmm...\n";
    #initialize a few parameters for the family
    my $precision  = 0;
    my $recall     = 0;
    my $n_hits     = 0;
    
    # my @keys = 	keys(%{$famhash->{$hmm}});
    # for my $key (@keys){
    # 	print "$key\n";
    # } 

    #initialize a few vars for the family
    # my $n_members       = keys( %{ $famhash->{$hmm} } );
    print "${$hmmhash}{$hmm}\n";
    my $n_members       = $hmmhash->{$hmm} ;
    my $member_hits     = 0;
    my $non_member_hits = 0;
    my $all_mems_hit    = 0; #sets to 1 if all members in family are hit
    #now parse the results data for family
    if( !( defined( $results->{$hmm} ) ) ){
	print "\tNo hit\n";
	print OUT join( "\t", $hmm, $n_members, $n_hits, $member_hits, $precision, $recall, "\n" )	
    }
    else{
	#loop over all the hits and determine if they are members or not
	#we won't sort hits because this takes some time and doesn't give big payoff given that we
	#can randomly draw hits and compare to sorted members. Put efficiency in that comparison
	foreach my $hit( keys( %{ $famhash->{$hmm} } ) ){
	    print "\tFound hit: $hit\n";
	    #not worrying about top hit filter right now
	    print "\t$n_hits\n";
	    if( $all_mems_hit ){
		print "\t\t...is not a member\n";
		$non_member_hits++;	   
	    }
	    else{
		my $is_member = check_if_member( $famhash, $hmm, $hit );
		if( $is_member ){
		    print "\t\t...is a member\n";
		    $member_hits++;
		    if( $member_hits == $n_members ){
			$all_mems_hit = 1;
			print "\t\t...all members found\n";
		    }
		}
		else{
		    print "\t\t...is not a member\n";
		    #THE OLD FCI CHECK
		    #my $famid = $project->MRC::DB::get_famid_from_geneoid( $hit, \@fcis );
		    #for now we'll assume that sequences without a family construction id are not members of families we care about.
		    #if( !defined( $famid ) ){
		    #warn( "Couldn't get famid for $hit\n" );
		    #print "\t\t\t...not proper family construction id\n";
		    #next;
		    #}
		    #THE NEW FCI CHECK (HOPEFULLY FASTER)
		 #    if( !defined( $good_seqs{$hit} ) ){			
			# print "\t\t\t...not proper family construction id\n";
			# next;
		 #    }
		    $non_member_hits++;
		}
		$n_hits++;
	    }
	}
	#now that we know which are members, calculate precision and recall
	if( $n_hits == 0 ){
	    $precision = 0;
	}
	else{
	    $precision = $member_hits / $n_hits;
	}
	$recall    = $member_hits / $n_members;
	print OUT join( "\t", $hmm, $n_members, $n_hits, $member_hits, $precision, $recall, "\n" );
    }
}

sub check_if_member{
    my $famhash   = shift; #ref hash of member ids                                                                                                                                                                                             
    my $famid     = shift;
    my $memberid  = shift;
    my $is_member = 0;
    if( exists( $famhash->{$famid}->{$memberid} ) ){
        $is_member = 1;
    }
    return $is_member;
}

sub calculate_coverage{
    my ( $start, $stop, $length ) = @_;
    my $aln_len = 0;
    if( $start > $stop ){
	$aln_len = $start - $stop;
    }
    elsif( $stop > $start ){
	$aln_len = $stop - $start;
    }
    my $coverage = $aln_len / $length;
    return $coverage;
}


### this subrouthine is superceded by the build_family_hash subroutine
sub parse_batchfile{
    my $file = shift;
    my @hmms = ();
    open( HMMS, "zmore $file |" ) || die "Can't read $file: $!\n";
    while(<HMMS>){
	if( $_ =~ m/NAME\s+(\d+)/ ){
	    my $id = $1;
	    push @hmms, $id;
	}
    }
    close HMMS;
    return \@hmms;
}

sub parse_hmm_seqs_dir{
	my $path = shift;
	my @hmmFiles = glob("$path/*.gz");
	# print "$hmmFiles[0]\n";
	my $hmmhash = {};
	my $id;
	my $nseq;
	# print "$hmmFiles[0]\n";
	for my $file (@hmmFiles){
		$nseq = 0;
		if( $file =~ m/\/(\d+).+\.gz/ ){
			print "\$id = $1\n";
			$id = $1;
		}
		open( HMMS, "zmore $file |" ) || die "Can't read $file: $!\n";
		while(<HMMS>){
			if( $_ =~ m/^>/ ){
				$nseq++;
				print "$nseq\n";
			}
		}
		$hmmhash->{$id} = $nseq;
		print "parsed $file\n";
		print "\$hmmhash->{$id}->{$nseq}\n";
	}
	print "parsed $path\n";
	return $hmmhash;
}




sub build_family_hash{
	my $resultfile = shift;

	open( IN, "zmore $resultfile |" )  || die "Can't open $resultfile for read: $!\n";

	
	my $famhash = {}; 
	# my $c = 0;
	while(<IN>){
	    #are we at the end of the file? eof wasn't working on bueno for some reason
	    next if $_ =~ m/\#/;
	    next if $_ =~ m/^\-\-\-/; #first zmore line
	    chomp $_;
		my @data        = split( " ", $_ );
		#gets the gene and family for each gene 
	    my @gene_fam	= split( "-", $data[0]);
	   
	    my $gene_id 	= $gene_fam[0];
	    # print "gene_id\t$gene_id\n";
	    my $fam_id 		= $gene_fam[1];
	    # print "fam_id\t$fam_id\n";

	    # print "$gene_id\t$fam_id\n";

	    $famhash->{$fam_id}{$gene_id} = $gene_id;
	    print 	"fam_id\t%$famhash->{$fam_id}\n";
	    # my @keys = 	keys(%{$famhash->{$fam_id}});
	    # for my $key (@keys){
	    # 	print "$key\n";
	    # } 
	    # print  "\n";
	 	#    $c++;
		# if($c >= 50){
		# 	last;
		# }
	}

	close IN;
	return $famhash;
}