WITH main as (
             SELECT
                 a.ORG,
                 a.TYPE,
                 a.CUSTOMER_ORG,
                 a.CARD_NMBR,
                 a.CARD_TYPE_1,
                 b.gcif_no,
                 a.BLOCK_CODE,
                 a.ALT_BLOCK_CODE,
                 a.USER_CODE2,
                 a.CURR_BALANCE,
                 a.RI_RATE_1 as RATE,
                 a.DTE_OPENED,
                 a.STATUS,
                 a.CRLIMIT,
                 a.LST_CRLIMIT,
                 a.CARD_EXPIR_DTE
             FROM
                 brgprod.V_CPCR{YYMMDD} a left join
                 v_dcif_acct b on CAST(a.card_nmbr AS CHAR(20)) = CAST(b.acct_no AS CHAR(20))
             WHERE
                 a.ORG = 1 and a.STATUS in(1,2)
         ),main_cc as(
             SELECT z.*,
                 SUBSTR(z.EXPIRE,3,2)||SUBSTR(z.EXPIRE,1,2) as EXPIRE2
             FROM
                 (
                 select a.*,
                     LPAD(a.CARD_EXPIR_DTE, 4, '0') as EXPIRE
                 from main a
                 )z
         ),
         final_cc as(
         SELECT
             main_cc.*
         FROM
             main_cc
         WHERE
             Block_Code is null
             OR Block_code in(' ','C','H','P','Y','M','K','B')
             OR (Block_code = 'U' and user_code2 not in ('RP','PZ','MX','KD','KE','BV','PB','PF','HT','PE','PO','PU','XU','XP','PW','SM'))
             OR (Block_code in ('I','R','L','S','J','A','Q','W','N','O','G','F','D') and Curr_balance <> 0)
             OR (Block_code='Z' and user_code2 not in ('RP','PZ','MX','KD','KE','BV','PB','PF','HT','PE','PO','PU','XU','XP','PW','SM') and curr_balance <> 0)
             OR (block_code='E' and Curr_balance > 0)
             OR (Block_Code = 'T' and Curr_balance = 0 and EXPIRE2 > '{YYMM}')
         ),
         flagging_cc as(
             SELECT
                 a.*,
                 CASE
                     WHEN a.TYPE in (1,3,5,7,11,16,21,35,41,51,411,511,418) THEN 'CLASSIC'
                     WHEN a.TYPE in (2,4,6,8,17,36,42,421,521,428) THEN 'GOLD'
                     WHEN a.TYPE = 38 THEN (CASE
                                                 WHEN a.CARD_TYPE_1 = 93 THEN 'CLASSIC'
                                                 WHEN a.CARD_TYPE_1 = 94 THEN 'GOLD'
                                                 WHEN a.CARD_TYPE_1 = 95 THEN 'PLATINUM'
                                                 ELSE 'INFINITE'
                                             END)
                     WHEN a.TYPE in (22,30,33,431,531,631,438,532) THEN 'PLATINUM'
                     WHEN a.TYPE in (800) THEN 'SMEC'
                     ELSE 'INVALID'
                 END as PROD_TYPE,
                 CASE
                     WHEN substr(CARD_NMBR,1,1)='5' THEN 'MASTERCARD'
                     WHEN substr(CARD_NMBR,1,1)='4' THEN 'VISA'
                     WHEN substr(CARD_NMBR,1,1)='3' THEN 'JCB'
                     WHEN substr(CARD_NMBR,1,3)='886' THEN 'GORO'
                     WHEN substr(CARD_NMBR,1,3)='886' THEN 'PITA'
                     ELSE 'UNIDENTIFIED'
                 END as PRINCIPAL,
                 CASE
                     WHEN substr(CARD_NMBR,1,6)='545298' and user_code2 in ('NJ') THEN 1
                     WHEN substr(CARD_NMBR,1,6)='515595' THEN 1
                     ELSE 0
                 END as WC_FLAG, -- white card flag
                 CASE
                     WHEN (user_code2 in ('XB','CK','MS') and a.DTE_OPENED>=to_date('20190401','YYYYMMDD') and substr(CARD_NMBR,7,2)='92') THEN 1
                     ELSE 0
                 END as MFI_FLAG
             FROM main_cc a
         ),
         final AS (
             SELECT
                 '{YYYYMMDD}' as BASE_DT,
                 a.*,
                 CASE
                     WHEN WC_FLAG = 1 THEN 'WHITE CARD'
                     WHEN PROD_TYPE = 'INVALID' THEN PRINCIPAL
                     ELSE PRINCIPAL||' '||PROD_TYPE
                 END CARD_TYPE_FINAL,
                 TO_DATE({YYYYMMDD},'YYYYMMDD') as INGESTION_DT
             FROM flagging_cc a)
         SELECT * FROM final
