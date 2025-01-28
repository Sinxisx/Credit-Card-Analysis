WITH
GCIF_BAL AS (SELECT DISTINCT 
BASE_DT,
APPL_ID,
GCIF_NO,
SUM(BAL) AS BAL_SUM
FROM PDA.MASTER_LOAN
WHERE BASE_DT LIKE '20'||'{ym}'||'%'
AND APPL_ID IN ('CP','XP')
GROUP BY BASE_DT,APPL_ID,GCIF_NO
),

AGG_BAL AS (SELECT
'{dt}' AS BASE_DT,
g.GCIF_NO,
g.APPL_ID,
MAX(g.BAL_SUM) MTD_MAX_OS,
AVG(g.BAL_SUM) MTD_AVG_OS
FROM GCIF_BAL g
GROUP BY g.GCIF_NO, g.APPL_ID
)


SELECT * FROM AGG_BAL