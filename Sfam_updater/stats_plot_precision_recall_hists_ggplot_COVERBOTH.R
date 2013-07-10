library( ggplot2 )

#call as follows
# % R --slave --args <directory_to_results> <file_name_of_precision_and_recall_results_table>  < stats_plot_precision_recall_hists_ggplot_COVERBOTH_fortim.R 

Args     <- commandArgs()

indir    <- Args[4]
all.inf  <- Args[5]
prom.inf <- Args[6]  #you can probably remove references to this variable, not in example above

#example setting for the commandline args follow
#indir     = "/home/sharpton/projects/protein_families/results/"
#all.inf   = "ALL_search_results_fci46_e10_5_c80_wlarge_COVERBOTH.tab"
#prom.inf  = "ALL_search_results_fci46_e10_5_c80_wlarge_COVERBOTH_prom8.tab"
intab     = paste( indir, all.inf,  sep="" )
#promtab   = paste( indir, prom.inf, sep="" )

titletype = "Global"

all.tab   = read.table( file = intab,   header = TRUE )
#prom.tab  = read.table( file = promtab, header = TRUE )

all.tab.p  = subset(all.tab,  all.tab$PRECISION == 1  & all.tab$RECALL == 1)
#prom.tab.p = subset(prom.tab, prom.tab$PRECISION == 1 & prom.tab$RECALL == 1)

###############
#ALL SEQUENCES
#Recall
p1 <- qplot( RECALL, data=all.tab, geom="histogram", xlab="Family Recall", ylab="Count", main="Family Recall Histogram (All Sequences)", origin = -0.05 )
ggsave( p1, filename="FamilyRecallHistALL.pdf" )

p1log <- qplot(RECALL, data=all.tab,  geom="histogram", log='y', xlab="Family Recall", ylab="log Count", main="Family Recall Histogram\n(All Sequences; log Count)", origin = -0.05 )
ggsave( p1log, filename="FamilyRecallHistALLlogy.pdf" )

#Precision
p2 <- qplot( PRECISION, data=all.tab, geom="histogram", xlab="Family Precision", ylab="Count", main="Family Precision Histogram (All Sequences)", origin = -0.05 )
ggsave( p2, filename="FamilyPrecisionHistALL.pdf" )

p2log <- qplot(PRECISION, data=all.tab, geom="histogram",  xlab="Family Precision", ylab="log Count", main="Family Precision Histogram\n(All Sequences; log Count)", origin = -0.05 )
ggsave( p2log, filename="FamilyPrecisionHistALLlogy.pdf" )

##########################
#NO PROMISCIOUS SEQUENCES
#Recall
#p3 <- qplot( RECALL, data=prom.tab, geom="histogram", xlab="Family Recall", ylab="Count", main="Family Recall Histogram (No Promiscuous Sequences)", origin = -0.05 )
#ggsave( p3, filename="FamilyRecallNoProm.pdf" )

#Precision
#p4 <- qplot( PRECISION, data=prom.tab, geom="histogram", xlab="Family Precision", ylab="Count", main="Family Precision Histogram (No Promiscuous Sequences)", origin = -0.05 )
#ggsave( p4, filename="FamilyPrecisionNoProm.pdf" )

#############
#OTHER STATS
#Correlation betwen total hits and family hits per family

#Family Size Distribution
#all families
p5 <- qplot(FAMILY_SIZE, data=all.tab, geom="histogram", xlab="Number of Sequences in Family", ylab="Count", main="Family Size Distribution (All Families)", origin = -0.05 )
ggsave( p5, filename="FamilySizesALL.pdf" )

p5log <- qplot(FAMILY_SIZE, data=all.tab, geom="histogram",  xlab="Number of Sequences in Family", ylab="log Count", main="Family Size Distribution\n(All Families; log Count)", origin = -0.05 )
ggsave( p5log, filename="FamilySizesALLlogy.pdf" )

p5loglog <- qplot(FAMILY_SIZE, data=all.tab, geom="histogram", log="x", xlab="log Number of Sequences in Family", ylab="log Count", main="Family Size Distribution\n(All Families; log Count)", origin = -0.05 )
ggsave( p5loglog, filename="FamilySizesALLlogxy.pdf" )

#subset of families
small <- subset(all.tab, all.tab$FAMILY_SIZE < 20 )
p6 <- qplot(FAMILY_SIZE, data=small, geom="histogram", xlab="Number of Sequences in Family", ylab="Count", main="Family Size Distribution (Families < 20 Members)", binwidth=1, origin=-0.05 )
ggsave( p6, filename="FamilySizesSub20.pdf" )

p6log <- qplot(FAMILY_SIZE, data=small,  geom="histogram", xlab="Number of Sequences in Family", ylab="log Count", main="Family Size Distribution (Families < 20 Members; log Count)", binwidth=1, origin=-0.05 )
ggsave( p6log, filename="FamilySizesSub20logy.pdf" )












