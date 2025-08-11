#SBE NATIONAL SECURITY DATA PULL


library(readxl)
library(writexl)
library(dplyr)
library(tidyverse)
library(odbc)
library(DT)
library(RColorBrewer)
library(ggforce)

##########PULLING SQL DATA###########

#PULLED FROM NSF DATA SYSTEMS
SBEBiotech<- read_excel("C:/Users/dagboh/OneDrive - National Science Foundation/Documents/Data/National Security Task for Lee/Biotech/SBE_Biotech_Projects.xlsx", skip=2)

SBEBiotech$`Fiscal Year Number`[grepl("^20", as.character(SBEBiotech$`Proposal ID`))] <- 2020

SBEBiotech$`Fiscal Year Number`[grepl("^21", as.character(SBEBiotech$`Proposal ID`))] <- 2021

SBEBiotech$`Fiscal Year Number`[grepl("^22", as.character(SBEBiotech$`Proposal ID`))] <- 2022

SBEBiotech$`Fiscal Year Number`[grepl("^23", as.character(SBEBiotech$`Proposal ID`))] <- 2023

SBEBiotech$`Fiscal Year Number`[grepl("^24", as.character(SBEBiotech$`Proposal ID`))] <- 2024

SBEBiotech$`Fiscal Year Number`[grepl("^25", as.character(SBEBiotech$`Proposal ID`))] <- 2025


#RENAME VARIABLES

SBEBiotech <- rename(SBEBiotech, "race" = "PI Race")
SBEBiotech <- rename(SBEBiotech, "gender" = "PI Gender")
SBEBiotech <- rename(SBEBiotech, "ethnicity" = "PI Ethnicity")
SBEBiotech <- rename(SBEBiotech, "disability" = "PI Disability Code")
SBEBiotech <- rename(SBEBiotech, "prop_id" = "Proposal ID")
SBEBiotech <- rename(SBEBiotech, "ERI" = "ERI Category")
SBEBiotech <- rename(SBEBiotech, "NewAwardee" = "New Awardee Flag")
SBEBiotech <- rename(SBEBiotech, "prop_status" = "Proposal Status Description")
SBEBiotech <- rename(SBEBiotech, "inst_id" = "Institution Identifer")
SBEBiotech <- rename(SBEBiotech, "awdamount" = "Total Intended Award Amount (Original from Awards)")
SBEBiotech <- rename(SBEBiotech, "rqstamount" = "Request Amount")
SBEBiotech <- rename(SBEBiotech, "division" = "NSF Division Abbreviation Name")
SBEBiotech <- rename(SBEBiotech, "year" = "Fiscal Year Number")
SBEBiotech <- rename(SBEBiotech, "ZIP" = "PI Zip Code")
SBEBiotech <- rename(SBEBiotech, "st_code" = "PI State Code")
SBEBiotech <- rename(SBEBiotech, "program" = "Program Element Name")

#SQL ATTEMPT PULLED WRONG DATA.

#library(DBI)
#con <- dbConnect(odbc::odbc(), dsn = "DataLakeHouse", uid = "dagboh@AD.NSF.GOV", 
#                 timeout = 10)

