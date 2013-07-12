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

our $verbose = 1 ;

GetOptions 	( "intab=s" => \$intab,
	"outtab=s"  => \$outtab,
	"verbose"   => \$verbose,
    "cutoff"    => \$cutoff,
    ) or die("Invalid command line arguments\n");


my $famStatHash = makeFamStatHash( intab=>$intab, cutoff=>$cutoff );

my $f = $famStatHash;

open OUT, "> $outtab" || die "Could not open $outtab,  $!";
my $header = "fam\tnumKO\tnumPath\n";

for my $fam ( keys( %$f ) ){
    my $row = $fam."\t";
    $row .= keys($f->{$fam}->{KO})."\t";
    if( defined( $f->{$fam}->{path} )){
        $row .= keys($f->{$fam}->{path})."\n";
    } else {
        $row .= "0\n";
    }
    print $row if ($verbose);
    print OUT $row;
}

close(OUT);


sub makeFamStatHash{
    my %args = @_;
    my $intab = $args{intab};
	my $cutoff = $args{cutoff};
    my $header = 1;
    my $famHash = {};
    open IN, "zmore $intab |" || die "error opening $intab $!";
    while (my $line =  <IN> ){
        print "line".$line."\n" if ($verbose);
        if($header){
           $header = 0;
        } else {
            <STDIN> if($verbose);
            chomp ($line);
            my @fields = split("\t" , $line );
            if ($fields[8] >= $cutoff) {
                $famHash->{$fields[0]}->{KO}->{$fields[1]} = 1;
                if ($fields[9] ne "NA"){
                    my @paths = split(",", $fields[9]);
                    for my $path ( @paths ) {

                        $famHash->{$fields[0]}->{path}->{$path} = 1;

                    }
                }
            }
        }
    }
    return $famHash;
}


