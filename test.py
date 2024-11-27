import pandas as pd
import mysql.connector
import os
from openpyxl import Workbook
from datetime import datetime
from db_config import *

# Function to get the full SQL file name
def get_full_sql_filename(sql_file):
    return os.path.basename(sql_file)

# Directories for CSV, SQL, and results
csv_dir = '/Users/shaliniolivera/Documents/Automation/LSH_Premium/csv'
sql_dir = '/Users/shaliniolivera/Documents/Automation/LSH_Premium/sql'
result_dir = '/Users/shaliniolivera/Documents/Automation/LSH_Premium/result'

# List of CSV file names and SQL query files
csv_files = ['staff_all.csv', 'child_all.csv']
sql_files = ['staff_db.sql', 'child_db.sql']

# Generate full paths for the CSV and SQL files
csv_files_to_process = [os.path.join(csv_dir, f) for f in csv_files]
sql_files_to_process = [os.path.join(sql_dir, f) for f in sql_files]

# Create a new workbook and add two sheets: Processed and Discrepancies
wb = Workbook()
ws_processed = wb.active
ws_processed.title = "Processed"
ws_processed.append(["CSV File Name", "Query Name", "Status", "Date Executed"])

ws_discrepancy = wb.create_sheet(title="Discrepancies")
ws_discrepancy.append(["CSV File Name", "Query Name", "Affected ID", "Reason for Discrepancy", "Column with Discrepancy", "CSV Value", "DB Value", "Date Executed"])

# Connect to MySQL database
db_conn = mysql.connector.connect(**dev1)
cursor = db_conn.cursor()

# Get current date for timestamp
current_date = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

# Function to handle numeric values for comparison (with handling for leading zeros)
def handle_numeric_comparison(csv_value, db_value):
    # Check if the values are numeric
    if isinstance(csv_value, str) and isinstance(db_value, str):
        # If both are strings, preserve the leading zeros by not converting them to float
        return csv_value.strip(), db_value.strip()
    
    try:
        csv_value = float(csv_value)
    except (ValueError, TypeError):
        csv_value = 0.0
    
    try:
        db_value = float(db_value)
    except (ValueError, TypeError):
        db_value = 0.0
    
    # Round both values to 2 decimal places for comparison
    return round(csv_value, 2), round(db_value, 2)