#SBE_Security <-"SELECT org.dir_div_abbr as division, 
#pec.pgm_ele_name as program, 
#awd.awd_titl_txt as title, 
#prop.prop_id as prop_id,
#prop.inst_id as inst_id,
#impact.society AS impact_on_society, 
#pr.sub_date as submission_date, 
#pr.rpt_peri_end as reporting_end_date, 
#case pr.rpt_type when 'A' then 'Annual Report' when 'F' then 'Final Annual Report' when 'I' then 'Interim' end as Type, 
#awd.awd_id as Awd_ID,
#awd.pgm_ele_code as Pgm_Code,
#awd.org_code as Org_Code,
#awd.tot_intn_awd_amt as AwdAmount,
#ucu.sign_blck_name AS PO, 
#pi_dmog_vw.pi_gend_desc as Gender,
#pi_dmog_vw.pi_ethn_desc as Ethnicity,
#pi_dmog_vw.pi_race_desc as Race,
#inst.hbcu_flag as HBCU,
#inst.hisp_serv_flag as HSI,
#inst.trbl_col_flag as TribalCollege,
#inst.disab_serv_flag as DisablCollege,
#nst.majr_minr_flag as MajorMinorityCollege,
#pi.pi_frst_name || ' ' || pi.pi_last_name as PI, 
#inst.inst_name as Org 
#FROM rppr.impact impact left join rptdb.awd awd on impact.awd_id = awd.awd_id 
#left join rptdb.prop prop on impact.awd_id = prop.prop_id 
#left join flflp.pr_cntl pr on impact.doc_id = pr.doc_id 
#left join rptdb.pgm_ele pec on pec.pgm_ele_code = awd.pgm_ele_code 
#left join rptdb.org org on org.org_code = awd.org_code 
#left join rptdb.upm_cmn_user ucu on ucu.ibm_logn_id = TRIM(awd.pm_ibm_logn_id) 
#left join rptdb.pi pi on pi.pi_id = awd.pi_id 
#left join rptdb.pi_dmog_vw on pi.pi_id = pi_dmog_vw.pi_id
#left join rptdb.inst inst on inst.inst_id = awd.perf_inst_id 
#WHERE pr.sub_date >= '2020-05-01 00:00:00' and pr.sub_date <= '2025-07-13 23:59:59' and awd.org_code like '04%' and ( impact.society like '%foreign policy%' or impact.society like '%security%' or impact.society like '%conflict%' or impact.society like '%interstate war%' or impact.society like '%intrastate war%' or impact.society like '%dispute resolution%' or impact.society like '%peace studies%' or impact.society like '%peace science%' or impact.society like '%cybersecurity%' or impact.society like '%treaty %' or impact.society like '%treaties%' ) 
#ORDER by division asc, program asc limit 2025-07-13"

#SBEBiotech <- dbGetQuery(con,SBE_Security) %>% 
#  mutate(across(where(is.character),str_trim))

#ADD CARNEGIE CLASSIFICATIONS

carnegie_crosswalk <- read_excel("C:/Users/dagboh/OneDrive - National Science Foundation/Documents/COE/Outreach/Reviewer Analyses/Excel Files/carnegie_crosswalk.xlsx")

carnegie_crosswalk <- rename(carnegie_crosswalk,"inst_id" = "NSF Institution ID")

SBEBiotech <-  left_join(SBEBiotech, carnegie_crosswalk, by = "inst_id")

write.csv(SBEBiotech, "C:/Users/dagboh/OneDrive - National Science Foundation/Documents/Data/National Security Task for Lee/Biotech/SBEBiotech_FullData.csv")

##########CLEAN DATA###########

## Fixing Carnegie Variables
SBEBiotech <- SBEBiotech %>%
  mutate(MSI = case_when(
    `Historically Black College or University` == "Yes" ~ "HBCU" ,
    `Hispanic Serving Institution` == "Yes" ~ "HSI",
    `Minority Serving Institution` == "Yes" ~ "Other MSI",
    is.na(IPEDS_ID) ~ "Not an IHE*"
  ))

#Create/clean MSI variables

SBEBiotech$MSI[is.na(SBEBiotech$MSI)] <- "Not an MSI"
SBEBiotech$`2018 Carnegie Basic Classification`[is.na(SBEBiotech$`2018 Carnegie Basic Classification`)] <- "Not an IHE*"

SBEBiotech$MSI_Broad <- SBEBiotech$MSI
SBEBiotech$MSI_Broad[SBEBiotech$MSI_Broad %in% c("HBCU","HSI","Other MSI")] <- "MSI"

SBEBiotech$MSI <- fct_relevel(SBEBiotech$MSI, c("Not an IHE*","Not an MSI","Other MSI","HSI","HBCU"))

#Cleam demographic variables
SBEBiotech$race[SBEBiotech$race == "U"] <- "Unknown"

SBEBiotech$ethnicity[is.na(SBEBiotech$ethnicity)] <- "Unknown"

SBEBiotech$gender[is.na(SBEBiotech$gender)] <- "Unknown"

