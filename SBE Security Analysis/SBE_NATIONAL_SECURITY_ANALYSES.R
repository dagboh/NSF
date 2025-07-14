#SBE NATIONAL SECURITY DATA PULL


library(readxl)
library(writexl)
library(dplyr)
library(tidyverse)
library(odbc)
library(DT)

#PULLING SQL DATA

library(DBI)
con <- dbConnect(odbc::odbc(), dsn = "DataLakeHouse", uid = "dagboh@AD.NSF.GOV", 
                 timeout = 10)

SBE_Security <-"SELECT org.dir_div_abbr as division, 
pec.pgm_ele_name as program, 
awd.awd_titl_txt as title, 
prop.prop_id as prop_id,
prop.inst_id as inst_id,
impact.society AS impact_on_society, 
pr.sub_date as submission_date, 
pr.rpt_peri_end as reporting_end_date, 
case pr.rpt_type when 'A' then 'Annual Report' when 'F' then 'Final Annual Report' when 'I' then 'Interim' end as Type, 
awd.awd_id as Awd_ID,
awd.pgm_ele_code as Pgm_Code,
awd.org_code as Org_Code,
awd.tot_intn_awd_amt as AwdAmount,
ucu.sign_blck_name AS PO, 
pi_dmog_vw.pi_gend_desc as Gender,
pi_dmog_vw.pi_ethn_desc as Ethnicity,
pi_dmog_vw.pi_race_desc as Race,
pi.pi_frst_name || ' ' || pi.pi_last_name as PI, 
inst.inst_name as Org 
FROM rppr.impact impact left join rptdb.awd awd on impact.awd_id = awd.awd_id 
left join rptdb.prop prop on impact.awd_id = prop.prop_id 
left join flflp.pr_cntl pr on impact.doc_id = pr.doc_id 
left join rptdb.pgm_ele pec on pec.pgm_ele_code = awd.pgm_ele_code 
left join rptdb.org org on org.org_code = awd.org_code 
left join rptdb.upm_cmn_user ucu on ucu.ibm_logn_id = TRIM(awd.pm_ibm_logn_id) 
left join rptdb.pi pi on pi.pi_id = awd.pi_id 
left join rptdb.pi_dmog_vw on pi.pi_id = pi_dmog_vw.pi_id
left join rptdb.inst inst on inst.inst_id = awd.perf_inst_id 
WHERE pr.sub_date >= '2020-05-01 00:00:00' and pr.sub_date <= '2025-07-13 23:59:59' and awd.org_code like '04%' and ( impact.society like '%foreign policy%' or impact.society like '%security%' or impact.society like '%conflict%' or impact.society like '%interstate war%' or impact.society like '%intrastate war%' or impact.society like '%dispute resolution%' or impact.society like '%peace studies%' or impact.society like '%peace science%' or impact.society like '%cybersecurity%' or impact.society like '%treaty %' or impact.society like '%treaties%' ) 
ORDER by division asc, program asc limit 2025-07-13"

SBE_SecurityData <- dbGetQuery(con,SBE_Security) %>% 
  mutate(across(where(is.character),str_trim))

#ADD CARNEGIE CLASSIFICATIONS

carnegie_crosswalk <- read_excel("C:/Users/dagboh/OneDrive - National Science Foundation/Documents/COE/Outreach/Reviewer Analyses/Excel Files/carnegie_crosswalk.xlsx")

carnegie_crosswalk <- rename(carnegie_crosswalk,"inst_id" = "NSF Institution ID")

SBE_SecurityData <-  left_join(SBE_SecurityData, carnegie_crosswalk, by = "inst_id")

write.csv(SBE_SecurityData, "C:/Users/dagboh/OneDrive - National Science Foundation/Documents/Data/National Security Task for Lee/SBE_Securitydata.csv")
