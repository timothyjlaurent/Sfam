#!/bin/bash
# This script will run hmmsearch on a fasta file of all sequences and a cat'ed
# collection of Sfam HMMS.  
# dependencies : hmmsearch must be in the path

#$ -S /bin/bash                    
#$ -o ./chefout                    
#$ -e ./chefout                    
#$ -cwd
#$ -r y
#$ -j y
#$ -l mem_free=5G
#$ -l arch=linux-x64
#$ -l netapp=1G,scratch=1G
#$ -l h_rt=336:00:00
##$ -l h_rt=00:30:00
#$ -t 1-100         
hostname 
date             

outdir="./chefout/"
fasta="./fasta/familymembers.fasta"
# fasta="./fasta/smallfamily.fasta"
hmmdir="./catHmmDir/"
hmmPattern=fci_*HMMs*
domtbloutdir="./domtblout/"
logdir="./HMMsearch_logs/"
# fulloutdir="./fullout/"

cd /pollard/shattuck0/laurentt/Sfam_updater

qstat -j $JOB_ID

# if [ ! -d "$logdir" ]; then
# 	mkdir $logdir
# fi

if [ ! -d "$outdir" ]; then
	mkdir $outdir
fi

if [ ! -d "$domtbloutdir" ]; then
	mkdir $domtbloutdir
fi

# if [ ! -d "$fulloutdir" ]; then 
# 	mkdir $fulloutdir
# fi


for f in `ls $hmmdir$hmmPattern`; do
	# get base filename
	f=$(echo $f | sed -r 's/[0-9]+.gz$//')
	echo $f
	IFS="/" read -ra FILENAME <<< "$f"
	for last in "${FILENAME[@]}"; do :; done
	echo $last

	
	# echo $domtblout 
	break
done

domtblout=$last$SGE_TASK_ID.Vs.ALL.SEQS.domtblout

hmmsearch --domtblout $domtbloutdir$domtblout $f$SGE_TASK_ID.gz $fasta #> $domtbloutdir$domtblout.log

gzip $domtbloutdir$domtblout