SBEBiotech <- SBEBiotech %>%
  mutate(gender = recode(gender,
                         "M" = "Male",
                         "F" = "Female",
                         "U" = "Unknown",
                         "X" = "Do not wish to provide"))

SBEBiotech <- SBEBiotech %>%
  mutate(disability = recode(disability,
                             "Y" = "Yes",
                             "N" = "No",
                             "U" = "Unknown",
                             "X" = "Do not wish to provide"))

SBEBiotech$race[!SBEBiotech$race %in% c("Asian","Black or African American","Do not wish to provide","Unknown","White")] <- "Two or more"

SBEBiotech$year <- as.numeric(as.character(SBEBiotech$year))

SBEBiotech <- SBEBiotech %>%
  mutate(WhiteNonWhite = case_when(race == "White" ~ "White",
                                   race != "White" ~ "Non-White"))

##########SBE TOTAL DATASET##########

SBETotal<- read_excel("C:/Users/dagboh/OneDrive - National Science Foundation/Documents/Data/National Security Task for Lee/SBE_ERI_Data_2020-2025.xlsx", skip=2)

SBETotal$`Fiscal Year Number`[grepl("^20", as.character(SBETotal$`Proposal ID`))] <- 2020

SBETotal$`Fiscal Year Number`[grepl("^21", as.character(SBETotal$`Proposal ID`))] <- 2021

SBETotal$`Fiscal Year Number`[grepl("^22", as.character(SBETotal$`Proposal ID`))] <- 2022

SBETotal$`Fiscal Year Number`[grepl("^23", as.character(SBETotal$`Proposal ID`))] <- 2023

SBETotal$`Fiscal Year Number`[grepl("^24", as.character(SBETotal$`Proposal ID`))] <- 2024

SBETotal$`Fiscal Year Number`[grepl("^25", as.character(SBETotal$`Proposal ID`))] <- 2025


#RENAME VARIABLES

SBETotal <- rename(SBETotal, "race" = "PI Race")
SBETotal <- rename(SBETotal, "gender" = "PI Gender")
SBETotal <- rename(SBETotal, "ethnicity" = "PI Ethnicity")
SBETotal <- rename(SBETotal, "disability" = "PI Disability Code")
SBETotal <- rename(SBETotal, "prop_id" = "Proposal ID")
SBETotal <- rename(SBETotal, "ERI" = "ERI Category")
SBETotal <- rename(SBETotal, "NewAwardee" = "New Awardee Flag")
SBETotal <- rename(SBETotal, "prop_status" = "Proposal Status Description")
SBETotal <- rename(SBETotal, "inst_id" = "Institution Identifer")
SBETotal <- rename(SBETotal, "awdamount" = "Total Intended Award Amount (Original from Awards)")
SBETotal <- rename(SBETotal, "rqstamount" = "Request Amount")
SBETotal <- rename(SBETotal, "division" = "NSF Division Abbreviation Name")
SBETotal <- rename(SBETotal, "year" = "Fiscal Year Number")
SBETotal <- rename(SBETotal, "ZIP" = "PI Zip Code")
SBETotal <- rename(SBETotal, "st_code" = "PI State Code")
SBETotal <- rename(SBETotal, "program" = "Program Element Name")

SBETotal <-  left_join(SBETotal, carnegie_crosswalk, by = "inst_id")

##########CLEAN DATA###########

## Fixing Carnegie Variables
SBETotal <- SBETotal %>%
  mutate(MSI = case_when(
    `Historically Black College or University` == "Yes" ~ "HBCU" ,
    `Hispanic Serving Institution` == "Yes" ~ "HSI",
    `Minority Serving Institution` == "Yes" ~ "Other MSI",
    is.na(IPEDS_ID) ~ "Not an IHE*"
  ))

#Create/clean MSI variables

SBETotal$MSI[is.na(SBETotal$MSI)] <- "Not an MSI"
SBETotal$`2018 Carnegie Basic Classification`[is.na(SBETotal$`2018 Carnegie Basic Classification`)] <- "Not an IHE*"

SBETotal$MSI_Broad <- SBETotal$MSI
SBETotal$MSI_Broad[SBETotal$MSI_Broad %in% c("HBCU","HSI","Other MSI")] <- "MSI"