# Iterate over each CSV file and corresponding SQL query
for csv_file, sql_file in zip(csv_files_to_process, sql_files_to_process):
    csv_data = pd.read_csv(csv_file)

    # Print column names to help debug
    print(f"CSV Columns: {csv_data.columns.tolist()}")

    # Check for the existence of the 'id' column in CSV
    if 'id' not in csv_data.columns:
        print(f"Error: 'id' column is missing in CSV file {csv_file}. Skipping file.")
        continue  # Skip this CSV file if 'id' column is missing

    # Clean column names by removing spaces and replacing any special characters
    csv_data.columns = csv_data.columns.str.strip().str.replace(r'\s+', '', regex=True)

    # Read the SQL query from an external file
    with open(sql_file, 'r') as file:
        query = file.read()

    table_name = get_full_sql_filename(sql_file)

    # Query the DB
    cursor.execute(query)
    db_data = cursor.fetchall()

    # Convert DB data to DataFrame
    db_columns = [desc[0] for desc in cursor.description]
    db_df = pd.DataFrame(db_data, columns=db_columns)

    # Print column names to help debug
    print(f"DB Columns: {db_df.columns.tolist()}")

    # Ensure 'id' column exists in DB
    if 'id' not in db_df.columns:
        print(f"Error: 'id' column is missing in DB data for query {table_name}. Skipping file.")
        continue  # Skip if 'id' column is missing in the DB data

    # Handle duplicates in CSV and DB by grouping them by ID
    csv_data_grouped = csv_data.groupby('id', as_index=False).first()  # Keep the first row for each ID (or apply aggregation if needed)
    db_df_grouped = db_df.groupby('id', as_index=False).first()  # Same logic for DB

    # Manually compare the rows based on ID
    differences = []
    csv_data_grouped.set_index('id', inplace=True)
    db_df_grouped.set_index('id', inplace=True)

    for id_value in csv_data_grouped.index:
        if id_value in db_df_grouped.index:
            csv_row = csv_data_grouped.loc[id_value]
            db_row = db_df_grouped.loc[id_value]
            row_diff = []

            for col in csv_data.columns:
                csv_value = csv_row[col]
                db_value = db_row[col]

                # Skip discrepancy if both CSV and DB values are empty or NaN
                if (pd.isna(csv_value) or csv_value == '') and (pd.isna(db_value) or db_value == ''):
                    continue  # No discrepancy if both are NaN or blank

                if pd.isna(csv_value) or csv_value == '':
                    row_diff.append((col, f"DISCREPANCY: CSV is NaN or blank, DB has value | CSV: {csv_value} | DB: {db_value}"))
                elif pd.isna(db_value) or db_value == '':
                    row_diff.append((col, f"DISCREPANCY: CSV has value, DB is NaN or blank | CSV: {csv_value} | DB: {db_value}"))
                else:
                    # Handle numeric columns for comparison (whole numbers or decimals)
                    csv_value, db_value = handle_numeric_comparison(csv_value, db_value)

                    # If neither value is NaN or blank, do the regular comparison
                    csv_value_str = str(csv_value).strip() if csv_value is not None else ""
                    db_value_str = str(db_value).strip() if db_value is not None else ""
                    if csv_value_str != db_value_str:
                        row_diff.append((col, f"DISCREPANCY: CSV value != DB value | CSV: {csv_value_str} | DB: {db_value_str}"))

            if row_diff:
                differences.append((id_value, row_diff))
        else:
            differences.append((id_value, 'ID not found in DB'))

    # Check for IDs in the DB that are missing in the CSV
    for id_value in db_df_grouped.index:
        if id_value not in csv_data_grouped.index:
            differences.append((id_value, 'ID missing from CSV'))

    # Record in the "Processed" tab, regardless of discrepancies
    if not differences:
        ws_processed.append([os.path.basename(csv_file), table_name, "MATCH", current_date])
    else:
        ws_processed.append([os.path.basename(csv_file), table_name, "DISCREPANCY FOUND", current_date])  # Indicate discrepancies

    # Output the discrepancies to the "Discrepancies" sheet
    if differences:
        for id_value, row_diff in differences:
            if isinstance(row_diff, str):  # If ID not found in DB or missing from CSV
                reason = "ID not found in DB" if row_diff == 'ID not found in DB' else "ID missing from CSV"
                ws_discrepancy.append([os.path.basename(csv_file), table_name, id_value, reason, "", "", "", current_date])
            else:
                for col, diff_status in row_diff:
                    # Extract reason for discrepancy and CSV/DB values
                    reason = diff_status.split(":")[1].split("|")[0].strip() if "DISCREPANCY:" in diff_status else diff_status
                    csv_value = diff_status.split("|")[1].replace("CSV: ", "").strip() if "CSV: " in diff_status else ""
                    db_value = diff_status.split("|")[2].replace("DB: ", "").strip() if "DB: " in diff_status else ""

                    # Append to discrepancies sheet with the cleaned reason and values
                    ws_discrepancy.append([os.path.basename(csv_file), table_name, id_value, reason, col, csv_value, db_value, current_date])

# Generate a dynamic filename using the current date
file_name = os.path.join(result_dir, f"csv_vs_db_comparison_results_{datetime.now().strftime('%Y-%m-%d_%H-%M-%S')}.xlsx")

# Save the workbook to a local file with the dynamic filename
wb.save(file_name)

# Close the cursor and database connection
cursor.close()
db_conn.close()

# Print out the file name to confirm
print(f"Comparison results saved to: {file_name}")
