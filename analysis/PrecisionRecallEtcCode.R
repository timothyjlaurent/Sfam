library(ggplot2)

asinh_trans <- function(){
  trans_new(name = 'asinh', transform = function(x) asinh(x), 
            inverse = function(x) sinh(x))
}




#call as follows
# % R --slave --args <directory_to_results> <file_name_of_precision_and_recall_results_table>  < stats_plot_precision_recall_hists_ggplot_COVERBOTH_fortim.R 

Args     <- commandArgs()

indir    <- Args[4]
all.inf  <- Args[5]


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

p1log <- qplot(RECALL, data=all.tab,  geom="histogram",  xlab="Family Recall", ylab="log Count", main="Family Recall Histogram\n(All Sequences; log Count)", origin = -0.05 )
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


library(ggplot2)
library(scales)

asinh_trans <- function(){
  trans_new(name = 'asinh', transform = function(x) asinh(x), 
            inverse = function(x) sinh(x))
}


dataTable= fci_2_precision_and_recall_vs_all_family_mambers


#d<-plotAsinhHist(dt = dataTable, hist = recall, title="FCI2 Family Recall Histogram", xlabel="Family Recall", ylabel="Count (arcSinh transformed)" )
grid = c(2,4,6,8,10)
grid = c(0, grid, 10*grid, 100*grid, 1000*grid, 10000*grid, 100000*grid)
grid2 = c(0,1,2,3,4,5,6,7,8,9,10)
grid2 = grid2/10
##, origin = (bw/2)
##m<-ggplot(dt, aes(x=histx))
m<-ggplot(dataTable, aes(x=RECALL)) +
  #, origin = (bw/2)
  geom_histogram(binwidth = 0.05)+ 
  scale_y_continuous(trans=asinh_trans(), breaks = grid , name = "Count (arcSinh transformed)")+
  scale_x_continuous(breaks = grid2 , name = "Family Recall") +
  ggtitle("FCI2 Family Recall Histogram")

ggsave(m, filename="FCI2_Family_Recall_Histogram.pdf", width = 7, height = 7)

## for precision
m<-ggplot(dataTable, aes(x=PRECISION)) +
  #, origin = (bw/2)
  geom_histogram(binwidth = 0.05)+ 
  scale_y_continuous(trans=asinh_trans(), breaks = grid , name = "Count (arcSinh transformed)")+
  scale_x_continuous(breaks = grid2 , name = "Family Precision") +
  ggtitle("FCI2 Family Precision Histogram")

ggsave(m, filename="FCI2_Family_Precision_Histogram.pdf", width = 7, height = 7)

## for family size (large)

m<-ggplot(dataTable, aes(x=FAMILY_SIZE)) +
  #, origin = (bw/2)
  geom_histogram()+ 
  scale_y_continuous(trans=asinh_trans(), breaks = grid , name = "Count (arcSinh transformed)")+
  scale_x_continuous( name = "Family Size") +
  ggtitle("FCI2 Family Size Histogram")

ggsave(m, filename="FCI2_Family_Size_Histogram.pdf", width = 7, height = 7)


## for familysize< 20
small <- subset(fci_2_precision_and_recall_vs_all_family_mambers, fci_2_precision_and_recall_vs_all_family_mambers$FAMILY_SIZE < 20 )

m<-ggplot(small, aes(x=FAMILY_SIZE)) +
  #, origin = (bw/2)
  geom_histogram(binwidth=1)+ 
  scale_y_continuous(trans=asinh_trans(), breaks = grid , name = "Count (arcSinh transformed)")+
  scale_x_continuous( name = "Family Size") +
  ggtitle("FCI2 Family Size Histogram (Family Size < 20)")

ggsave(m, filename="FCI2_Family_Size_less_than_20_Histogram.pdf", width = 7, height = 7)

## proportion of unannotated family members

dt<-fci2_famid_stats

m<-ggplot(dt, aes(x=proportion_nonAnnot)) +
  #, origin = (bw/2)
  geom_histogram(binwidth = 0.05)+ 
  scale_y_continuous(trans=asinh_trans(), breaks = grid , name = "Count (arcSinh transformed)")+
  scale_x_continuous(breaks = grid2 , name = "Proportion of Family Members without Annotation") +
  ggtitle("FCI2 Proportion of Unannotated Family Members")

ggsave(m, filename="FCI2_Proportion_Unannotated_Histogram.pdf", width = 7, height = 7)



## for # of annotations per family

