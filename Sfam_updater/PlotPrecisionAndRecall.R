library(ggplot2)
library(scales)

asinh_trans <- function(){
  trans_new(name = 'asinh', transform = function(x) asinh(x), 
            inverse = function(x) sinh(x))
}

#call as follows
# % R --slave --args <directory_to_results> <file_name_of_precision_and_recall_results_table>  < stats_plot_precision_recall_hists_ggplot_COVERBOTH_fortim.R 

Args     <- commandArgs()

indir    <- Args[4]
all.inf  <- Args[5]

intab     = paste( indir, all.inf,  sep="" )
titletype = "Global"

all.tab   = read.table( file = intab,   header = TRUE )

dataTable = all.tab
## recall
p1 <- qplot( RECALL, data=all.tab, geom="histogram", xlab="Family Recall", ylab="Count", main="Family Recall Histogram (All Sequences)", origin = -0.05 )
ggsave( p1, filename="FamilyRecallHistALL.pdf" )

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

ggsave(m, filename="FCI2_Family_Recall_Histogram-AsinH.pdf", width = 7, height = 7)
##precision
p2 <- qplot( PRECISION, data=all.tab, geom="histogram", xlab="Family Precision", ylab="Count", main="Family Precision Histogram (All Sequences)", origin = -0.05 )
ggsave( p2, filename="FamilyPrecisionHistALL.pdf" )

m<-ggplot(dataTable, aes(x=PRECISION)) +
  #, origin = (bw/2)
  geom_histogram(binwidth = 0.05)+ 
  scale_y_continuous(trans=asinh_trans(), breaks = grid , name = "Count (arcSinh transformed)")+
  scale_x_continuous(breaks = grid2 , name = "Family Precision") +
  ggtitle("FCI2 Family Precision Histogram")

ggsave(m, filename="FCI2_Family_Precision_Histogram-AsinH.pdf", width = 7, height = 7)


## familysize

p5 <- qplot(FAMILY_SIZE, data=all.tab, geom="histogram", xlab="Number of Sequences in Family", ylab="Count", main="Family Size Distribution (All Families)", origin = -0.05 )
ggsave( p5, filename="FamilySizesALL.pdf" )

small <- subset(all.tab, all.tab$FAMILY_SIZE < 20 )
p6 <- qplot(FAMILY_SIZE, data=small, geom="histogram", xlab="Number of Sequences in Family", ylab="Count", main="Family Size Distribution (Families < 20 Members)", binwidth=1, origin=-0.05 )
ggsave( p6, filename="FamilySizesSub20.pdf" )


m<-ggplot(dataTable, aes(x=FAMILY_SIZE)) +
  #, origin = (bw/2)
  geom_histogram()+ 
  scale_y_continuous(trans=asinh_trans(), breaks = grid , name = "Count (arcSinh transformed)")+
  scale_x_continuous( name = "Family Size") +
  ggtitle("FCI2 Family Size Histogram")

ggsave(m, filename="FCI2_Family_Size_Histogram-AsinH.pdf", width = 7, height = 7)


m<-ggplot(small, aes(x=FAMILY_SIZE)) +
  #, origin = (bw/2)
  geom_histogram(binwidth=1)+ 
  scale_y_continuous(trans=asinh_trans(), breaks = grid , name = "Count (arcSinh transformed)")+
  scale_x_continuous( name = "Family Size") +
  ggtitle("FCI2 Family Size Histogram (Family Size < 20)")

ggsave(m, filename="FCI2_Family_Size_less_than_20_Histogram-AsinH.pdf", width = 7, height = 7)



