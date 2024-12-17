WITH 
ML AS (
SELECT DISTINCT 
BASE_DT, 
AGREE_ID, 
GCIF_NO, 
CIF_NO, 
NOTE_NO, 
PRD_TP, 
PRD_NM,
PRD_SEGMENT, 
ORG_LMT_AMT, 
CURR_LMT_AMT, 
BAL, 
ORIG_INT_RT, 
CURR_INT_RT, 
OTH_CURR_INT_RT,
LAST_RNWL_DT,
ORIG_MAT_DT,
CURR_MAT_DT,
TENOR,
DAYS_REMAIN,
CLCT_RTNG_FCL, 
ALLOW_PCT, 
ALLOW_PCT_ADD, 
RESTRUCT_CD, 
PASTDUE_SINCE_DT,
PASTDUE_DAYS, 
WRITE_OFF_AMT,
WRITE_OFF_DT, 
WRITE_OFF_YN,
CASE WHEN PASTDUE_DAYS = 0 THEN 'PERFORMING'
WHEN PASTDUE_DAYS >= 1 AND PASTDUE_DAYS <= 30 THEN 'GRACE PERIOD'
WHEN PASTDUE_DAYS > 30 THEN 'DELINQUENT'
END AS CC_STATUS
FROM PDA.MASTER_LOAN
WHERE BASE_DT = '{dt}'
AND PRD_NM LIKE '%Credit Card%'),
C360 AS (
SELECT DISTINCT
GCIF_NO, 
LOB AS SEGMENT, 
CUST_NM, 
OPENDATE AS OPEN_DATE, 
LAST_ACTIVE_DATE,
CUST_TP, 
GENDER_CD, 
AGE,
CASE WHEN AGE>=50 THEN 'SAGA'
ELSE 'NON-SAGA'
END AS SAGA_FLAG,
EMPLOYMENT_TYPE, 
CA_BAL, 
CA_AVG,
SA_BAL, 
SA_AVG, 
TD_NOA, 
TD_BAL, 
TD_AVG,
SY_FUNDING_BAL, 
SY_FUNDING_AVG, 
FUNDING_NOA, 
FUNDING_BAL,
FUNDING_AVG, 
NOA_DORMANT, 
CC_PLAFOND, 
CC_BAL, 
PL_PLAFOND, 
PLOAN_BAL, 
TR_PLAFOND, 
TR_BAL, 
PB_PLAFOND, 
PB_BAL, 
PRK_PLAFOND, 
PRK_BAL, 
PPB_PLAFOND, 
PPB_BAL, 
BG_PLAFOND,
BG_BAL, 
LC_PLAFOND, 
LC_BAL, 
SYARIAHLOAN_PLAFOND AS SY_LOAN_PLAFOND, 
SYARIAHLOAN_BAL AS SY_LOAN_BAL,
KPR_PLAFOND, 
KPR_BAL, 
KPM_PLAFOND, 
KPM_BAL, 
KOLEK AS COLLECT,
MF_BAL, 
ORI_BAL AS BONDS_BAL,
TRB,
M2U_TRX AS M2U_TRX_TOTAL, 
M2U_TRXAMT_FIN, 
CRTRX AS CRTRX_MTD, 
CRTRXAMT AS CRTRX_AMT_MTD, 
DBTRX AS DBTRX_MTD,
DBTRXAMT AS DBTRX_AMT_MTD
FROM PDA.CUSTOMER_PORTFOLIO_{ym}
),
CECE AS (
SELECT DISTINCT GCIF_NO,CARD_NMBR
FROM PDA.TBL_BAL_CC
WHERE BASE_DT = '{dt}'
AND STATUS IN (1,2) 
AND CARD_NMBR NOT LIKE '8%' 
AND CRLIMIT>0
AND (Block_Code is null
OR Block_code in(' ','C','H','P','Y','M','K','B')
OR (Block_code = 'U' and user_code2 not in ('RP','PZ','MX','KD','KE','BV','PB','PF','HT','PE','PO','PU','XU','XP','PW','SM'))
OR (Block_code in ('I','R','L','S','J','A','Q','W','N','O','G','F','D') and Curr_balance > 0)
OR (Block_code='Z' and user_code2 not in ('RP','PZ','MX','KD','KE','BV','PB','PF','HT','PE','PO','PU','XU','XP','PW','SM') and curr_balance > 0)
OR (block_code='E' and Curr_balance > 0)
OR (Block_Code = 'T' and Curr_balance = 0 and EXPIRE2 > '{ym}'))
),
ML_BAL AS(
SELECT DISTINCT 
AGREE_ID,
MAX(BAL) MTD_MAX_BAL
FROM PDA.MASTER_LOAN
WHERE BASE_DT LIKE '20'||'{ym}'||'%'
AND PRD_NM LIKE '%Credit Card%'
GROUP BY AGREE_ID
)
SELECT *
FROM CECE 
INNER JOIN ML 
ON CECE.CARD_NMBR = ML.NOTE_NO
INNER JOIN C360 
ON CECE.GCIF_NO = C360.GCIF_NO
LEFT JOIN ML_BAL
ON ML.AGREE_ID = ML_BAL.AGREE_ID