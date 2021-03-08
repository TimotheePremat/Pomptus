#Timothée Premat | 08/03/2021
#Script to print plots based on PAM (Poggio & Premat, 2019)* analysis results
    ## Poggio, Enzo & Timothée Premat, "Le PAM, un Programme d'Analyse Métrique pour le français médiéval"[= PAM: a software for analysis of medieval French metrics], in : Actes des Rencontres lyonnaises des jeunes chercheurs en linguistique historique, under the dir. of Timothée Premat & Ariane Pinche, Lyon : Diachronies contemporaines, 2019, pp. 59-70. ⟨https://hal.archives-ouvertes.fr/hal-02320550⟩ ⟨10.5281/zenodo.3464477⟩

#If needed, install packages. Uncomment the ones needed.
    #install.packages(scales)
    #install.packages(tidyverse)
    #install.packages(readxl)
    #install.packages(ggpubr)
    #install.packages(ggrepel)
    #install.packages(Hmisc)

#Load packages
library(scales)
library(tidyverse)
library(readxl)
library(ggpubr)
library(ggrepel)
library(Hmisc)
library(moments)

#Set directory
setwd("~/Documents/GitHub/Promptus/roland/roland_corr_elid")

##Import global data
        PAM_raw_xlsx <- read_excel("all.xlsx")
        PAM_raw_xlsx_non_corr <- read_excel("all_non_corr.xlsx")
    
    #First, let's apply some transformations to clean up and properly reorganize data!
    ##Moove columns
        PAM_raw_xlsx <- PAM_raw_xlsx %>% relocate(meter, ces_3, ces_4, ces_5, ces_6, ces_7)
        PAM_raw_xlsx_non_corr <- PAM_raw_xlsx_non_corr %>% relocate(meter, ces_3, ces_4, ces_5, ces_6, ces_7)
    
    ##Delete uneven lines (which contains syllables and not tags)
        toDelete <- seq(1, nrow(PAM_raw_xlsx), 2)
        PAM_tag <- PAM_raw_xlsx[ toDelete ,]
        toDelete <- seq(1, nrow(PAM_raw_xlsx_non_corr), 2)
        PAM_tag_non_corr <- PAM_raw_xlsx_non_corr[ toDelete ,]

    ##Delete empty columns (xlsx export from PAM creates extra columns to be sure to be large enough for big too-long lines) (would also delete unused -1 (elided schwa) columns, but it shouldn't have any consequences and should be very rare, if existing)
        PAM_tag <- PAM_tag[,colSums(is.na(PAM_tag))<nrow(PAM_tag)]
        PAM_tag_non_corr <- PAM_tag_non_corr[,colSums(is.na(PAM_tag_non_corr))<nrow(PAM_tag_non_corr)]

        #Reduce meter==11 to meter==10 when 4épC or 6épC detected
        PAM_tag_epC <- PAM_tag %>%
            mutate(meter=replace(meter, ces_4=="4épC" & meter==11, 10)) %>%
            as.data.frame()
        PAM_tag_epC <- PAM_tag_epC %>%
            mutate(meter=replace(meter, ces_6=="6épC" & meter==11, 10)) %>%
            as.data.frame()

        PAM_tag_epC_non_corr <- PAM_tag_non_corr %>%
            mutate(meter=replace(meter, ces_4=="4épC" & meter==11, 10)) %>%
            as.data.frame()
        PAM_tag_epC_non_corr <- PAM_tag_epC_non_corr %>%
            mutate(meter=replace(meter, ces_6=="6épC" & meter==11, 10)) %>%
            as.data.frame()


#PLOT IT!
    #Merge df from corrected and non corrected texts
    data_both <- rbind(PAM_tag_epC,PAM_tag_epC_non_corr)

