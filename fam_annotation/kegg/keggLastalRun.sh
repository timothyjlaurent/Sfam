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
#$ -t 1-437         
hostname 
date             

outdir="./lastout/"
db="./keggSeqDB"
famPattern=fci_*HMMs*



cd /pollard/shattuck0/laurentt/kegFamFasta

qstat -j $JOB_ID

# if [ ! -d "$logdir" ]; then
# 	mkdir $logdir
# fi

if [ ! -d "$outdir" ]; then
	mkdir $outdir
fi



domtblout=${outdir}${SGE_TASK_ID}tblout

lastal -o ${domtblout} -f 0 $db  famSeq_.${SGE_TASK_ID}  

gzip ${domtblout}