m<-ggplot(dt, aes(x=num_annotations)) +
  #, origin = (bw/2)
  geom_histogram()+ 
  scale_y_continuous(trans=asinh_trans(), breaks = grid , name = "Count (arcSinh transformed)")+
  scale_x_continuous( name = "Number of Annotations per Family (arcSinh transformed)", trans=asinh_trans(), breaks = grid) +
  ggtitle("FCI2 Number of Annotations per Family Histogram")+
  theme(axis.text.x  = element_text(angle=90, vjust=0.5))

ggsave(m, filename="FCI2_NumAnnotations_per_Family_Histogram.pdf", width = 7, height = 7)



## for # families that are annotated >= 0.5

annot = subset(dt, 1- dt$proportion_nonAnnot >= .5)


m<-ggplot(annot, aes(x=1- proportion_nonAnnot)) +
  #, origin = (bw/2)
  geom_histogram(binwidth= 0.025)+ 
  scale_y_continuous(trans=asinh_trans(), breaks = grid , name = "Count (arcSinh transformed)")+
  scale_x_continuous( name = "Proportion of annotated family members", breaks = grid2) +
  ggtitle("FCI2 Number of Family Members Annotated >= 0.5 per Family Histogram")+
  theme(axis.text.x  = element_text(angle=90, vjust=0.5))

ggsave(m, filename="FCI2_number_of_annotated_families_Histogram.pdf", width = 7, height = 7)




precision = fci_2_precision_and_recall_vs_all_family_mambers$PRECISION
d<-plotAsinhHist(dt = dataTable, hist = precision, title="FCI2 Family Precision Histogram", xlabel="Family Precision", ylabel="Count (arcSinh transformed)" )
ggsave(d, filename="FCI2_Family_Precision_Histogram.pdf")


plotAsinhHist <- function(dt, hist, bw = 0.025, title , xlabel, ylabel){

asinh_trans <- function(){
  trans_new(name = 'asinh', transform = function(x) asinh(x), 
            inverse = function(x) sinh(x))
}


grid = c(2,4,6,8,10)
grid = c(0, grid, 10*grid, 100*grid, 1000*grid, 10000*grid, 100000*grid)
grid2 = c(0,1,2,3,4,5,6,7,8,9,10)
grid2 = grid2/10
##, origin = (bw/2)
##m<-ggplot(dt, aes(x=histx))
m<-ggplot(dt, aes(x=hist)) +
  #, origin = (bw/2)
  geom_histogram(binwidth = bw)+ 
  scale_y_continuous(trans=asinh_trans(), breaks = grid , name = ylabel)+
  scale_x_continuous(breaks = grid2 , name = xlabel) +
  ggtitle(title)
  


}




annotatedFams<- subset(fci2_famid_annotation_Fraction,fci2_famid_annotation_Fraction$annotation_fraction>=0.5)
uniquefams <- unique(fci2_famid_annotation_Fraction$fam_id)

uniquefams<- data.frame(uniquefams)

maxAnnot<-sapply(uniquefams$uniquefams, function(x){
  max(subset(fci2_famid_annotation_Fraction,fci2_famid_annotation_Fraction$fam_id ==x )$annotation_fraction)
} 
  )

m<- ggplot(maxAnnot, aes(x= maxAnnot))+ geom_histogram()+
geom_histogram(binwidth = .05) +
  scale_y_continuous( name = "Count")+
  scale_x_continuous( name = "Proportion of Family Members that Share Annotation", breaks = grid2) +
  ggtitle("FCI2 Proportion of Family Members that Share an Annotation Histogram")
ggsave(m, filename="FCI2_Proportion_Annotated.pdf")
maxAnnot <- data.frame(maxAnnot)

m <- qplot(maxAnnot, data=maxAnnot, log="y", xlim=c(0,1.05), geom="histogram",  xlab="Proportion of Family Members that Share Annotation", ylab="log Count", main="FCI2 Proportion of Family Members that Share an Annotation Histogram", origin = -0.05 )
ggsave(m, filename="FCI2_Proportion_Annotated-log.pdf")
m<- ggplot(maxAnnot, aes(x= maxAnnot))+ geom_histogram()+
  scale_y_log10(breaks = grid , name = "Count (arcSinh transformed)")+
  scale_x_continuous( name = "Proportion of annotated family members", breaks = grid2) +
  ggtitle("FCI2 Proportion of Family Members that Share an Annotation Histogram")+
  theme(axis.text.x  = element_text(angle=90, vjust=0.5))
ggsave(m, filename="FCI2_Proportion_Annotated-AsinH.pdf")

hist(maxAnnot)
