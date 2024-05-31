SELECT * FROM saradap WHERE saradap_term_code_entry= '202410'; --6256 / 775
--SARADAP_APST_CODE
SELECT * FROM stvapst;
--SARADAP_STYP_CODE
SELECT * FROM stvstyp;
--SARADAP_RESD_CODE
SELECT * FROM stvresd;
--SARADAP_COLL_CODE_1
SELECT * FROM stvcoll;
-- SARADAP_DEGC_CODE_1
SELECT * FROM stvdegc;
-- SARADAP_MAJR_CODE_1
SELECT * FROM stvmajr;

SELECT * FROM sarappd WHERE sarappd_term_code_entry='202410' and sarappd_pidm=715574; -- 6224
--SARAPPD_APDC_CODE
SELECT * FROM STVAPDC;
-- Term
SELECT * FROM STVTERM;
SELECT * FROM sprhold where sprhold_pidm = f_x_get_pidm('A00580072') and ;
----------------------------------------------------------------------------------------Based on the base tables
SELECT  spriden_pidm
        ,spriden_id  
        ,spriden_first_name
        ,spriden_last_name
        ,spriden_mi
        ,spbpers.gender
        ,spbpers.ethn_desc 
        ,stvlevl_desc
        ,stvapst_desc   "Applicaiton Decision"
        ,stvapdc_desc   "Applicant Decision"
        ,stvstyp_desc   "Student Type"
        ,stvresd_desc   "Residence"
        ,saradap_degc_code_1 "Degree"
        ,saradap_majr_code_1 "Major"
FROM    saradap 
        INNER JOIN stvlevl ON saradap_levl_code = stvlevl_code
        INNER JOIN stvapst ON saradap_apst_code = stvapst_code
        INNER JOIN (SELECT spriden_pidm,spriden_id,spriden_first_name,spriden_last_name,spriden_mi 
                    FROM spriden WHERE spriden_change_ind IS NULL)SRPIDEN ON saradap_pidm=spriden_pidm
        LEFT JOIN sarappd ON saradap_pidm = sarappd_pidm AND saradap_term_code_entry = sarappd_term_code_entry
        LEFT JOIN stvapdc ON sarappd_apdc_code = stvapdc_code
        LEFT JOIN stvstyp ON saradap_styp_code = stvstyp_code
        LEFT JOIN stvresd ON saradap_resd_code = stvresd_code
        LEFT JOIN (SELECT spbpers_pidm
                            ,spbpers_sex  Gender
                            ,stvethn_desc ethn_desc
                    FROM    spbpers,STVETHN
                    WHERE   spbpers_ethn_code = stvethn_code) SPBPERS  ON saradap_pidm = spbpers.spbpers_pidm
WHERE   saradap_term_code_entry ='202470'
GROUP BY spriden_pidm
        ,spriden_id  
        ,spriden_first_name
        ,spriden_last_name
        ,spriden_mi
        ,spbpers.gender
        ,spbpers.ethn_desc 
        ,stvlevl_desc
        ,stvapst_desc
        ,stvapdc_desc
        ,stvstyp_desc
        ,stvresd_desc
        ,saradap_degc_code_1
        ,saradap_majr_code_1
ORDER BY spriden_last_name
;

