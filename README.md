# Credit Card Analysis
Project to analyze credit card performance in terms of multiple metrics such as number of customers, balance, demograpy, delinquency, written-off loans, etc.\
The content of this repository are files of scripts used to collect data from database and preliminary visualization using python (for now).\
The final analysis is stored in Google Bigquery and visualized in Looker Studio.\
SQL queries are separated for execution speed and ease of management.
## The files:
<pre>
1. Analysis.ipynb     : Python notebook of initial data exploration, the data is still missing several key informations.
2. Analysisv2.ipynb   : Attempt to explore final dataset, ran out of memory when reading the data.
3. CCPull_CP.sql      : Customer portfolio query.
4. CCPull_ML.sql      : Credit card loan data query.
5. CCPull_ML_Agg.sql  : Credit card aggregate loan balance query.
6. CCPull_ML_GPD.sql  : Credit card loan data query, grouped to customer level.
7. CCPull_ML_GPDv2.sql: Credit card loan data query, grouped to customer level, finalized.
8. DB Pull.ipynb      : Pyhton notebook to run and save the query results.
9. DELQ_HIST.SQL      : Credit card delinquency history query.
10. TBL_BAL_CC        : Reference script to handle credit card facility table.
</pre>
