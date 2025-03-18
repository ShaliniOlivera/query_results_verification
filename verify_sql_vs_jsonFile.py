import pandas as pd
import mysql.connector
import os
import json
from openpyxl import Workbook
from datetime import datetime
from db_config import ms_dev02
from columns_config import columns_to_verify

def normalize_data(df, source):
    """Normalizes data structure and format for consistency."""
    if df is None or df.empty:
        return None

    # Standardize column names
    df.columns = df.columns.str.lower()

    # Flatten `columns_to_verify` dictionary and ensure all expected columns exist
    expected_columns = {col for cols in columns_to_verify.values() for col in cols}

    missing_cols = [col for col in expected_columns if col not in df.columns]
    df = pd.concat([df, pd.DataFrame(columns=missing_cols)], axis=1)

    # Convert date formats to ISO 8601
    date_columns = [col for col in df.columns if 'date' in col or 'time' in col]
    for col in date_columns:
        df[col] = pd.to_datetime(df[col], errors='coerce').dt.strftime('%Y-%m-%dT%H:%M:%SZ')

    # Flatten nested structures
    for col in ["centres", "classes"]:
        if col in df.columns:
            df[col] = df[col].apply(lambda x: json.dumps(x) if isinstance(x, (dict, list)) else x)

    return df

# Directories
sql_dir = '/Users/shaliniolivera/Documents/Automation/LSH_Premium/queries'
result_dir = '/Users/shaliniolivera/Documents/Automation/LSH_Premium/result_jsonQuery_verification'
json_dir = '/Users/shaliniolivera/Documents/Automation/LSH_Premium/json_files'

# SQL and JSON file mapping
sql_json_pairs = [('qa_foliettes.sql', 'lsh_premium_observation.json')]

# Create Excel workbook
wb = Workbook()
ws_processed = wb.active
ws_processed.title = "Processed"
ws_processed.append(["SQL Query", "JSON File", "Status", "Mismatched Count", "Date Executed"])

# Database connection
db_conn = mysql.connector.connect(**ms_dev02)
cursor = db_conn.cursor()
current_date = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

def execute_query(query):
    """Executes SQL query and returns a Pandas DataFrame."""
    cursor.execute(query)
    data = cursor.fetchall()
    if not data or cursor.description is None:
        return None
    columns = [desc[0].lower() for desc in cursor.description]
    return pd.DataFrame(data, columns=columns)

def load_json_file(json_path):
    """Loads JSON file into a Pandas DataFrame."""
    with open(json_path, "r", encoding="utf-8") as file:
        data = json.load(file)
    return pd.DataFrame(data) if isinstance(data, list) else pd.DataFrame([data])

# Process SQL and JSON comparisons
for sql_file, json_file in sql_json_pairs:
    with open(os.path.join(sql_dir, sql_file), 'r') as file:
        query = file.read()

    df_sql = normalize_data(execute_query(query), 'SQL')
    df_json = normalize_data(load_json_file(os.path.join(json_dir, json_file)), 'JSON')

    if df_sql is None or df_json is None:
        ws_processed.append([sql_file, json_file, "FAILED", "N/A", current_date])
        continue

    # Get comparison columns, defaulting to the intersection of available columns
    comparison_columns = columns_to_verify.get((sql_file, json_file), list(df_sql.columns.intersection(df_json.columns)))

    has_mismatch = False
    mismatch_count = 0

    df_sql['Source'] = 'SQL'
    df_json['Source'] = 'JSON'
    all_records = pd.concat([df_sql, df_json])

    # Sorting logic
    sort_columns = ["id"]
    if "created_at" in all_records.columns:
        sort_columns.append("created_at")

    all_records = all_records.sort_values(by=sort_columns)
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
            for col in comparison_columns:
                value_sql = str(sql_row.get(col, "N/A")).strip()
                value_json = str(json_row.get(col, "N/A")).strip()
                if value_sql != value_json:
                    overall_status = "MISMATCH"
                    has_mismatch = True
                    mismatch_count += 1

    final_status = "MISMATCH" if has_mismatch else "MATCH"
    ws_processed.append([sql_file, json_file, final_status, mismatch_count, current_date])

# Save Excel file
file_name = os.path.join(result_dir, f"sql_json_comparison_{datetime.now().strftime('%Y-%m-%d_%H-%M-%S')}.xlsx")
wb.save(file_name)

# Cleanup
cursor.close()
db_conn.close()

print(f"✅ Comparison results saved to: {file_name}")
