#!/bin/env R
## color palettes : https://ipalettes.com/palette/ggplot-891

rm(list = ls())

## idxstats data has been merged using my perl script
## Plot it now
library(ggplot2)
library(rcartocolor)
library(patchwork)
library(plotly)
library(htmlwidgets)

####----------- SETWD ----------------------
work_dir <- "path_to_appropriate_folder";
# work_dir <- paste(work_dir, "results.exp-03", sep = "/");
setwd(work_dir);

####---------- SETUPS ----------------------
## metadata
metadata_folder <- "path_to_appropriate_folder"

chr2source_filepath <- paste(metadata_folder, "aa23_walbb_5viruses.ref_genomes.v6.accessions_to_source_species.metadata.V20260408.tsv", sep = "/");
chr2source <- read.table(chr2source_filepath, sep = "\t", h = T)

unique(chr2source$Source)
	# [1] "wAlbB"          "Mosquito_mtDNA" "Unmapped_bin"   "Virus_ssRNA"    "Mosquito_gDNA" 

treatments_metadata_file <- paste(metadata_folder, "table.sample_treatmentNames.v2.tsv", sep = "/")
treatments_df <- read.table(treatments_metadata_file, sep = "\t", h = T)

####------------- Setup colors ----------------------------
## todo
# 	### LOOKUP colors
# 	library(plotrix)
# 	sapply(rainbow(4), color.id)
# 	source_pal <- c(Mosquito_gDNA = "#4472c4", Mosquito_mtDNA = "#56B4E9", wAlbB = "#00b050", Unmapped_bin="grey")
# 	install.packages('gplots')
# 	col2hex("gray")
# 	library(scales)
# 	hue_pal()(5)
# 	sapply(hue_pal()(5), color.id)
# 	#         #F8766D         #A3A500         #00BF7D         #00B0F6         #E76BF3 
# 	#        "salmon"       "yellow4"  "springgreen3"  "deepskyblue2" "mediumorchid1" 


my_chr2source_colors_file <- paste(metadata_folder, "metadata.colors_for_chromosome2species_source.v20260408.tsv", sep = "/");
my_chr2source_colors_df <- read.table(my_chr2source_colors_file, sep = "\t", h = T)
my_chr2source_colors_df$color_hex <- paste("#", my_chr2source_colors_df$Color_hexcode_addHASH, sep = "")
# colr_map <- unique(my_chr2source_colors_df[,c("Gene_biotype.v2", "Colors", "ColorsName")])

colors_5_sourceTypes <- my_chr2source_colors_df$color_hex
names(colors_5_sourceTypes) <- my_chr2source_colors_df$Source_original

# sapply(colors_5_sourceTypes, color.id)
# $Mosquito_gDNA
# [1] "steelblue"
# 
# $Mosquito_mtDNA
# [1] "steelblue2"
# 
# $Unmapped_bin
# [1] "gray" "grey"
# 
# $Virus_ssRNA
# [1] "salmon"
# 
# $wAlbB
# [1] "springgreen3"

# colScale_4biotypes <- scale_colour_manual(name = "Gene_biotype", values = colors_4_biotypes)


####--------------------------------------------------------
### actual data
in_file <- "merged_idxstats.exp_01.tsv"
mydf <- read.table(in_file, sep = "\t", h = T)

mydf <- merge(mydf, treatments_df, by.x = "sample_name", by.y = "Sample", all.x = T)
mydf <- merge(mydf, chr2source, by.x = "chromosome", by.y = "chromosome", all.x = T)


( plot1 <- ggplot(mydf, aes(fill=Source, y=RPM, x=Treatment)) + 
     geom_bar(position="stack", stat="identity") + 
#      ggtitle("RPMs by source species") + 
     theme_bw() + 
     scale_fill_manual(values = colors_5_sourceTypes) +
     labs(x = "Treatments", y = "Reads per Million, by Species")
)

# new5colors <- colors_5_sourceTypes;
# 
# newgreen <- "41CC38"
# newgreen <- "49E63F"
# newgreen <- "51ff46"
# 
# newgreen_hash <- paste("#", newgreen, sep = "")
# new5colors["wAlbB"] <- newgreen_hash
# 
# filename <- paste("1a.newcolor-walbb-", newgreen, sep = "")
# filename <- paste(filename, "pdf", sep = ".")
# 
# (	plotnew <- plot1 + scale_fill_manual(values = new5colors) + ggtitle(newgreen_hash) )
# pdf(filename); print(plotnew); dev.off()
# 

## Choose #41CC38 as the new wAlbB color

