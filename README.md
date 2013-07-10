2013 07 10

Timothy Laurent

This Sfam Repository is to hold code for analysis and classification of Sfam Data http://www.biomedcentral.com/1471-2105/13/264/

The Sfam_updater directort has library code for accessing the Sfam Database as well as programs to generate Precision and
recall statistics from an all vs all HMMER search of Sfamily members vs all S family HMMs.

The analysis dir has R code for generating graphs a host of graphs visualizing family size, precision, recall, the results of
the interproscan domain annotaion for the protein family.

The Annotation dir has code to parse the results of the interproscan search matching family to domain annotataion; the kegg directory has code for running an all vs all lastal cluster job of Sfam members vs the KEGG database and then parsing the results to generate tabular date of kegg orthology designation with the family and the kegg pathways they belong to.


