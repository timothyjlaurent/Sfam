library(ggplot2)
library(scales)

# % R --slave --args <directory_to_results>   < plot_annotation.R 

grid = c(2,4,6,8,10)
grid = c(0, grid, 10*grid, 100*grid, 1000*grid, 10000*grid, 100000*grid)
grid2 = c(0,1,2,3,4,5,6,7,8,9,10)
grid2 = grid2/10

asinh_trans <- function(){
  trans_new(name = 'asinh', transform = function(x) asinh(x), 
            inverse = function(x) sinh(x))
}

Args     <- commandArgs()

indir    <- Args[4]

titletype = "Global"

famAnnotFractFile=  paste(indir, "fci2_famid_annotation_Fraction.tab", sep="/")

famIdStatFile = paste(indir, "fci2_famid_stats.tab", sep="/")

fci2_famid_stats = read.table( file = famIdStatFile,   header = TRUE )
fci2_famid_annotation_Fraction = read.table (file = famAnnotFractFile, header =TRUE)
dt<-fci2_famid_stats
## proportion unannotated
m<-ggplot(dt, aes(x=proportion_nonAnnot)) +
  #, origin = (bw/2)
  geom_histogram(binwidth = 0.05)+ 
  scale_y_continuous(  name = "Count")+
  scale_x_continuous(breaks = grid2 , name = "Proportion of Family Members without Annotation") +
  ggtitle("FCI2 Proportion of Unannotated Family Members")

ggsave(m, filename="FCI2_Proportion_Unannotated_Histogram.pdf", width = 7, height = 7)

m<-ggplot(dt, aes(x=proportion_nonAnnot)) +
  #, origin = (bw/2)
  geom_histogram(binwidth = 0.05)+ 
  scale_y_continuous(trans=asinh_trans(), breaks = grid , name = "Count (arcSinh transformed)")+
  scale_x_continuous(breaks = grid2 , name = "Proportion of Family Members without Annotation") +
  ggtitle("FCI2 Proportion of Unannotated Family Members")

ggsave(m, filename="FCI2_Proportion_Unannotated_Histogram-AsinH.pdf", width = 7, height = 7)


# num annotations per Family

m<-ggplot(dt, aes(x=num_annotations)) +
  #, origin = (bw/2)
  geom_histogram()+ 
  scale_y_continuous( name = "Count")+
  scale_x_continuous( name = "Number of Annotations per Family") +
  ggtitle("FCI2 Number of Annotations per Family Histogram")+
  theme(axis.text.x  = element_text(angle=90, vjust=0.5))

ggsave(m, filename="FCI2_NumAnnotations_per_Family_Histogram.pdf", width = 7, height = 7)

m<-ggplot(dt, aes(x=num_annotations)) +
  #, origin = (bw/2)
  geom_histogram()+ 
  scale_y_continuous(trans=asinh_trans(), breaks = grid , name = "Count (arcSinh transformed)")+
  scale_x_continuous( name = "Number of Annotations per Family (arcSinh transformed)", trans=asinh_trans(), breaks = grid) +
  ggtitle("FCI2 Number of Annotations per Family Histogram")+
  theme(axis.text.x  = element_text(angle=90, vjust=0.5))

ggsave(m, filename="FCI2_NumAnnotations_per_Family_Histogram-AsinH.pdf", width = 7, height = 7)


uniquefams <- unique(fci2_famid_annotation_Fraction$fam_id)

maxAnnot<-sapply(uniquefams, function(x){
  max(subset(fci2_famid_annotation_Fraction,fci2_famid_annotation_Fraction$fam_id ==x )$annotation_fraction)
} 
)

maxAnnot = data.frame(maxAnnot)

m<- ggplot(maxAnnot, aes(x= maxAnnot))+ geom_histogram()+
  geom_histogram(binwidth = .05) +
  scale_y_continuous( name = "Count")+
  scale_x_continuous( name = "Proportion of Family Members that Share Annotation", breaks = grid2) +
  ggtitle("FCI2 Proportion of Family Members that Share an Annotation Histogram")
ggsave(m, filename="FCI2_Proportion_Annotated.pdf")



m <- qplot(maxAnnot, data=maxAnnot, log="y", xlim=c(0,1.05), geom="histogram",  xlab="Proportion of Family Members that Share Annotation", ylab="log Count", main="FCI2 Proportion of Family Members that Share an Annotation Histogram", origin = -0.05 )

ggsave(m, filename="FCI2_Proportion_Annotated-logy.pdf")