(plot1 <- plot1 +      
	theme(
	legend.position = "bottom", 
	axis.title  = element_text(size = 12), 
	axis.text  = element_text(size = 12), 
	axis.ticks = element_line(linewidth = 0.5),
	legend.background = element_rect(colour = "gray"),
	legend.title = element_blank()
	)	
)
# 	axis.text.x = element_text(angle = 45, hjust = 1)

# pdf("fig_idxstats.exp-03.pdf", w = 3.4, h = 5.5)
pdf("Fig_1A.exp_01.pdf", w = 3.4, h = 5.5)
print(plot1)
dev.off()


# tiff("Fig_1A.exp_01.tiff", w = 3.4, h = 5.5, units = "in", res = 300)
# print(plot1)
# dev.off()

# tiff("fig_idxstats.exp-03.tiff", w = 3.6, h= 5.8, units = "in", res = 300)
# print(plot1)
# dev.off()
# 
# 
# png("fig_idxstats.exp-03.200dpi.png", h = 6, w= 9, units = "in", res = 200)
# print(plot1)
# dev.off()
# 
##----------
## Just the viruses
iViruses <- mydf$Source == "Virus_ssRNA"
## Drop the Aedes_flavivirus : Not present in our samples!!!
iDrop <- mydf$Species != "Aedes_flavivirus__plus_ssRNA"
myviruses <- mydf[iViruses & iDrop,]


( plot2 <- ggplot(myviruses, aes(fill=Source, y=RPM, x=Treatment)) + 
     geom_bar(position="stack", stat="identity") + 
#      ggtitle("RPMs by virus species") + 
     theme_bw() + 
     scale_fill_manual(values = colors_5_sourceTypes) 
)

(plot2 <- plot2 +      
	theme(
	legend.position = "bottom", 
	axis.title  = element_text(size = 12), 
	axis.text  = element_text(size = 12), 
	axis.ticks = element_line(linewidth = 0.5),
	legend.background = element_rect(colour = "gray"),
	legend.title = element_blank()
	)	
)

# (plot2 <- plot2 + 
# 	theme(axis.text.x = element_text(angle = 45, hjust = 1))
# )	
# 
# 
# pdf("fig_idxstats.viruses.pdf")
# print(plot2)
# dev.off()
# 
# 
# tiff("fig_idxstats.viruses.200dpi.tiff", h = 6, w= 9, units = "in", res = 200)
# print(plot2)
# dev.off()
# 
# png("fig_idxstats.viruses.200dpi.png", h = 6, w= 9, units = "in", res = 200)
# print(plot2)
# dev.off()


###--- color by virus species


###---- https://r-statistics.co/ggplot2-Colours.html
library(plotrix)
colors12x <- brewer.pal(5, "Set3")
colors5viruses <- brewer.pal(5, "Dark2")

pie(rep(1, length(colors5viruses)), col = colors5viruses , main="colors5viruses") 

colors5viruses_idlist <- sapply(colors5viruses , plotrix::color.id)
mycolors_viruses <- read.table("colrs.5viruses.metadata.tsv", sep = "\t", h = T)
mycolors_viruses$color_hex_with_hashSign <- paste("#", mycolors_viruses$ColorHex, sep = "")

mycolors_viruses_scale <- mycolors_viruses$color_hex_with_hashSign
names(mycolors_viruses_scale) <- mycolors_viruses$Species
mycolors_viruses_scale
#    BK059423_SanGabriel_mononegavirus            BK059489_Tombus_like_seg1 
#                            "#1B9E77"                            "#E7298A" 
#            BK059490_Tombus_like_seg2 MK879803_Aedes_albopictus_negev_like 
#                            "#D95F02"                            "#7570B3" 
#                  MW147277_Anphevirus 
#                            "#66A61E" 



###########

( plot3 <- ggplot(myviruses, aes(fill=Species, y=RPM, x=Treatment)) + 
     geom_bar(position="stack", stat="identity") + 
#      ggtitle("RPMs by virus species") + 
     theme_bw() +
     scale_fill_manual(values = mycolors_viruses_scale) + 
     labs(x = "Treatments", y = "Reads per Million, ssRNA Viruses")
)


(plot3 <- plot3 +      
	theme(
	legend.position = "bottom", 
	axis.title  = element_text(size = 12), 
	axis.text  = element_text(size = 12), 
	axis.ticks = element_line(linewidth = 0.5),
	legend.background = element_rect(colour = "gray"),
	legend.title = element_blank()
	)	
)


# pdf("Fig_viruses.exp_01.pdf", w = 3.3, h = 7.1) # width 3.3 for single-panel figure
pdf("Fig_viruses.exp_01.pdf", w = 3.3, h = 5.5) # width 3.3 for single-panel figure
print(plot3)
dev.off()


#### Normalize within viruses?????
my_agg <- aggregate(x = myviruses, RPM ~ Treatment + Species, FUN = sum)


