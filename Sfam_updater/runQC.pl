#!/usr/bin/perl -w
package Sfam_gather_genes;
use Sfam_updater::DB_op;
use strict;
use Getopt::Long;
use parse_hmmsearch_results_topm

## options 
my(

	$hmmsearchFile,
	$outputpath,
	$batchfile,
	$username, # to verify family members
	$password, # "            "


	);

GetOptions(
	## get command line options




	);



## call parse_hmmsearch_results.pl
if (parse_hmmsearch_results_topm(
	#options go here



	)

){
	print "parsing successful";
}