---- ARGOS QUERY----
select AA.ID "Student_ID",
       AA.FIRST_NAME "First_Name",
       AA.LAST_NAME "Last_Name",
       AA.GENDER "Gender",
       AA.ETHN_DESC "Ethn_Desc",
       AA.LEVL_DESC "Student_Level",
       AA.APST_DESC "Application_Status",
       AA.APDC_DESC1 "Application_Decision",
       AA.ADMT_DESC "Admission_Type",
       AA.STYP_DESC "Student_Type",
       AA.RESD_DESC "Residency",
       AA.DEGC_CODE1 "Degree",
       AA.MAJR_CODE1 "Major",
       AA.HOLD_DESC1 "Hold",
       AA.HOLD_REASON1 "Hold_Reason",
       HOUSING."Housing_IND" "Housing_ind",
       HOUSING.SLRRASG_BLDG_CODE "Building",
       HOUSING.SLRRASG_ROOM_NUMBER "Room",
       HOUSING.SLRRASG_ASCD_CODE "Housing_Status",
       FAFSA.RVQ_FAFSA_CURRENT_RECORD_IND "FAFSA_IND",
       FNAID_VERF_ST."Verification_status" "Verification_status",
       CASE WHEN AWRD_ACC.RPRAWRD_PIDM IS NULL THEN 'N' ELSE 'Y' END "AWRD_ACC_IND",
       AWRD_ACC."Accepted_Amt" "Accepted_amt",
       CASE WHEN AWARD_OFRD."Offer_IND" IS NOT NULL THEN 'Y' ELSE 'N' END "AWARD_OFRD_IND",
       AWRD_ACC."Offer_amt" "Offered_amt",
       AT_DEPOSITS.DEPOSIT_DETAIL_DESC "Deposit_Description",
       TBRDEPO.TBRDEPO_AMOUNT "Deposit_Amt",
       AT_DEPOSITS.DEPOSIT_BALANCE "Deposit_Balance",
       CASE WHEN SORHSCH.SORHSCH_GRADUATION_DATE IS NOT NULL
            AND SORHSCH.SORHSCH_TRANS_RECV_DATE IS NOT NULL
            AND SORHSCH.SORHSCH_ADMR_CODE IS NOT NULL
            THEN 'Y'
            ELSE 'N'
       END "Transcript"
  from BANINST1.AS_ADMISSIONS_APPLICANT AA,
       BANINST1.AT_DEPOSITS AT_DEPOSITS,
       TAISMGR.TBRDEPO TBRDEPO,
       SATURN.SORHSCH SORHSCH,
       ( select distinct SLRRASG.SLRRASG_PIDM,
                SLRRASG.SLRRASG_BLDG_CODE,
                SLRRASG.SLRRASG_ROOM_NUMBER,
                SLRRASG.SLRRASG_TERM_CODE,
                SLRRASG.SLRRASG_RRCD_CODE,
                SLRRASG.SLRRASG_BEGIN_DATE,
                SLRRASG.SLRRASG_END_DATE,
                SLRRASG.SLRRASG_ASCD_CODE,
                CASE WHEN SARADAP.SARADAP_PIDM IS NOT NULL THEN 'Y'
                     WHEN SARADAP.SARADAP_PIDM IS NULL THEN 'N' END "Housing_IND"
           from SATURN.SLRRASG SLRRASG,
                SATURN.SARADAP SARADAP
          where ( SARADAP.SARADAP_PIDM = SLRRASG.SLRRASG_PIDM (+)
                  and SARADAP.SARADAP_TERM_CODE_ENTRY = SLRRASG.SLRRASG_TERM_CODE (+) )
            and ( SLRRASG.SLRRASG_ASCD_CODE = 'AC'
                  and exists ( select SLBRMAP.SLBRMAP_PIDM
                             from SATURN.SLBRMAP SLBRMAP
                            where SLBRMAP.SLBRMAP_PIDM = SLRRASG.SLRRASG_PIDM ) ) ) HOUSING,
       ( select distinct STVTERM.STVTERM_CODE,
                RVQ_FAFSA.RVQ_FAFSA_PIDM,
                RVQ_FAFSA.RVQ_FAFSA_CURRENT_RECORD_IND
           from SATURN.STVTERM STVTERM,
                BANINST1.RVQ_FAFSA RVQ_FAFSA
          where ( RVQ_FAFSA.RVQ_FAFSA_AIDY_CODE = STVTERM.STVTERM_FA_PROC_YR ) ) FAFSA,
       ( select RCRAPP1.RCRAPP1_PIDM,
                STVTERM2.STVTERM_CODE,
                CASE WHEN RCRAPP1.RCRAPP1_VERIFICATION_MSG = 2 THEN 'Not Selected'
                WHEN RCRAPP1.RCRAPP1_VERIFICATION_MSG = 1 AND RORSTAT.RORSTAT_VER_COMPLETE = 'Y' THEN 'Verification Complete'
                WHEN RCRAPP1.RCRAPP1_VERIFICATION_MSG = 1 AND RORSTAT.RORSTAT_VER_COMPLETE = 'N' THEN 'Selected-Not Verified'
                END "Verification_status"
           from FAISMGR.RCRAPP1 RCRAPP1,
                FAISMGR.RORSTAT RORSTAT,
                SATURN.STVTERM STVTERM2
          where ( RCRAPP1.RCRAPP1_PIDM = RORSTAT.RORSTAT_PIDM
                  and RCRAPP1.RCRAPP1_AIDY_CODE = RORSTAT.RORSTAT_AIDY_CODE
                  and RORSTAT.RORSTAT_AIDY_CODE = STVTERM2.STVTERM_FA_PROC_YR )
          group by RCRAPP1.RCRAPP1_PIDM,
                   STVTERM2.STVTERM_CODE,
                   CASE WHEN RCRAPP1.RCRAPP1_VERIFICATION_MSG = 2 THEN 'Not Selected'
         WHEN RCRAPP1.RCRAPP1_VERIFICATION_MSG = 1 AND RORSTAT.RORSTAT_VER_COMPLETE = 'Y' THEN 'Verification Complete'
         WHEN RCRAPP1.RCRAPP1_VERIFICATION_MSG = 1 AND RORSTAT.RORSTAT_VER_COMPLETE = 'N' THEN 'Selected-Not Verified'
         END ) FNAID_VERF_ST,
       ( select RPRAWRD.RPRAWRD_PIDM,
                RPRAWRD.RPRAWRD_AIDY_CODE,
                SUM(RPRAWRD.RPRAWRD_ACCEPT_AMT) "Accepted_Amt",
                SUM(RPRAWRD.RPRAWRD_OFFER_AMT) "Offer_amt",
                RPRATRM.RPRATRM_TERM_CODE
           from FAISMGR.RPRAWRD RPRAWRD,
                FAISMGR.RPRATRM RPRATRM
          where ( RPRAWRD.RPRAWRD_PIDM = RPRATRM.RPRATRM_PIDM
                  and RPRAWRD.RPRAWRD_AIDY_CODE = RPRATRM.RPRATRM_AIDY_CODE )
            and ( RPRAWRD.RPRAWRD_AWST_CODE IN ('ACPT','WA') )
          group by RPRAWRD.RPRAWRD_PIDM,
                   RPRAWRD.RPRAWRD_AIDY_CODE,
                   RPRATRM.RPRATRM_TERM_CODE ) AWRD_ACC,
       ( select RPRAWRD.RPRAWRD_PIDM,
                RPRAWRD.RPRAWRD_AIDY_CODE,
                SUM(RPRAWRD.RPRAWRD_OFFER_AMT) "Offer_amt",
                RPRATRM.RPRATRM_TERM_CODE,
                CASE WHEN RPRAWRD.RPRAWRD_PIDM IS NOT NULL THEN 'Y' ELSE 'N' END "Offer_IND"
           from FAISMGR.RPRAWRD RPRAWRD,
                FAISMGR.RPRATRM RPRATRM
          where ( RPRAWRD.RPRAWRD_PIDM = RPRATRM.RPRATRM_PIDM
                  and RPRAWRD.RPRAWRD_AIDY_CODE = RPRATRM.RPRATRM_AIDY_CODE )
            and ( RPRAWRD.RPRAWRD_AWST_CODE IN ('OFRD') )
          group by RPRAWRD.RPRAWRD_PIDM,
                   RPRAWRD.RPRAWRD_AIDY_CODE,
                   RPRATRM.RPRATRM_TERM_CODE,
                   CASE WHEN RPRAWRD.RPRAWRD_PIDM IS NOT NULL THEN 'Y' ELSE 'N' END ) AWARD_OFRD
 where ( AA.PIDM_KEY = HOUSING.SLRRASG_PIDM (+)
         and AA.TERM_CODE_KEY = HOUSING.SLRRASG_TERM_CODE (+)
         and AA.PIDM_KEY = AWRD_ACC.RPRAWRD_PIDM (+)
         and AA.TERM_CODE_KEY = AWRD_ACC.RPRATRM_TERM_CODE (+)
         and AA.PIDM_KEY = FAFSA.RVQ_FAFSA_PIDM (+)
         and AA.TERM_CODE_KEY = FAFSA.STVTERM_CODE (+)
         and AA.PIDM_KEY = AWARD_OFRD.RPRAWRD_PIDM (+)
         and AA.TERM_CODE_KEY = AWARD_OFRD.RPRATRM_TERM_CODE (+)
         and AA.PIDM_KEY = AT_DEPOSITS.PIDM_KEY (+)
         and AA.TERM_CODE_KEY = AT_DEPOSITS.DEPOSIT_TERM_CODE_KEY (+)
         and AT_DEPOSITS.DEPOSIT_TERM_CODE_KEY = TBRDEPO.TBRDEPO_TERM_CODE (+)
         and AT_DEPOSITS.PIDM_KEY = TBRDEPO.TBRDEPO_PIDM (+)
         and AA.PIDM_KEY = SORHSCH.SORHSCH_PIDM (+)
         and AA.PIDM_KEY = FNAID_VERF_ST.RCRAPP1_PIDM (+)
         and AA.TERM_CODE_KEY = FNAID_VERF_ST.STVTERM_CODE (+) )
   and AA.TERM_CODE_KEY = '202470'
 group by AA.ID,
          AA.FIRST_NAME,
          AA.LAST_NAME,
          AA.GENDER,
          AA.ETHN_DESC,
          AA.LEVL_DESC,
          AA.APST_DESC,
          AA.APDC_DESC1,
          AA.ADMT_DESC,
          AA.STYP_DESC,
          AA.RESD_DESC,
          AA.DEGC_CODE1,
          AA.MAJR_CODE1,
          AA.HOLD_DESC1,
          AA.HOLD_REASON1,
          HOUSING."Housing_IND",
          HOUSING.SLRRASG_BLDG_CODE,
          HOUSING.SLRRASG_ROOM_NUMBER,
          HOUSING.SLRRASG_ASCD_CODE,
          FAFSA.RVQ_FAFSA_CURRENT_RECORD_IND,
          FNAID_VERF_ST."Verification_status",
          CASE WHEN AWRD_ACC.RPRAWRD_PIDM IS NULL THEN 'N' ELSE 'Y' END,
          AWRD_ACC."Accepted_Amt",
          CASE WHEN AWARD_OFRD."Offer_IND" IS NOT NULL THEN 'Y' ELSE 'N' END,
          AWRD_ACC."Offer_amt",
          AT_DEPOSITS.DEPOSIT_DETAIL_DESC,
          TBRDEPO.TBRDEPO_AMOUNT,
          AT_DEPOSITS.DEPOSIT_BALANCE,
          CASE WHEN SORHSCH.SORHSCH_GRADUATION_DATE IS NOT NULL
     AND SORHSCH.SORHSCH_TRANS_RECV_DATE IS NOT NULL
     AND SORHSCH.SORHSCH_ADMR_CODE IS NOT NULL
     THEN 'Y'
     ELSE 'N'
END
 order by AA.LAST_NAME
;