SBETotal$MSI <- fct_relevel(SBETotal$MSI, c("Not an IHE*","Not an MSI","Other MSI","HSI","HBCU"))

#Cleam demographic variables
SBETotal$race[SBETotal$race == "U"] <- "Unknown"

SBETotal$ethnicity[is.na(SBETotal$ethnicity)] <- "Unknown"

SBETotal$gender[is.na(SBETotal$gender)] <- "Unknown"

SBETotal <- SBETotal %>%
  mutate(gender = recode(gender,
                         "M" = "Male",
                         "F" = "Female",
                         "U" = "Unknown",
                         "X" = "Do not wish to provide"))

SBETotal <- SBETotal %>%
  mutate(disability = recode(disability,
                             "Y" = "Yes",
                             "N" = "No",
                             "U" = "Unknown",
                             "X" = "Do not wish to provide"))

SBETotal$race[!SBETotal$race %in% c("Asian","Black or African American","Do not wish to provide","Unknown","White")] <- "Two or more"

SBETotal$year <- as.numeric(as.character(SBETotal$year))

SBETotal <- SBETotal %>%
  mutate(WhiteNonWhite = case_when(race == "White" ~ "White",
                                   race != "White" ~ "Non-White"))

#Create Color Palates

color_scale2 <- RColorBrewer::brewer.pal(n=7,"Dark2")

gend_colors <- c("Male" = color_scale2[1],
                 "Female" = color_scale2[2],
                 "Unknown" = "grey",
                 "Do not wish to provide" = color_scale2[7])

ethn_colors <- c("Hispanic or Latino" = color_scale2[1],
                 "Not Hispanic or Latino" = color_scale2[2],
                 "Unknown" = "grey",
                 "Do not wish to provide" = color_scale2[7])

race_colors <- c("Asian" = color_scale2[2],
                 "Black or African American" = color_scale2[3],
                 "White" = color_scale2[5],
                 "Two or more" = color_scale2[6],
                 "Unknown" = "grey",
                 "Do not wish to provide" = color_scale2[7])

ERI_colors <- c( "Unknown" = "grey",
                 "Non-Emerging Research Inst" = color_scale2[2],
                 "Emerging Research Inst" = color_scale2[1]) 

category_colors <- c("Biotech Only" = color_scale2[1],
                     "SBE Total" = color_scale2[2])

division_colors <- c( "NCSE" = color_scale2[4],
                      "SMA" = color_scale2[3],
                      "BCS" = color_scale2[2],
                      "SES" = color_scale2[1]) 

disab_colors <- c("Do not wish to provide" = color_scale2[7],
                  "Unknown" = "grey",
                  "No" = color_scale2[2],
                  "Yes" = color_scale2[1]) 

wnw_colors <- c("White" = color_scale2[2],
                "Non-White" = color_scale2[1])


#Order Variables

race_order <- c("Asian",
                "Black or African American",
                "White",
                "Two or more",
                "Unknown",
                "Do not wish to provide")

ethn_order <- c("Hispanic or Latino",
                "Not Hispanic or Latino",
                "Unknown",
                "Do not wish to provide")

gend_order <- c( "Female",
                 "Male",
                 "Unknown",
                 "Do not wish to provide")   

ERI_order <- c( "Unknown (n=4)",
                "Non-Emerging Research Inst (n=61)",
                "Emerging Research Inst (n=18)")  

division_order <- c("SES",
                    "BCS",
                    "SMA")  

disab_order <- c("Yes",
                 "No",
                 "Unknown",
                 "Do not wish to provide") 

###########MAKE TABLES##########

#Budget By Division

AwdAmount_by_Division <- SBEBiotech %>%
  group_by(`division`) %>%
  summarize(
    total_budget = sum(awdamount, na.rm = TRUE),
    avg_budget = mean(awdamount, na.rm = TRUE),
    n_projects = n()
  ) %>%
  arrange(desc(total_budget))


write.csv(AwdAmount_by_Division, "C:/Users/dagboh/OneDrive - National Science Foundation/Documents/Data/National Security Task for Lee/Biotech/SBEBiotech_AwdAmount_by_Division.csv")

