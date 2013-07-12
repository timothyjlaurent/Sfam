#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use POSIX;
use File::Glob;
use Storable;
use Data::Dumper;
use diagnostics;

our $debug = 0 ;

my $hitTable = "/mnt/data/work/pollardlab/laurentt/kegFamFasta/sfamKoEcTab.txt.gz";
my $fastaBaseFolder = "/mnt/data/home/sharpton/pollardlab/sharpton/20130401";
my $outfile = "famKoPathTab.txt";
my $pathTab = "keggPathways.txt";
my $koToPathTab = "keggKoToPathway.txt";
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time); 
my $curTime = $year + 1900 ."-".( $mon + 1)  ."-". $mday . "-" . $hour . "-" . $min . "-" . $sec ."-";
print "curtime:\t$curTime\n";
$outfile = $curTime.$outfile;

open OUT, ">$outfile";


my $pathToDescHash = makePathToDescHash( path=>$pathTab );

my $koToPathHash = makeKoToPathHash( path=>$koToPathTab );

##fixTable( tab=>"./famToKoTab.txt.gz", koToPathHash=>$koToPathHash, pathToDescHash=>$pathToDescHash);

##die;

my $famSizeHash ;
#$famSizeHash = countFamMembers($fastaBaseFolder);
#store \%{$famSizeHash}, 'famSize.hash';
 $famSizeHash = retrieve('famSize.hash');

my $famKOhash;
#$famKOhash = makefamKOhash($hitTable); 
#store \%{$famKOhash}, 'famKO.hash';
$famKOhash = retrieve('famKO.hash');


# die;

my $header = "famid\tkoID\tEC\tDESC\tMembers\thitPerMember\tnumHits\tfamSize\tproportion\tpathway\tpathDescription\n";
print OUT $header;
##my @fams = sort (keys(%$famKOhash));
my @fams = sort { $a <=> $b  } (keys(%$famSizeHash));

for my $fam (@fams){
	warn Dumper ($famKOhash->{$fam}) if ($debug);
	# readline;
	print $fam."\n" if ($debug);
    if( defined ($famKOhash->{$fam})){
        my @kos = sort(keys($famKOhash->{$fam}));
        for my $ko (@kos){
             my $row; 
            print $ko."\n";
            $row = $fam."\t";
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
             $row .= @members/$famSizeHash->{$fam}."\t";
             if (defined( $koToPathHash->{$ko} )) {
                my @path = sort(keys($koToPathHash->{$ko}));
                $row .= join(',', @path)."\t";
                my @pathDesc;
                for( my $i = 0 ; $i < @path ; $i++ ){
                    my $path = $path[$i];
                    my @desc = keys($pathToDescHash->{$path});
                    ##print $desc[0]."\n";
                    $pathDesc[$i] = $desc[0];
                }
                $row .= join(',',@pathDesc)."\n";
            } else {
                $row .= "NA\tNA\n";
            }
            
            #print $row;
            print OUT $row;
        }
    } else {
       
        my  $row= "$fam\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\n";
        #print $row;
        print OUT $row;
    }
}
close (OUT);
system("gzip $outfile");


print "end of script\n";



sub fixTable{
	print "in fixTable\n";
	my %args = @_;
	my $tabPath = $args{tab};
	my $koToPathHash = $args{koToPathHash};
	my $pathToDescHash = $args{pathToDescHash};
	open ( OUT, '> famKoPathTab.txt') || die "cannot open famKoPathTab.txt";
	open( IN, "zmore $tabPath |" ) || die "cannot open $tabPath";
	
	my $header = "famid\tkoID\tEC\tDESC\tMembers\thitPerMember\tnumHits\tfamSize\tproportion\tpathway\tpathDescription\n";
	print OUT $header;
	my $i =0;
	my $row = <IN>;
	print "before while\t$row\n";
	while ( my $row = <IN> ) {
		if ($row=~ qq/koID/){
			next;
		}
		else {
			chomp ($row);
			my @fields = split( '\t' , $row ) ;
			my $ko = $fields[1];
			print "$ko\n";
			#print Dumper($koToPathHash)."\n";	
			if (defined( $koToPathHash->{$ko} )) {
				my @path = sort(keys($koToPathHash->{$ko}));
				$row .= join(',', @path)."\t";
				my @pathDesc;
			 	for( my $i = 0 ; $i < @path ; $i++ ){
				 	my $path = $path[$i];
				 	my @desc = keys($pathToDescHash->{$path});
				 	print $desc[0]."\n";
				 	$pathDesc[$i] = $desc[0];
			 	}
			 	$row .= "\t".join(',',@pathDesc)."\n";
			} else {
				$row .= "\tNA\tNA\n";
			}
			 print $row;
			 print OUT $row;
		}
	}
	close (OUT);
}



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
sub makeKoToPathHash{
	print "In makeKoToPathHash\n";
	my %args = @_;
	my $path = $args{path};
	my $koToPathHash = {};
	open (IN , "< $path") || die "cannot open $path";
	while (my $line = <IN> ){
		chomp ($line);
		if ( $line =~ qq/path:ko/ ){
			next;
		} else{
			
			my @fields = split( '\t', $line );
			$koToPathHash->{$fields[0]}->{$fields[1]} = 1;
            ##	print "$line\t".$fields[0]."\t".$fields[1]."\n"; 
		} 
	}
	return $koToPathHash;
}


sub makePathToDescHash{
	print "In makePathToDescHash\n";
	my %args = @_;
	my $path = $args{path};
	my $pathToDescHash = {};
	open (IN, "< $path") || die "cannot open $path";
	while( my $line = <IN>){
		chomp( $line );
		my @fields = split ( '\t' , $line );
		$pathToDescHash->{$fields[0]}->{$fields[1]} = 1;
        #print "$line\t".$fields[0]."\t".$fields[1]."\n";	
	}
	return $pathToDescHash;
}