##DISTRIB_lines = barplot of each type of m:n[x]
DISTRIB_lines <- ggplot(PAM_tag_epC, aes(meter)) + geom_bar() +
    geom_text(stat='count', aes(label=..count..), vjust=-0.5) +
    ###Good looking parameters
    labs(
      x="Number of metrified syllables",
      y="Number of lines (squared log.)",
      title = "Distribution of line lenght*",
      caption = "*metrified syllables only")+
    theme_classic() +
    coord_trans(y='sqrt') +
    scale_x_continuous(breaks=c(7,8,9,10,11,12,13,14,15)) +
    scale_y_continuous(breaks=c(5,10,50,150,1000,4000))

DISTRIB_lines_non_corr <- ggplot(PAM_tag_epC_non_corr, aes(meter)) + geom_bar() +
    geom_text(stat='count', aes(label=..count..), vjust=-0.5) +
    ###Good looking parameters
    labs(
      x="Number of metrified syllables",
      y="Number of lines (squared log.)",
      title = "Distribution of line lenght*",
      caption = "*metrified syllables only")+
    theme_classic() +
    coord_trans(y='sqrt') +
    scale_x_continuous(breaks=c(7,8,9,10,11,12,13,14,15)) +
    scale_y_continuous(breaks=c(5,10,50,150,1000,4000))

DISTRIB_lines_both <- ggplot(mapping=aes(x=meter)) +
    geom_bar(data=PAM_tag_epC_non_corr,aes(x=meter-0.2), fill="grey40",color="white", width=0.4) +
    geom_bar(data=PAM_tag_epC,aes(x=meter+0.2) , fill="grey20",color="white", width=0.4) +
geom_text(data=PAM_tag_epC, stat='count', aes(label=..count..), vjust=-0.5, hjust=-0.5, color="grey20") +
geom_text(data=PAM_tag_epC_non_corr, stat='count', aes(label=..count..), vjust=-0.5, hjust=1.5, color="grey40") +
    labs(
      x="Number of metrified syllables",
      y="Number of lines (squared log.)",
      title = "Distribution of line lenght*",
      caption = "*metrified syllables only; **for line-type ≠ 10 only") +
    theme_classic() +
    coord_trans(y='sqrt') +
    scale_x_continuous(breaks=c(7,8,9,10,11,12,13,14,15)) +
    scale_y_continuous(breaks=c(5,10,50,150,1000,4000)) +
    annotate("text", x = 13.5, y = 3000, label = "With normal elisions, \u03B31 = -0.65**") +
    annotate("rect", xmin = 11.75, xmax=12.2, ymin= 2900, ymax=3100, fill="grey40") +
    annotate("text", x = 13.5, y = 2800, label = "With custom elisions, \u03B31 = -0.50**") +
    annotate("rect", xmin = 11.75, xmax=12.2, ymin= 2700, ymax=2900, fill="grey20")


##STATS = calculate and print general results as the PAM but with comprehension of 4épC and 6épC
PAM_md <- PAM_tag_epC %>%
    group_by(meter) %>%
    summarise(count = n()) %>%
    mutate(rate=sprintf("%0.2f", count/sum(count)*100))

knitr::kable(PAM_md, "pipe", align = "lrr")
knitr::kable(PAM_md, format = "latex", align = "lrr")

#PRINT IT!
##Uncomment the plot you want to print. Leave all uncommented to print all plots.

DISTRIB_lines_both
    ggsave(DISTRIB_lines_both, filename = "distrib_meter_both.png", width=25, height=20.13, units="cm", scale=1, dpi="retina")
#DISTRIB_lines_non_corr

#Skewness
PAM_tag_epC_filtered <- filter(PAM_tag_epC, meter == 7 | meter == 8 | meter == 9 | meter == 11 | meter == 12 | meter == 13| meter == 14 | meter == 15)
PAM_tag_epC_non_corr_filtered <- filter(PAM_tag_epC_non_corr, meter == 7 | meter == 8 | meter == 9 | meter == 11 | meter == 12 | meter == 13 | meter == 14 | meter == 15)

linetype_corr <- PAM_tag_epC_filtered$meter
linetype_noncorr <- PAM_tag_epC_non_corr_filtered$meter

skewness(linetype_corr)
skewness(linetype_noncorr)
