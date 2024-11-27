import pandas as pd
import mysql.connector
import os
from openpyxl import Workbook
from datetime import datetime
import subprocess
import time
from config import *
from config import establish_ssh_connection, get_db_config

# Example: Choose environment and database (DB)
environment = "devx"
db = "dev1"

establish_ssh_connection(environment)

db_config = get_db_config(environment, db)

# Function to get the full SQL file name
def get_full_sql_filename(sql_file):
    return os.path.basename(sql_file)

# Directories for CSV, SQL, and results
csv_dir = '/Users/shaliniolivera/Documents/Automation/LSH_Premium/csv'
sql_dir = '/Users/shaliniolivera/Documents/Automation/LSH_Premium/sql'
result_dir = '/Users/shaliniolivera/Documents/Automation/LSH_Premium/result'

# List of CSV file names and SQL query files to compare
csv_files = ['staff_all.csv', 'child_all.csv']
sql_files = ['staff_db.sql', 'child_db.sql']

# Generate full paths for the CSV and SQL files
csv_files_to_process = [os.path.join(csv_dir, f) for f in csv_files]
sql_files_to_process = [os.path.join(sql_dir, f) for f in sql_files]

# Create a new workbook and add two sheets
wb = Workbook()
ws_processed = wb.active
ws_processed.title = "Processed"
ws_processed.append(["CSV File Name", "Query Name", "Status", "Date Executed"])

ws_discrepancy = wb.create_sheet(title="Discrepancies")
ws_discrepancy.append(["CSV File Name", "Query Name", "Affected ID", "Reason for Discrepancy", "Column with Discrepancy", "CSV Value", "DB Value", "Date Executed"])

# Function to handle numeric values for comparison (with handling for leading zeros)
def handle_numeric_comparison(csv_value, db_value):
    if isinstance(csv_value, str) and isinstance(db_value, str):
        return csv_value.strip(), db_value.strip()
    
    try:
        csv_value = float(csv_value)
    except (ValueError, TypeError):
        csv_value = 0.0
    
    try:
        db_value = float(db_value)
    except (ValueError, TypeError):
        db_value = 0.0
    
    return round(csv_value, 2), round(db_value, 2)

# Connect to MySQL database using the selected environment's configuration
db_conn = mysql.connector.connect(**db_config)
cursor = db_conn.cursor()

# Get current date for timestamp
current_date = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

# Iterate over each CSV file and corresponding SQL query
for csv_file, sql_file in zip(csv_files_to_process, sql_files_to_process):
    csv_data = pd.read_csv(csv_file)

    with open(sql_file, 'r') as file:
        query = file.read()

    table_name = get_full_sql_filename(sql_file)

    cursor.execute(query)
    db_data = cursor.fetchall()

    db_columns = [desc[0] for desc in cursor.description]
    db_df = pd.DataFrame(db_data, columns=db_columns)

    differences = []
    csv_data.set_index('id', inplace=True)
    db_df.set_index('id', inplace=True)

    for id_value in csv_data.index:
        if id_value in db_df.index:
            csv_row = csv_data.loc[id_value]
            db_row = db_df.loc[id_value]
            row_diff = []

            for col in csv_data.columns:
                csv_value = csv_row[col]
                db_value = db_row[col]

                if (pd.isna(csv_value) or csv_value == '') and (pd.isna(db_value) or db_value == ''):
                    continue

                if pd.isna(csv_value) or csv_value == '':
                    row_diff.append((col, f"DISCREPANCY: CSV is NaN or blank, DB has value | CSV: {csv_value} | DB: {db_value}"))
                elif pd.isna(db_value) or db_value == '':
                    row_diff.append((col, f"DISCREPANCY: CSV has value, DB is NaN or blank | CSV: {csv_value} | DB: {db_value}"))
                else:
                    csv_value, db_value = handle_numeric_comparison(csv_value, db_value)

                    csv_value_str = str(csv_value).strip() if csv_value is not None else ""
                    db_value_str = str(db_value).strip() if db_value is not None else ""
                    if csv_value_str != db_value_str:
                        row_diff.append((col, f"DISCREPANCY: CSV value != DB value | CSV: {csv_value_str} | DB: {db_value_str}"))

            if row_diff:
                differences.append((id_value, row_diff))
        else:
            differences.append((id_value, 'ID not found in DB'))

    for id_value in db_df.index:
        if id_value not in csv_data.index:
            differences.append((id_value, 'ID missing from CSV'))

    # Print raw logs without formatting
    print(f"{os.path.basename(csv_file)} {table_name} ", end="")
    if not differences:
        print("MATCH")
    else:
        print("DISCREPANCY FOUND")
        for id_value, row_diff in differences:
            if isinstance(row_diff, str):
                reason = "ID not found in DB" if row_diff == 'ID not found in DB' else "ID missing from CSV"
                print(f"{os.path.basename(csv_file)} {table_name} {id_value} {reason}")
            else:
                for col, diff_status in row_diff:
                    # Ensuring there are no extra tabs or spaces
                    print(f"{os.path.basename(csv_file)} {table_name} {id_value} {diff_status.strip()}")

    if not differences:
        ws_processed.append([os.path.basename(csv_file), table_name, "MATCH", current_date])
    else:
        ws_processed.append([os.path.basename(csv_file), table_name, "DISCREPANCY FOUND", current_date])

    if differences:
        for id_value, row_diff in differences:
            if isinstance(row_diff, str):
                reason = "ID not found in DB" if row_diff == 'ID not found in DB' else "ID missing from CSV"
                ws_discrepancy.append([os.path.basename(csv_file), table_name, id_value, reason, "", "", "", current_date])
            else:
                for col, diff_status in row_diff:
                    reason = diff_status.split(":")[1].split("|")[0].strip() if "DISCREPANCY:" in diff_status else diff_status
                    csv_value = diff_status.split("|")[1].replace("CSV: ", "").strip() if "CSV: " in diff_status else ""
                    db_value = diff_status.split("|")[2].replace("DB: ", "").strip() if "DB: " in diff_status else ""

                    ws_discrepancy.append([os.path.basename(csv_file), table_name, id_value, reason, col, csv_value, db_value, current_date])

# Generate the results file
file_name = os.path.join(result_dir, f"csv_vs_db_comparison_results_{datetime.now().strftime('%Y-%m-%d_%H-%M-%S')}.xlsx")

# Save the workbook
wb.save(file_name)

# Close MySQL connection
cursor.close()
db_conn.close()

# Print final result
print(f"Comparison results saved to: {file_name}")