AwdAmount_by_DivisionYear <- SBEBiotech %>%
  group_by(`division`, `year`) %>%
  summarize(
    total_budget = sum(awdamount, na.rm = TRUE),
    avg_budget = mean(awdamount, na.rm = TRUE),
    n_projects = n()
  ) %>%
  arrange(desc(total_budget))


write.csv(AwdAmount_by_DivisionYear, "C:/Users/dagboh/OneDrive - National Science Foundation/Documents/Data/National Security Task for Lee/Biotech/SBEBiotech_AwdAmount_by_DivisionYear.csv")


#Budget by Program

AwdAmount_by_Program <- SBEBiotech %>%
  group_by(`program`, `year`) %>%
  summarize(
    total_budget = sum(awdamount, na.rm = TRUE),
    avg_budget = mean(awdamount, na.rm = TRUE),
    n_projects = n()
  ) %>%
  arrange(desc(total_budget))

write.csv(AwdAmount_by_Program, "C:/Users/dagboh/OneDrive - National Science Foundation/Documents/Data/National Security Task for Lee/Biotech/SBEBiotech_AwdAmount_by_Program.csv")


#Budget by Year

AwdAmount_by_Year <- SBEBiotech %>%
  group_by(year) %>%
  summarize(total_budget = sum(awdamount, na.rm = TRUE),
            avg_budget = mean(awdamount, na.rm = TRUE),
            n_projects = n()) %>%
  arrange(year)

SBETotal_AwdAmount_by_Year <- SBETotal %>%
  group_by(year) %>%
  summarize(total_budget = sum(awdamount, na.rm = TRUE),
            avg_budget = mean(awdamount, na.rm = TRUE),
            n_projects = n()) %>%
  arrange(year)

AwdAmount_by_Year$Category <- "Biotech Only"

SBETotal_AwdAmount_by_Year$Category <- "SBE Total"

FullAwdAmount_by_Year <- full_join(AwdAmount_by_Year,SBETotal_AwdAmount_by_Year)

FullAwdAmount_by_Year <- FullAwdAmount_by_Year %>%
  group_by(year)%>%
  mutate(
    year_total = sum(total_budget),
    prop = total_budget / year_total
  ) %>%
  ungroup()

write.csv(FullAwdAmount_by_Year, "C:/Users/dagboh/OneDrive - National Science Foundation/Documents/Data/National Security Task for Lee/Biotech/SBEBiotech_FullAwdAmount_by_Year.csv")


##########PLOTS##########


