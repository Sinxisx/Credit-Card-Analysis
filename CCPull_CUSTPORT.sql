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
WHEN PASTDUE_DAYS > 1 AND PASTDUE_DAYS <= 30 THEN 'GRACE PERIOD'
WHEN PASTDUE_DAYS > 30 THEN 'DELINQUENT'
END AS CC_STATUS
FROM PDA.MASTER_LOAN
WHERE BASE_DT = '{dt}'
AND PRD_NM LIKE '%Credit Card%'
AND STATUS = '00001'),
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
)
SELECT *
FROM ML LEFT JOIN C360 ON ML.GCIF_NO = C360.GCIF_NO