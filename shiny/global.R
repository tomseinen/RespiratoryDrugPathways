library(shiny)
library(shinydashboard)
library(DT)
library(plotly)
library(dplyr)
library(tidyr)
library(scales)
library(ggiraph)
library(reshape2)
library(data.table)
library(shinymanager)
library(magrittr)
library(ggplot2)

# Set working directory
setwd(stringr::str_replace(getwd(),"/shiny",""))
addResourcePath("workingdirectory", getwd())

# Fixing the labels
all_years <- list("Entire study period" = "all", 
                  "Index year 2010" = "2010",
                  "Index year 2011" = "2011",
                  "Index year 2012" = "2012",
                  "Index year 2013" =  "2013",
                  "Index year 2014" = "2014", 
                  "Index year 2015" = "2015",
                  "Index year 2016" = "2016",
                  "Index year 2017" = "2017")

all_populations <- list("Asthma > 18"= "asthma",
                        "COPD > 40" = "copd",
                        "ACO > 40" = "aco",
                        "Asthma 6-17" = "asthma6plus",
                        "Asthma < 5" = "asthma6min")

included_databases <- list("IPCI" = "IPCI",
                           "CPRD" = "CPRD",
                           "CCAE" = "ccae",
                           "MDCD" = "mdcd",
                           "MDCR" = "mdcr",
                           "AUSOM" = "AUSOM",
                           "EHIF" = "Asthma")

# Set colors
colors <- list("stopped" = "#EBDEF0", # purple
               "step_up" = "#FADBD8", # red
               "undefined" = "#E5E8E8", # grey
               "step_down" = "#D5F5E3", # green
               "switching" = "#FCF3CF", # yellow
               "acute_exacerbation" = "#FAE5D3", # orange
               "end_of_acute_exacerbation" = "#D6EAF8") # blue

# Order characterization (alphabetic with some exceptions)
orderRows <- c("Number of persons", "Male" , "Age", "Charlson comorbidity index score",  "Anxiety", "Atopic disorders",
               "Allergic rhinitis", "Cerebrovascular disease",  "Chronic rhinosinusitis" , "Depressive disorder", "Diabetes mellitus", "Gastroesophageal reflux disease" ,  
                "Heartfailure", "Hypertensive disorder", "Ischemic heart disease" , "Lower respiratory tract infections",
                 "Nasal polyposis", "Obesity"  )   

characterization <- list()
stepupdown <- list()
summary_counts <- list()
summary_drugclasses <- list()
summary_drugclasses_year <- list()

for (d in included_databases) {
  
  # Load characterization for entire database
  characterization[[d]]  <- read.csv(paste0(stringr::str_replace(getwd(),"/shiny",""), "/output/", d, "/characterization/characterization.csv"))
  
  # Load remaining file per study population
  stepupdown_d <- list()
  summary_counts_d <- list()
  summary_drugclasses_d <- list()
  summary_drugclasses_year_d <- list()
  
  for (p in c(all_populations, paste0(all_populations, "_inhaler"))) {
    # Load step up/down file for available study populations
    try(stepupdown_d[[p]] <- read.csv(paste0(stringr::str_replace(getwd(),"/shiny",""), "/output/", d, "/", p, "/",d , "_", p, "_augmentswitch.csv"))) 
    
    # Load summary counts
    try({
    file <- read.csv(paste0(stringr::str_replace(getwd(),"/shiny",""), "/output/", d, "/", p, "/",d , "_", p, "_summary_cnt.csv"))
    transformed_file <- data.table(year = character(), number_target = integer(), number_pathways = integer())
    transformed_file <- rbind(transformed_file, list("all", file$NUM_PERSONS[file$COUNT_TYPE == "Number of persons in target cohort"], file$NUM_PERSONS[file$COUNT_TYPE == "Total number of pathways (after minCellCount)"]))
    
    for (y in all_years[-c(1)]) {
      try(transformed_file <- rbind(transformed_file, list(y, file$NUM_PERSONS[file$COUNT_TYPE == paste0("Number of persons in target cohort in ", y)], file$NUM_PERSONS[file$COUNT_TYPE == paste0("Number of pathways (after minCellCount) in ", y)])))
    }
    
    transformed_file$perc <- round(transformed_file$number_pathways * 100.0 / transformed_file$number_target,1)
    summary_counts_d[[p]] <- transformed_file})
    
    # Load summary classes file for available study populations
    try(summary_drugclasses_d[[p]] <- read.csv(paste0(stringr::str_replace(getwd(),"/shiny",""), "/output/", d, "/", p, "/",d , "_", p, "_percentage_groups_treated_noyear.csv"))) 
    try(summary_drugclasses_year_d[[p]] <- read.csv(paste0(stringr::str_replace(getwd(),"/shiny",""), "/output/", d, "/", p, "/",d , "_", p, "_percentage_groups_treated_withyear.csv"))) 
  }
  
  try(stepupdown[[d]] <- stepupdown_d)
  try(summary_counts[[d]] <- summary_counts_d)
  try(summary_drugclasses[[d]] <- summary_drugclasses_d)
  try(summary_drugclasses_year[[d]] <- summary_drugclasses_year_d)
}

writeLines("Data Loaded")

