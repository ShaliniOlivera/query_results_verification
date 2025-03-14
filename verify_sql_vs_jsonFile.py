import pandas as pd
import mysql.connector
import os
import json
from openpyxl import Workbook
from datetime import datetime
from db_config import dev1  # Update as needed
from columns_config import columns_to_verify  # Custom column mapping

# Directories
sql_dir = '/Users/shaliniolivera/Documents/Automation/LSH_Premium/queries'
result_dir = '/Users/shaliniolivera/Documents/Automation/LSH_Premium/result_jsonQuery_verification'
json_dir = '/Users/shaliniolivera/Documents/Automation/LSH_Premium/json_files'  # JSON storage path

# SQL and JSON file mapping
sql_json_pairs = [
    ('qa_class_activity.sql', 'class_activity.json')
]

# Create a new workbook
wb = Workbook()
ws_processed = wb.active
ws_processed.title = "Processed"
ws_processed.append(["SQL Query", "JSON File", "Status", "Mismatched Count", "Date Executed"])

# Connect to MySQL database
db_conn = mysql.connector.connect(**dev1)
cursor = db_conn.cursor()

current_date = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

def execute_query(query, query_name):
    """Executes an SQL query and returns the result as a DataFrame."""
    try:
        cursor.execute(query)
        data = cursor.fetchall()

        if cursor.description is None:
            print(f"⚠️ WARNING: No data returned for {query_name}.")
            return None

        columns = [desc[0] for desc in cursor.description]
        return pd.DataFrame(data, columns=columns)

    except mysql.connector.Error as err:
        print(f"❌ ERROR: Query execution failed for {query_name}: {err}")
        return None

def load_json_file(json_path):
    """Loads a JSON file into a Pandas DataFrame."""
    try:
        with open(json_path, "r", encoding="utf-8") as file:
            data = json.load(file)
        return pd.DataFrame(data) if isinstance(data, list) else pd.DataFrame([data])

    except Exception as e:
        print(f"❌ ERROR: Failed to load JSON {json_path}: {e}")
        return None

for sql_file, json_file in sql_json_pairs:
    print(f"🔍 Verifying SQL Query: {sql_file} vs JSON: {json_file}...")

    # Read SQL Query
    with open(os.path.join(sql_dir, sql_file), 'r') as file:
        query = file.read()

    df_sql = execute_query(query, sql_file)
    df_json = load_json_file(os.path.join(json_dir, json_file))

    if df_sql is None or df_json is None:
        ws_processed.append([sql_file, json_file, "FAILED", "N/A", current_date])
        continue

    # Identify comparison columns
    comparison_columns = columns_to_verify.get((sql_file, json_file), df_sql.columns.intersection(df_json.columns).tolist())

    # Create a new sheet for discrepancies
    sheet_name = f"{sql_file} vs {json_file}".replace('.sql', '').replace('_', ' ')[:31]
    ws_discrepancy = wb.create_sheet(title=sheet_name)
    header = ["Overall Result", "ID"]

    for col in comparison_columns:
        header.extend([f"{col} Status", f"{col} - SQL", f"{col} - JSON"])
    header.append("Date Executed")
    ws_discrepancy.append(header)

    has_mismatch = False
    mismatch_count = 0

    # Merge both datasets
    df_sql["Source"] = "SQL"
    df_json["Source"] = "JSON"
    all_records = pd.concat([df_sql, df_json])

    # Determine sorting columns dynamically
    sort_columns = ["id"]
    if "created_at" in all_records.columns:
        sort_columns.append("created_at")

    all_records = all_records.sort_values(by=sort_columns)

    # Group by ID
    grouped = all_records.groupby("id", group_keys=False)

    for id_value, group in grouped:
        sql_rows = group[group["Source"] == "SQL"].drop(columns=["Source"], errors="ignore")
        json_rows = group[group["Source"] == "JSON"].drop(columns=["Source"], errors="ignore")

        sql_rows = sql_rows.sort_values(by=comparison_columns, ascending=True).reset_index(drop=True)
        json_rows = json_rows.sort_values(by=comparison_columns, ascending=True).reset_index(drop=True)

        max_length = max(len(sql_rows), len(json_rows))

        for i in range(max_length):
            sql_row = sql_rows.iloc[i] if i < len(sql_rows) else pd.Series(dtype=object)
            json_row = json_rows.iloc[i] if i < len(json_rows) else pd.Series(dtype=object)

            overall_status = "MATCH"
            row_data = [id_value]

            for col in comparison_columns:
                value_sql = str(sql_row.get(col, "N/A")).strip()
                value_json = str(json_row.get(col, "N/A")).strip()
                status = "MATCH" if value_sql == value_json else "MISMATCH"
                if status == "MISMATCH":
                    overall_status = "MISMATCH"
                    has_mismatch = True
                    mismatch_count += 1
                row_data.extend([status, value_sql, value_json])

            row_data.append(current_date)
            ws_discrepancy.append([overall_status] + row_data)

    final_status = "MISMATCH" if has_mismatch else "MATCH"
    ws_processed.append([sql_file, json_file, final_status, mismatch_count, current_date])

# Save the Excel report
file_name = os.path.join(result_dir, f"sql_json_comparison_{datetime.now().strftime('%Y-%m-%d_%H-%M-%S')}.xlsx")
wb.save(file_name)

cursor.close()
db_conn.close()

print(f"✅ Comparison results saved to: {file_name}")
