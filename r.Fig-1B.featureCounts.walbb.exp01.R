#!/bin/env R

rm(list = ls())

## featureCounts data has been merged and processed (RPMs) using my perl script
## Plot it now

library(ggplot2)
library(rcartocolor)
library(patchwork)
library(plotly)
library(htmlwidgets)

library(dplyr)
library(stringr)


## metadata

metadata_folder <- "path_to_appropriate_folder"

gene2biotypes_file <- "path_to_appropriate_folder/wAlbB_NEB/v2019-02-15/RefSeq_NZ_CP031221.1/walbb_biotypes.v20260316.tsv";
gene2biotypes <- read.table(gene2biotypes_file, sep = "\t", h = T)
unique(gene2biotypes[,"Gene_biotype"])
# [1] "protein_coding" "Others"         "ncRNA"          "rRNA"          

## Define "treatments" for correct barplot ordering
# treatments_df <- data.frame(Sample = c("walbb_control_noEnrich", "walbb_1x_enrich", "walbb_2x_enrich"), Treatment = c("Control_noEnrich", "Enrich_1x", "Enrich_2x" ))
treatments_metadata_file <- paste(metadata_folder, "table.sample_treatmentNames.v2.tsv", sep = "/")
treatments_df <- read.table(treatments_metadata_file, sep = "\t", h = T)


####------------- Setup colors ----------------------------
my_biotype_colors_file <- paste(metadata_folder, "walbb.gene2biotype.colors.v2_20260408.tsv", sep = "/");
my_biotype_colors_df <- read.table(my_biotype_colors_file, sep = "\t", h = T)



colr_map <- unique(my_biotype_colors_df[,c("Gene_biotype.v2", "Colors", "ColorsName")])
colors_4_biotypes <- paste("#", colr_map$Colors, sep = "")
names(colors_4_biotypes) <- colr_map$Gene_biotype.v2

colScale_4biotypes <- scale_colour_manual(name = "Gene_biotype", values = colors_4_biotypes)



####-------------------------------------------------------
### actual data
work_dir <- "path_to_appropriate_folder/exp_01.walbb_elutions/04.featureCounts_on_normReads";
work_dir <- paste(work_dir, "out_featureCounts.walbb.exp_01", sep = "/");
setwd(work_dir);

in_file <- "merged_featureCounts.walbb.exp_01.tsv"
mydf <- read.table(in_file, sep = "\t", h = T)
## add a pseudocount of 1 iin case log-scale is needed later???
mydf$CPMpc <- mydf$CPM + 1

mydf <- merge(mydf, treatments_df, by = "Sample", all.x = T)


mydf <- merge(mydf, gene2biotypes, by.x = "Geneid", by.y = "Geneid", all.x = T)

( plot1 <- ggplot(data = mydf, aes(fill=Gene_biotype, y=CPM, x=Treatment)) + 
     geom_bar(position="stack", stat="identity") + 
#      ggtitle("CPMs by Gene_biotype") + 
     theme_bw() + 
     scale_fill_manual(values = colors_4_biotypes) + 
     labs(x = "Treatments", y = "Counts per Million wAlbB reads, by gene biotype")

)



## trying out new shades of green for wAlbB rRNA to make it much lighter than protein-coding green
# new4biotype_colors <- colors_4_biotypes;

# newgreen <- "41CC38"
# newgreen <- "49E63F"
# newgreen <- "51ff46"
# 
# newgreen_hash <- paste("#", newgreen, sep = "")
# new4biotype_colors["rRNA"] <- newgreen_hash
# 
# filename <- paste("2b.newcolor-walbb-", newgreen, sep = "")
# filename <- paste(filename, "tiff", sep = ".")
# 
# (	plotnew <- plot1 + scale_fill_manual(values = new4biotype_colors) + ggtitle(newgreen_hash) )
# tiff(filename); print(plotnew); dev.off()
# 


(plot1 <- plot1 +      
	theme(
	legend.position = "bottom", 
	axis.title = element_text(size = 12), 
	axis.text  = element_text(size = 12), 
	axis.ticks = element_line(linewidth = 0.5),
	legend.background = element_rect(colour = "gray"),
	legend.title = element_blank()		)
)

pdf("Fig-1B.exp_01.pdf", width = 3.4, height = 5.5)
print(plot1)
dev.off()

# 
# tiff("Fig-1B.walbb.featureCounts_by_geneBiotypes.tiff", width = 3.4, height = 6.8, units = "in", res=300)
# print(plot1)
# dev.off()
# 
# tiff("x.tiff", width = 3.4, height = 6.8, units = "in", res=300)
# print(x)
# dev.off()
# 
# png("Fig-1B.walbb.featureCounts_by_geneBiotypes.png", h = 6, w= 6, units = "in", res=200)
# print(plot1)
# dev.off()
# 
# plot1 +   theme(axis.text.x = element_text(angle = 45, hjust = 1)) + 
# 
# # (plot2 <- ggplot(mydf, aes(fill=Gene_biotype, y=CPMpc, x=Sample)) + 
# #      geom_bar(position="dodge", stat="identity") + 
# #      ggtitle("RPMs by Gene_biotype") + 
# #      theme_bw() + 
# #      theme(axis.text.x = element_text(angle = 45, hjust = 1))
# # )
# # 
# # (plot2 <- plot2 + scale_y_log10())
# 

(plot1b <- plot1 +  scale_fill_manual(values = colors_4_biotypes) )

