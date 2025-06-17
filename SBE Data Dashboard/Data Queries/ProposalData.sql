-- !preview conn=con

select p.prop_id, p.lead_prop_id, 
case when p.lead_prop_id is null or p.lead_prop_id = ' ' then 'std'
when p.lead_prop_id =p.prop_id then 'lead_collab'
else 'collab'
end proj_collab,
case when not (p.lead_prop_id is null or p.lead_prop_id = ' ') then COUNT (p.prop_id) over (partition by p.lead_prop_id)
else 1 end proj_prop_cnt,
case when not (p.lead_prop_id is null or p.lead_prop_id = ' ') then sum(p.rqst_dol) over (partition by p.lead_prop_id)
else p.rqst_dol  end proj_rqst_dol,
p.rqst_dol,
extract('year' from p.dd_rcom_date  + INTERVAL '3 months') as dd_fy,
prc.prc_list,
ctry_list as cvr_sht_ctry_list,
pd_ctry_list,
p2.pi_last_name,
p2.pi_frst_name,
pa2.pi_emai_addr,
p2.lkup_nsf_id nsf_id,
p.pi_id,
p.pi_pr_sup_code,
coalesce(cp_cnt.pi_cnt,0) +1 pi_cnt,
coalesce(pp.panl_cnt,0) rev_panl_cnt,
coalesce(pp.panl_summ_count,0)panl_summ_count,
case when (p.natr_rqst_code IN ('1', '3', '4') -- filter nature of request
  AND p.rcom_awd_istr IN ('0', '2', '3', '6', '7') -- filter recommended awd instrument
  AND p.pgm_ele_code NOT IN ('722700','153600', '717200') -- exclude GRFP & H1B
  ) then 'Y'
when (p.rcom_awd_istr IN ('4') and EXISTS (SELECT * FROM pars.rev_prop WHERE rev_prop.prop_id = p.prop_id)) then 'Y'
when p.prop_id IN (SELECT DISTINCT awd.awd_id
                          FROM awd.awd
                          LEFT JOIN pars.prop ON prop.prop_id = awd.awd_id
                          LEFT JOIN pars.budg_splt ON awd.awd_id = budg_splt.awd_id
                          WHERE prop.pgm_ele_code IN ('722700','153600') 
                          AND budg_splt.fund_code NOT LIKE '1300%') then 'Y'
else 'N'
end compet_flag,
case when prc_list like '%7914%' or p.prop_titl_txt like '%RAPID:%' then 'Y'
else 'N' end AS rapid_flag,
case when prc_list like '%7916%' or p.prop_titl_txt like '%EAGER:%' then 'Y'
else 'N' end as eager_flag,
i.inst_name,
trim(i.st_code) st_code,
case when trim(i.st_code) IN ('AL', 'AK', 'AR', 'DE', 'GU', 'HI', 'ID', 'IA', 'KS', 'KY', 'LA', 'ME', 'MS', 'MT', 'NE', 'NV', 
'NH', 'NM', 'ND', 'OK', 'PR', 'RI', 'SC', 'SD', 'VI', 'VT', 'WV', 'WY') THEN 'Y'
ELSE 'N'
end inst_epscor_flag,
perf_org.perf_org_txt, 
 --below is the institution level definition taken from enterprise reporting
