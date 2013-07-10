#Invoke % R --slave --args intab outpdf titletype < tree_to_matrix.R

Args <- commandArgs()
intab <- Args[4]
outpdf <- Args[5]
titletype <- Args[6]
tab <- read.table( file =intab, header = TRUE )
subset(tab, tab$PRECISION == 1 & tab$RECALL == 1)->perfect_tab

pdf(file = outpdf)

hist(tab$RECALL, breaks=50, col="blue", xlim=c(0,1), xlab = "Fraction of Member Sequences Recruited by HMM", main = paste( "Family Recall (", titletype, ")", sep = "" ) )

hist(tab$PRECISION, breaks=50, col="blue", xlim=c(0,1), xlab = "Non-Member Recruited Sequences / All Recruited Sequences", main = paste( "Family Precision (", titletype,")", sep = "") )

#cor.test(tab$N_MEMBER_HITS, tab$N_HITS, method="spearman")

plot(tab$N_MEMBER_HITS, tab$N_HITS, xlab = "Number of Family Sequences Recruited", ylab = "Total Number of Recruited Sequences", main="Correlation between Family Hits and Total Hits")

hist(tab$FAMILY_SIZE, breaks = 50, col="blue", xlab="Family Size", main="Family Size Distribution, All Families")

hist(perfect_tab$FAMILY_SIZE, breaks = 50, col="blue", xlim=c(0,250), xlab="Family Size", main=paste("Family Size Distribution, Perfect Families (", titletype, ")", sep = "") )

dev.off()

summary(tab$PRECISION)