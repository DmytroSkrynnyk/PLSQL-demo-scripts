The issue is one where I wanted to confirm that the URL params are in synch with the rpt_param_def table.
What to do?  
 
I could either…
 
    loop thru the apex rpt_param_def table and then INSTR back to the url ... or
 
    parse the rpt_url and then select from the apex rpt_param_def.
 
Those would work but would require multiple iterations to determine what is common to both, what is unique to one, what is unique to the other, etc. I remembered years ago an article from Steven Feuerstein where he needed to do this very thing (http://www.oracle.com/technetwork/issue-archive/o53plsql-083350.html). He used collection methods. The thinking is to populate a nested table from the rpt_url values. Create a second nested table from the apex_rpt_param_def rows. Once the two nested tables exist, it becomes trivial to answer the original questions of commonality and uniqueness.
 
 
Here’s the guts of the script                                                      
 
begin
 
   pop_l_rpt_url(v_rpt_url_filename,v_app_cd);
   display_coll(l_url_param,'PARAMETERS FROM RPT_URL','N');
  
   pop_l_apex_param(v_apex_param);
   display_coll(l_apex_param,'PARAMETERS FROM APEX_PARAM','N');
 
   -- parameters common to both
   l_stage_param := l_url_param MULTISET INTERSECT l_apex_param;
   display_coll(l_stage_param,'COMMON PARAMETERS','Y');
 
   -- parameters unique to rpt_url
   l_stage_param := l_url_param MULTISET EXCEPT l_apex_param;
   display_coll(l_stage_param,'UNIQUE TO RPT_URL','Y');
 
   -- parameters unique to apex_param
   l_stage_param := l_apex_param MULTISET EXCEPT l_url_param;
   display_coll(l_stage_param,'UNIQUE TO APEX_PARAM','Y');
 
end;
 
Here is the output.
 
 
---------------------------------------------
   PARAMETERS FROM RPT_URL (35)
---------------------------------------------
---------------------------------------------
   PARAMETERS FROM APEX_PARAM (38)
---------------------------------------------
---------------------------------------------
   COMMON PARAMETERS (30)
---------------------------------------------
   INVTRY_ITEM_ID
   STORAGE_SITE_CD
   FIT_FOR_PURPOSE_CD
   FIT_FOR_PURPOSE_DESC
   QUALITY_CD
   OWNER_BIZENT_CD
   PROD_ID
   PROD_DESC
   PURCH_INST_REF
   PURCH_ORG_CD
   RECEIPT_LOT
   RECEIPT_INST_REF
   CUSTOMS_CLASS
   MFG_FACILITY_CD
   SERIAL_NO
   PROD_MEMBER
   PROD_MBR_ATTR_NAME
   PROD_MBR_ATTR_VAL
   INT_EXT_FLAG
   DLV_DT_BASIS
   SUPPRESS_ZERO_WONO
   INVTRY_REPORT_UOM2
   RPT_TYPE
   CURRENCY_CODE
   SHOW_COSTS
   SUBTOTALS
   CFF
   INVTRY_FILTER
   SRC_FRM
   SHOW_SUMMARY
---------------------------------------------
   UNIQUE TO RPT_URL (5)
---------------------------------------------
   DESC_SET_NAME
   PROD_CLASS
   RPT_DESFORMAT
   RPT_DESTYPE
  
---------------------------------------------
   UNIQUE TO APEX_PARAM (8)
---------------------------------------------
   FIT_FOR_PURPOSE_GRP_CD
   GRP_CD
   ORDER_TYPE_CD
   OWNER_CD
   OWNER_TYPE
   PROGRAM_BIZENT_CD
   PROGRAM_CD
   SUPPLIER_BIZENT_CD
 
 
 
 
 
Here is the script in it’s entirety.
 
 
 
Declare
 
   l_stage_param          varchar_ntt := varchar_ntt();
   l_url_param            varchar_ntt := varchar_ntt();
   l_apex_param           varchar_ntt;
 
   v_app_cd               tims_app_tp.app_cd_t      := 'CUSTOM_IQ';
   v_rpt_url_filename     rpt_def_frm_tp.rpt_name_t := 'INVTRY01 - Internal W/O SUMMARY';
   v_apex_param           rpt_def_frm_tp.rpt_name_t := 'INVTRY01';
 
   PROCEDURE display_coll (l_coll_in IN VARCHAR_NTT,coll_desc IN VARCHAR2,prn_detail IN VARCHAR2)
   IS
      v_cnt NUMBER;
   BEGIN
  
   dbms_output.put_line('---------------------------------------------');
   dbms_output.put_line('   ' || coll_desc || ' (' || l_coll_in.last || ')');
   dbms_output.put_line('---------------------------------------------');
 
      v_cnt := l_coll_in.FIRST;
      WHILE v_cnt IS NOT NULL AND prn_detail = 'Y' LOOP
         dbms_output.put_line('   ' || l_coll_in(v_cnt));
         v_cnt := l_coll_in.NEXT(v_cnt);
      END LOOP;
   END;
 
   PROCEDURE pop_l_rpt_url ( p_rpt_name IN  rpt_def_frm_tp.rpt_name_t,
                             p_app_cd   IN  tims_app_tp.app_cd_t)
   IS
      v_rpt_param_str   rpt_def_frm_tp.rpt_url_t;
      v_table           dbms_utility.uncl_array;
      v_tablen          BINARY_INTEGER;
 
   BEGIN
      --collect parameters from rpt_def_frm.rpt_url
      SELECT
         SUBSTR(rpt_url,INSTR(rpt_url, ':', 1, 6)+1,INSTR(rpt_url, ':', 1, 7)-1 - INSTR(rpt_url, ':', 1, 6))
      INTO
         v_rpt_param_str
      FROM
         rpt_def_frm f,
         rpt_def_app a,
         tims_app    t
      WHERE
         f.rpt_def_frm_id = a.rpt_def_frm_id and
         a.tims_app_id = t.tims_app_id and
         t.app_cd = p_app_cd and
         f.rpt_name = p_rpt_name and
         f.active_flag = 'Y';
 
      --populate table from string
      DBMS_UTILITY.COMMA_TO_TABLE(v_rpt_param_str, v_TabLen, v_Table);
      --to aid in collection comparison, populate nested table 
      --and strip Apex pg from param name example: P600_PROD_CLASS becomes PROD_CLASS
      FOR v_cnt IN 1..v_Table.COUNT LOOP
          l_url_param.extend;
          l_url_param( l_url_param.last) := REGEXP_REPLACE(v_table(v_cnt),'^P[^_]+_', '');
      END LOOP;
 
   END;
 
   PROCEDURE pop_l_apex_param (p_rpt_name IN VARCHAR)
   IS
      v_cnt NUMBER;
   BEGIN
  
      --collect parameters from apexapp.rpt_param_def into nested table
      select p.param_name
      bulk collect into l_apex_param
      from apexapp.rpt_param_def p,
           apexapp.rpt_def r
      where
           p.rpt_def_id = r.rpt_def_id and   
           r.rpt_fname = p_rpt_name and
           p.active_flag = 'Y';
 
   END;
 
begin
 
   pop_l_rpt_url(v_rpt_url_filename,v_app_cd);
   display_coll(l_url_param,'PARAMETERS FROM RPT_URL','N');
  
   pop_l_apex_param(v_apex_param);
   display_coll(l_apex_param,'PARAMETERS FROM APEX_PARAM','N');
 
   -- parameters common to both
   l_stage_param := l_url_param MULTISET INTERSECT l_apex_param;
   display_coll(l_stage_param,'COMMON PARAMETERS','Y');
 
   -- parameters unique to rpt_url
   l_stage_param := l_url_param MULTISET EXCEPT l_apex_param;
   display_coll(l_stage_param,'UNIQUE TO RPT_URL','Y');
 
   -- parameters unique to apex_param
   l_stage_param := l_apex_param MULTISET EXCEPT l_url_param;
   display_coll(l_stage_param,'UNIQUE TO APEX_PARAM','Y');
 
end;