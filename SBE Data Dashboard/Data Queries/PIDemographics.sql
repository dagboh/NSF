-- !preview conn=con

#this needs to be made SBE-specific

select  
pi_role.pi_id as pi_pi_id,
pi_role.proj_role_code as pi_proj_role_code,
pi_role.prop_id as pi_prop_id,
prop.prop_stts_code as pi_prop_stts_code,
pi.pi_acad_degr_txt AS pi_acad_degr_txt,
pi.pi_actv_stts_code AS pi_actv_stts_code,
pi.pi_degr_yr AS pi_degr_yr,
pi.pi_dept_name AS pi_dept,
pi.pi_frst_name AS pi_frst_name,
pi.pi_last_name AS pi_last_name,
pi.pi_mid_init AS pi_mid_init,
pi_dmog_vw.pi_gend_desc as pi_gend_desc,
pi_dmog_vw.pi_ethn_desc as pi_ethn_desc,
pi_dmog_vw.pi_race_desc as pi_race_text,
pi_dmog_vw.pi_race_code as pi_race_code,
pi_dmog_vw.pi_mult_race_code as pi_multi_race_code,
prop.dd_rcom_date as pi_dd_rcom_date,
prop.pgm_ele_code as pi_pgm_ele_code,
prop.lead_prop_id as pi_lead_prop_id,
prop.org_code as pi_prop_org_code,
inst.st_code as pi_state,
pr.frst_awd as pi_frst_awd
from 
pars.prop
left join
(SELECT  prop.prop_id AS prop_id,  prop.pi_id AS pi_id, prop.proj_role_code AS proj_role_code 
 FROM pars.prop
 UNION
 SELECT addl_pi_invl.prop_id AS prop_id, addl_pi_invl.pi_id AS pi_id, addl_pi_invl.proj_role_code AS proj_role
 FROM pars.addl_pi_invl) as pi_role on prop.prop_id = pi_role.prop_id
left join (
select distinct min(case props.pi_id when null then apc.start_date else a.awd_eff_date end) over (partition by apc.pi_id) as frst_awd, apc.pi_id 
from awd.awd_pi_copi apc 
join awd.awd a on a.awd_id =apc.awd_id 
full join (SELECT  prop.prop_id AS prop_id,  prop.pi_id AS pi_id
 FROM pars.prop
 UNION
 SELECT addl_pi_invl.prop_id AS prop_id, addl_pi_invl.pi_id AS pi_id
 FROM pars.addl_pi_invl) as props on props.prop_id =a.awd_id and props.pi_id = apc.pi_id
join pars.prop on prop.prop_id = a.awd_id
where prop.obj_clas_code NOT IN ('4115', '4121', '4160', '4170', '4181', '4182', '4194') 
AND a.awd_istr_code != '7' ) as pr on pr.pi_id = pi_role.pi_id
left join rptdb.pi_vw as pi on pi.pi_id = pi_role.pi_id
left join rptdb.pi_dmog_vw ON pi_dmog_vw.pi_id = pi_role.pi_id
left join rptdb.inst on inst.inst_id = pi.inst_id
where prop.dd_rcom_date > '10-01-2014' 
