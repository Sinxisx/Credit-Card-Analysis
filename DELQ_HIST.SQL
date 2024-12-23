WITH 
main as (
SELECT
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
a.DELQ_HIST_1
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

SELECT CARD_NMBR, DELQ_HIST_1 FROM final_cc