case when perf_org.perf_org_code  in ('A02', 'B02' ,'C02','D12') then 'K-12' 
when perf_org.perf_org_code  in ('A03', 'B03', 'C03', 'D13') then '2 Year' 
when perf_org.perf_org_code  in ('A04', 'B04', 'C04', 'D14') then '4 Year' 
when perf_org.perf_org_code  in ('A05', 'B05', 'C05', 'D15') then 'Masters' 
when perf_org.perf_org_code  in ('A06', 'B06', 'C06', 'D16') then 'PhD' 
else 'Other' end 
institution_category,
case when i.HBCU_FLAG = 'Y' or
i.HISP_SERV_FLAG = 'Y' or
i.NATV_ALSK_SERV_FLAG = 'Y' or
i.NATV_HWAN_SERV_FLAG = 'Y' or
i.TRBL_COL_FLAG = 'Y' or 
i.MAJR_MINR_FLAG = 'Y' then 'Y'
else 'N'
end as MSI_FLAG,
i.HISP_SERV_FLAG,
i.NATV_ALSK_SERV_FLAG,
i.NATV_HWAN_SERV_FLAG,
i.TRBL_COL_FLAG, 
i.MAJR_MINR_FLAG,
i.hbcu_flag,
pc.clos_date,
case 
when p.dd_rcom_date = '1900-01-01 00:00:00.000' and  pc.clos_date is null then extract(day from current_date - p.nsf_rcvd_date)
when p.dd_rcom_date = '1900-01-01 00:00:00.000' and not pc.clos_date is null then extract(day from current_date - pc.clos_date)
when pc.clos_date is null then extract(day from p.dd_rcom_date - p.nsf_rcvd_date)
when not pc.clos_date is null then extract(day from p.dd_rcom_date - pc.clos_date)
end dwell_time,
case when not pc.hum_date is NULL THEN pc.hum_date::varchar(10) WHEN pc.humn_date_pend_flag='Y' THEN 'Pend' END AS humn_date,
CASE WHEN not pc.vert_date  is NULL THEN pc.vert_date::varchar(10)  WHEN pc.vrtb_date_pend_flag='Y' THEN 'Pend' END AS vrtb_date,
nr.natr_rqst_abbr,
p.pm_ibm_logn_id po,
awd.pm_ibm_logn_id awd_po, 
coalesce(awd.org_code, p.org_code) org_code, 
p.inst_id, 
p.perf_inst_id, 
p.pgm_ele_code, 
pe.pgm_ele_name, 
p.orig_pgm_ele_code, 
p.orig_org_code,o.dir_div_abbr div, 
o2.dir_div_abbr dir, 
p.obj_clas_code, 
oc.obj_clas_name, 
COALESCE(awd.awd_titl_txt, p.prop_titl_txt) AS title,
p.rqst_mnth_cnt, 
p.rqst_eff_date, 
p.nsf_rcvd_date,
p.rcom_mnth_cnt, 
p.rcom_eff_date, 
p.pm_asgn_date, 
p.pm_rcom_date,
p.dd_rcom_date, 
p.rcom_awd_istr,
awd.awd_istr_code,
p.natr_rqst_code,
p.prop_stts_code,
p.pgm_annc_id,
p.nsb_flag, 
p.site_vist_flag,
p.cntx_stmt_id,
p.dd_aprv_logn_id,
p.dd_aprv_date,
p.prcs_stmt_tmpl_id,
p.prcs_stmt_tmsp, 
ps.prop_stts_abbr,
ps.prop_stts_txt,
amd.amd_mnth_cnt,
amd.actn_exp_date,
awd.tot_intn_awd_amt,
awd.awd_eff_date,
awd.awd_exp_date,
case when p.prop_stts_code = '80' and not (p.lead_prop_id is null or p.lead_prop_id = ' ') then sum(awd.tot_intn_awd_amt) over (partition by p.lead_prop_id)
else awd.tot_intn_awd_amt  end proj_tot_intn_awd_amt,
rev_count.rev_count,
rev_count.mail_rev_count,
rev_count.panl_rev_count,
rev_count.avg_mrr, 
rev_count.rtng_list,
eri.unitid,
case when eri.eri ='1' then 'y'  when eri.eri = '0' then 'n' else 'unkn' end eri_stts
from pars.prop p
left join pars.prop_stts ps on ps.prop_stts_code = p.prop_stts_code 
left join (select pa.prop_id, string_agg(trim(pa.prop_atr_code), '; ') as prc_list 
from pars.prop_atr pa where pa.prop_atr_type_code = 'PRC' group by pa.prop_id) as prc on prc.prop_id = p.prop_id
left join (select p.prop_id, string_agg(c.ctry_name , '; ') as ctry_list
from pars.prop p
join flflp.prop_subm_ctl psc on psc.prop_id = p.prop_id
join flflp.prop_spcl_item psi on psi.temp_prop_id = psc.temp_prop_id 
join pars.ctry c on lower(trim(c.ctry_code)) = lower(trim(psi.spcl_item_code)) and not c.ctry_code ='RI REQUIRED' 
group by p.prop_id ) as cvr_ctry on cvr_ctry.prop_id = p.prop_id
left join (select prop_id, string_agg(c.ctry_name, '; ') as pd_ctry_list 
from
(select prop_id, trim(upper(intl_ctry_1)) as ctry
from pars.intl_impl ii 
union all 
select prop_id, trim(upper(intl_ctry_2)) as ctry
from pars.intl_impl ii 
union all 
select prop_id, trim(upper(intl_ctry_3)) as ctry
from pars.intl_impl ii 
union all 
select prop_id, trim(upper(intl_ctry_4)) as ctry
from pars.intl_impl ii 
union all 
select prop_id, trim(upper(intl_ctry_5)) as ctry
from pars.intl_impl ii ) as pd_ctry
join pars.ctry c on c.ctry_code = pd_ctry.ctry and not c.ctry_name ='RI REQUIRED' 
group by prop_id) as pd_ctry on pd_ctry.prop_id = p.prop_id
left join pars.inst i on i.inst_id = p.inst_id
left join pars.pi p2 on p2.pi_id = p.pi_id
left join pars.pi_addr pa2 on pa2.pi_id =p.pi_id and trim(pa2.prim_addr_flag) = 'Y'
left join flflp.prop_subm_ctl psc2 on psc2.prop_id = p.prop_id 
left join flflp.prop_covr pc on pc.temp_prop_id = psc2.temp_prop_id
left join rptdb.natr_rqst nr on nr.natr_rqst_code =p.natr_rqst_code
left join msd.pgm_ele pe on pe.pgm_ele_code =p.pgm_ele_code
left join awd.awd on awd.awd_id = p.prop_id
left join (select prop_id, count(distinct pi_id) as pi_cnt from pars.addl_pi_invl api group by prop_id) cp_cnt on cp_cnt.prop_id = p.prop_id
left join (select pp.prop_id, 
count(distinct pp.panl_id) as panl_cnt,   
count(distinct case when lower(trim(pps.panl_summ_rlse_flag))='y' then  pp.panl_id end) panl_summ_count
from flflp.panl_prop pp 
left join flflp.panl_prop_summ pps on lower(trim(pps.panl_id))= lower(trim(pp.panl_id)) and pps.prop_id = pp.prop_id 
where upper(left(pp.panl_id,1)) like 'P' 
group by pp.prop_id) pp on pp.prop_id = p.prop_id
left join msd.obj_clas oc on oc.obj_clas_code = p.obj_clas_code
LEFT JOIN pars.perf_org on perf_org.perf_org_code = i.perf_org_code
left join awd.amd on p.prop_id = amd.prop_id and amd.amd_id = '000'
LEFT JOIN msd.org o ON o.org_code = COALESCE(awd.org_code, p.org_code)
LEFT JOIN msd.org o2 ON o2.org_code = LEFT(COALESCE(awd.org_code, p.org_code),2)||'000000'
left join(select p.prop_id, 
count(distinct case when trim(lower(rp2.rev_rlse_flag)) = 'y' and trim(lower(rp.rev_stts_code)) = 'r' then rp2.revr_id end) as rev_count,
count(distinct case when trim(lower(rp2.rev_rlse_flag)) = 'y' and trim(lower(rp.rev_stts_code)) = 'r' and trim(lower(rp.rev_type_code))  = 'r' then rp2.revr_id end) as mail_rev_count,
count(distinct case when trim(lower(rp2.rev_rlse_flag)) = 'y' and trim(lower(rp.rev_stts_code)) = 'r' and not trim(lower(rp.rev_type_code))  = 'r' then rp2.revr_id end) as panl_rev_count,
round(avg(case when trim(ril.score) = 'NA' then null
        else ril.score::numeric
        end),2) avg_mrr, string_agg(ril.rating, ';') rtng_list 
from pars.prop p 
join pars.rev_prop rp on rp.prop_id = p.prop_id 
left join pars.rev_type rt on rt.rev_type_code = rp.rev_type_code 
left join flflp.rev_prop rp2 on (rp2.revr_id=rp.revr_id and rp2.prop_id=rp.prop_id)
left join misc.rating_ind_lkup ril on ril.rev_prop_rtng_ind = rp2.rev_prop_rtng_ind 
group by p.prop_id) rev_count on rev_count.prop_id = p.prop_id
left join (select distinct on (inst_id) inst_id, eri, unitid
from misc.inst_eri_stts ies 
order by inst_id, eri_yr desc) eri on eri.inst_id = i.inst_id 
WHERE (p.dd_rcom_date BETWEEN '10-01-2014' AND CURRENT_DATE)