#Award Amount by Year
library(ggplot2)
AwdAmount_by_Year_plot <- ggplot(FullAwdAmount_by_Year, aes(x = as.numeric(year), y = total_budget, fill = Category, color=Category)) +
  geom_bar(stat = "identity", position="dodge") +
  geom_smooth(method = "lm", se = FALSE, show.legend=FALSE) +
  scale_x_discrete(drop = FALSE) +
  labs(title = "SBE-Funded Biotech Projects (2020-2025): Total Award 
Amount by Year (n=525)",
       x = "Fiscal Year",
       y = "Total Award Amount",
       fill = "Biotech 
vs. SBE Total") +
  geom_label(aes(label = percent(prop, accuracy = 1)), vjust = 0.5, size = 2.5, fill = "white", alpha = 0.7) +
  scale_y_continuous(
    breaks = scales::pretty_breaks(n=10),
    labels = dollar
  )+
  scale_x_continuous(breaks = unique(AwdAmount_by_Year$year))+
  scale_fill_manual(values=category_colors)+
  scale_color_manual(values=category_colors)+
  geom_label(aes(label = dollar(total_budget)), vjust = -0.5, size = 2.5, fill = "white", alpha = 0.7) +
  theme_minimal()+
  guides(color= "none")

print(AwdAmount_by_Year_plot)
ggsave("C:/Users/dagboh/OneDrive - National Science Foundation/Documents/Data/National Security Task for Lee/Biotech/SBEBiotechAwards_byYear.png" ,width = 7, height = 4)

#Awd Amount by Year and#Awd Amount by Year and#Awd Amount by Year and Program
DivAwdAmount_by_Year_plot <- ggplot(AwdAmount_by_DivisionYear, aes(x = as.numeric(year), y = total_budget, color = division)) +
  geom_line(size=0.7)+
  geom_point(size=2) +
  scale_x_discrete(drop = FALSE) +
  labs(title = "SBE-Funded Biotech Projects (2020-2025): Total Award Amount 
by Division and Year (n=525)",
       x = "Fiscal Year",
       y = "Total Award Amount",
       color = "Division") +
  scale_y_continuous(
    breaks = scales::pretty_breaks(n=10),
    labels = dollar
  )+
  scale_x_continuous(breaks = unique(AwdAmount_by_Year$year))+
  geom_text(aes(label = dollar(total_budget)), vjust = -0.5, hjust = 0.5, size = 2.5)+
  theme_minimal()

print(DivAwdAmount_by_Year_plot)
ggsave("C:/Users/dagboh/OneDrive - National Science Foundation/Documents/Data/National Security Task for Lee/Biotech/SBEBiotechAwards_byDvsnYear.png" ,width = 7, height = 4)

###########EPSCOR MAP##########


# get and prep geospacial data
library(tigris)
library(sf)

options(tigris_use_cache = TRUE)


us_states <- states(cb = TRUE, resolution = "20m") %>%
  filter(!STUSPS %in% c("GU","AS","MP","VI")) %>%
  shift_geometry()

EPSCOR_states <- states(cb = TRUE, resolution = "20m") %>%
  filter(!STUSPS %in% c("GU","AS","MP","VI", "WA","OR","CA","AZ","UT","CO","TX","MN","MO","WI","IL","TN","IN","MI","OH","TN","GA","FL","NC","VA","DC","MD","PA","NJ","CT","NY","MA")) %>%
  shift_geometry()

props_by_state <- SBEBiotech %>%
  group_by(st_code) %>%
  summarise(count = n()) 

props_by_state$st_code <- trimws(props_by_state$st_code)

props_with_states <- geo_join(us_states,props_by_state,"STUSPS","st_code") %>%
  filter(!is.na(count)) %>%
  select(c(STUSPS,count,geometry)) %>%
  st_as_sf()

us_states <- st_as_sf(us_states)


# proposals map
ggplot() +
  geom_sf(data = us_states, fill = "white", color = "grey") +  
  geom_sf(data = props_with_states, aes(fill = count),color="grey") +  
  scale_fill_continuous(low = "#deebf7", high = "#3182bd") +
  geom_sf(data = EPSCOR_states, fill = "transparent", color = "red") +
  geom_sf_text(data = props_with_states, aes(label = count), check_overlap = TRUE,size=8) +
  annotate("text", x = Inf, y = -Inf, label = "* red outline = EPSCoR State",
           hjust = 1.1, vjust = -0.5, size = 4, fontface = "italic") +
  theme_void() +  
  theme(legend.position = "none") + 
  labs(title = "Geographic Distribution of SBE-Awarded Biotech Projects: 2020-2025 (n=525)")+
  theme(text = element_text(size = 14))


ggsave("C:/Users/dagboh/OneDrive - National Science Foundation/Documents/Data/National Security Task for Lee/Biotech/SBEBiotechAwards_EPSCoRmap.png",width = 13.3, height = 7.5)

#EPSCOR STATE TABLE#

epscor_states <- c(
  "AL", "AK", "AR", "DE", "GU", "HI", "ID", "IA", "KS", "KY", 
  "LA", "ME", "MS", "MT", "NE", "NV", "NH", "NM", "ND", "OK", 
  "PR", "RI", "SC", "SD", "VT", "VI", "WV", "WY"
)

SBEBiotech_EPSCOROnly <- props_by_state %>%
  filter(st_code %in% epscor_states)

SBEBiotech_EPSCOROnly <- rename(SBEBiotech_EPSCOROnly, "EPSCOR State" = "st_code")

write.csv(SBEBiotech_EPSCOROnly, file="C:/Users/dagboh/OneDrive - National Science Foundation/Documents/Data/National Security Task for Lee/Biotech/SBEBiotechAwards_EPSCOROnly.csv")
