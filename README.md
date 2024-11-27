what this does:

verify the discrepancies between the csv (path /csv) and the records pulled from the database based on the queries stored in the .sql file (path /sql)
this can verify multiple csv vs sql queries in one execution
after verification, it will export the result in a .xlsx file (destination is in the path /results) 3.1 file name is going to be "csv_vs_db_comparison_results_" 3.2 .xlsx file will contain 2 tabs | Processed , Discrepancies
Verification scope:

treats ID as unique and base each record verification on the unique id
discrepancies in terms of 2.1 missing value per record/column 2.2 missing id in the csv 2.3 missing id in the db
