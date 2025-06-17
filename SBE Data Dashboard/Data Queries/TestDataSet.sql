-- !preview conn=con

SELECT rptdb.prop.lead_prop_id, 
                     rptdb.prop.prop_id, 
                     rptdb.prop.inst_id, 
                     rptdb.prop.pi_id, 
                     rptdb.prop.org_code,
                     rptdb.prop.nsf_rcvd_date, 
                     rptdb.prop.pgm_ele_code, 
                     rptdb.prop.rqst_dol, 
                     rptdb.prop.rcom_awd_istr,
                     rptdb.prop.prop_stts_code, 
                     rptdb.prop.perf_inst_id,
                     rptdb.prop.pgm_annc_id
FROM rptdb.prop
WHERE rptdb.prop.org_code IN ('04040000', '04030000', '04000000', '04050000',
                              '04010000')