#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use POSIX;
use File::Glob;
use Storable;
use Data::Dumper;
use diagnostics;

my $intab = "famToKoPathTab.txt.gz";
my $outtab = "famKoStatTab.txt";
my $cutoff = 0.5 ;

our $verbose = 0 ;

GetOptions 	( "intab=s" => \$intab,
	"outtab=s"  => \$outtab,
	"verbose"   => \$verbose,
    "cutoff"    => \$cutoff,
    ) or die("Invalid command line arguments\n");

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);

my $curTime = $year + 1900 ."-".( $mon + 1)  ."-". $mday . "-" . $hour . "-" . $min . "-" . $sec ."-";

print "curtime:\t$curTime\n";


##<STDIN>;
    
my $famStatHash = makeFamStatHash( intab=>$intab, cutoff=>$cutoff );

my $f = $famStatHash;

$outtab = $curTime.$outtab;

open OUT, "> $outtab" || die "Could not open $outtab,  $!";
my $header = "fam\tnumKO\tnumPath\n";

for my $fam ( sort {$a <=> $b}  (keys( %$f )) ){
    print "fam\t".$fam."\n" if ($verbose);
    print Dumper($f->{$fam})."\n" if ($verbose);
    my $row = $fam."\t";
    if (  $f->{$fam}->{KO} ){ 
        $row .= keys($f->{$fam}->{KO})."\t";
    } else {
        $row .= "0\t";
    }
    if( $f->{$fam}->{path} ){
        $row .= keys($f->{$fam}->{path})."\n";
    } else {
        $row .= "0\n";
    }
    print "row\t$row" if ($verbose);
    print OUT $row;
}

close(OUT);


sub makeFamStatHash{
    my %args = @_;
    my $intab = $args{intab};
	my $cutoff = $args{cutoff};
    my $header = 2;
    my $famHash = {};
    open IN, "zmore $intab |" || die "error opening $intab $!";
    while (my $line =  <IN> ){
        print "line".$line."\n" if ($verbose);
        if($header){
           $header--;
        } else {
            #<STDIN> if($verbose);
            chomp ($line);
            my @fields = split("\t" , $line );
            if ($fields[8] ne "NA"){
                if( $fields[8] >= $cutoff) {
                    if ( $fields[1] ne "NA") {
                        $famHash->{$fields[0]}->{KO}->{$fields[1]} = 1;
                        if ($fields[9] ne "NA"){
                            my @paths = split(",", $fields[9]);
                            for my $path ( @paths ) {

                                $famHash->{$fields[0]}->{path}->{$path} = 1;

                            }
                        }
                    }
                }
            } else {
                $famHash->{$fields[0]}->{KO} = 0;
                $famHash->{$fields[0]}->{path} = 0;
            }
        }
    }
    close(IN);
    return $famHash;
}


