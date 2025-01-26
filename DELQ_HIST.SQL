WITH 
main as (
SELECT
{dt} AS BASE_DT,
a.ORG,
a.TYPE,
a.CUSTOMER_ORG,
a.CARD_NMBR,
a.CARD_TYPE_1,
a.BLOCK_CODE,
a.ALT_BLOCK_CODE,
a.USER_CODE2,
a.CURR_BALANCE,
a.RI_RATE_1 as RATE,
a.DTE_OPENED,
a.STATUS,
a.CRLIMIT,
a.LST_CRLIMIT,
a.CARD_EXPIR_DTE,
a.DELQ_HIST_1,
a.DELQ_HIST_2,
a.DELQ_HIST_3,
a.DELQ_HIST_4,
a.DELQ_HIST_5,
a.DELQ_HIST_6,
a.DELQ_HIST_7,
a.DELQ_HIST_8,
a.DELQ_HIST_9,
a.DELQ_HIST_10,
a.DELQ_HIST_12,
a.DELQ_HIST_13,
a.DELQ_HIST_14,
a.DELQ_HIST_15,
a.DELQ_HIST_16,
a.DELQ_HIST_17,
a.DELQ_HIST_18,
a.DELQ_HIST_18,
a.DELQ_HIST_19,
a.DELQ_HIST_20,
a.DELQ_HIST_21,
a.DELQ_HIST_22,
a.DELQ_HIST_23,
a.DELQ_HIST_24
FROM brgprod.V_CPCR{dt} a
WHERE a.ORG = 1 and a.STATUS in(1,2)
),

main_cc as(
SELECT z.*,
SUBSTR(z.EXPIRE,3,2)||SUBSTR(z.EXPIRE,1,2) as EXPIRE2
FROM (select 
a.*,
LPAD(a.CARD_EXPIR_DTE, 4, '0') as EXPIRE
from main a)z
),

final_cc as(
SELECT
main_cc.*
FROM main_cc
WHERE
Block_Code is null
OR Block_code in(' ','C','H','P','Y','M','K','B')
OR (Block_code = 'U' and user_code2 not in ('RP','PZ','MX','KD','KE','BV','PB','PF','HT','PE','PO','PU','XU','XP','PW','SM'))
OR (Block_code in ('I','R','L','S','J','A','Q','W','N','O','G','F','D') and Curr_balance <> 0)
OR (Block_code='Z' and user_code2 not in ('RP','PZ','MX','KD','KE','BV','PB','PF','HT','PE','PO','PU','XU','XP','PW','SM') and curr_balance <> 0)
OR (block_code='E' and Curr_balance > 0)
OR (Block_Code = 'T' and Curr_balance = 0 and EXPIRE2 > '{ym}'))

SELECT 
BASE_DT,
CARD_NMBR,
DELQ_HIST_1,
DELQ_HIST_2,
DELQ_HIST_3,
DELQ_HIST_4,
DELQ_HIST_5,
DELQ_HIST_6,
DELQ_HIST_7,
DELQ_HIST_8,
DELQ_HIST_9,
DELQ_HIST_10,
DELQ_HIST_12,
DELQ_HIST_13,
DELQ_HIST_14,
DELQ_HIST_15,
DELQ_HIST_16,
DELQ_HIST_17,
DELQ_HIST_18,
DELQ_HIST_19,
DELQ_HIST_20,
DELQ_HIST_21,
DELQ_HIST_22,
DELQ_HIST_23,
DELQ_HIST_24
FROM final_cc