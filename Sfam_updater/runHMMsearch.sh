#!/bin/bash
# This script will run hmmsearch on a fasta file of all sequences and a cat'ed
# collection of Sfam HMMS

fasta="./fasta/familymembers.fasta"
hmmDir="./catHmmDir/"
hmmPattern=fci_*HMMs*
outdir="./"


for f in `ls $hmmDir$hmmPattern`; do
	# get base filename
	IFS="/" read -ra FILENAME <<< "$f"
	for last in "${FILENAME[@]}"; do :; done
	# echo $last

	domtblout=$last.Vs.ALL.SEQS.domtblout
	echo $domtblout 

done