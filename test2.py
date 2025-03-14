#handling duplicate IDs and those queries without created_at
import pandas as pd
import mysql.connector
import os
from openpyxl import Workbook
from datetime import datetime
from db_config import *
from columns_config import columns_to_verify

# Directories
sql_dir = '/Users/shaliniolivera/Documents/Automation/LSH_Premium/queries'
result_dir = '/Users/shaliniolivera/Documents/Automation/LSH_Premium/result'

# List of SQL query file names
sql_files = [
    # ('qa_child_details.sql', 'dev_child_profile.sql'),
    # ('qa_parent_details.sql', 'dev_child_profile.sql'),
    # ('qa_child_attributes.sql', 'dev_child_profile.sql'),
    # ('qa_doctor_details.sql', 'dev_child_profile.sql'),
    # ('qa_immunization.sql', 'dev_child_profile.sql'),
    # ('qa_physicalConditions.sql', 'dev_child_profile.sql'),
    # ('qa_specialNeeds.sql', 'dev_child_profile.sql'),
    # ('qa_foodAllergies.sql', 'dev_child_profile.sql'),
    # ('qa_nonFoodAllergies.sql', 'dev_child_profile.sql'),
    # ('qa_guardian_data.sql', 'dev_guardian_data.sql'),
    # ('qa_centre_data.sql', 'dev_centre_data.sql'),
    # ('qa_discount_item.sql', 'dev_discount_item.sql'),
    # ('qa_billable_item.sql', 'dev_billable_item.sql'),
    # ('qa_child_level.sql', 'dev_child_level.sql'),
    # ('qa_class_info.sql', 'dev_class_info.sql'),
    # ('qa_child_class.sql', 'dev_child_class.sql'),
    # ('qa_giro_account.sql','dev_giro_account.sql'),
    ('qa_discount_arrangement.sql','dev_discount_arrangement.sql')
]

# Create a new workbook
wb = Workbook()
ws_processed = wb.active
ws_processed.title = "Processed"
ws_processed.append(["SQL Files Verified", "Status", "Mismatched Count", "Date Executed"])

# Connect to MySQL database
db_conn = mysql.connector.connect(**dev1)
cursor = db_conn.cursor()

current_date = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

def execute_query(query, query_name):
    """Executes a query and returns data with column names, handling errors."""
    try:
        cursor.execute(query)
        data = cursor.fetchall()
        
        if cursor.description is None:
            print(f"⚠️ WARNING: No data returned for {query_name}.")
            return None, None
        
        columns = [desc[0] for desc in cursor.description]
        return data, columns
    
    except mysql.connector.Error as err:
        print(f"❌ ERROR: Query execution failed for {query_name}: {err}")
        return None, None

for query1_file, query2_file in sql_files:
    print(f"🔍 Verifying SQL Files: {query1_file} and {query2_file}...")  
    
    with open(os.path.join(sql_dir, query1_file), 'r') as file:
        query1 = file.read()
    with open(os.path.join(sql_dir, query2_file), 'r') as file:
        query2 = file.read()

    data1, columns1 = execute_query(query1, query1_file)
    data2, columns2 = execute_query(query2, query2_file)

    if data1 is None or data2 is None:
        ws_processed.append([f"{query1_file} | {query2_file}", "FAILED", "N/A", current_date])
        continue

    df1 = pd.DataFrame(data1, columns=columns1)
    df2 = pd.DataFrame(data2, columns=columns2)

    comparison_columns = columns_to_verify.get((query1_file, query2_file), df1.columns.intersection(df2.columns).tolist())
    sheet_name = f"{query1_file} vs {query2_file}".replace('.sql', '').replace('_', ' ')[:31]  
    ws_discrepancy = wb.create_sheet(title=sheet_name)
    header = ["Overall Result", "QA Query", "Dev Query", "ID"]
    
    for col in comparison_columns:
        header.extend([f"{col} Status", f"{col} - QA Query", f"{col} - Dev Query"])
    header.append("Date Executed")
    
    ws_discrepancy.append(header)

    has_mismatch = False
    mismatch_count = 0
    
    # Merge both datasets and identify sorting column
    df1["Source"] = "QA"
    df2["Source"] = "Dev"
    all_records = pd.concat([df1, df2])

    # Determine sorting columns dynamically
    sort_columns = ["id"]
    if "created_at" in all_records.columns:
        sort_columns.append("created_at")

    all_records = all_records.sort_values(by=sort_columns)

    grouped = all_records.groupby("id", group_keys=False)
    
    for id_value, group in grouped:
        qa_rows = group[group["Source"] == "QA"].drop(columns=["Source"], errors="ignore")
        dev_rows = group[group["Source"] == "Dev"].drop(columns=["Source"], errors="ignore")
        
        # Ensure sorting consistency for comparison
        qa_rows = qa_rows.sort_values(by=comparison_columns, ascending=True).reset_index(drop=True)
        dev_rows = dev_rows.sort_values(by=comparison_columns, ascending=True).reset_index(drop=True)
        
        max_length = max(len(qa_rows), len(dev_rows))

        for i in range(max_length):
            qa_row = qa_rows.iloc[i] if i < len(qa_rows) else pd.Series(dtype=object)
            dev_row = dev_rows.iloc[i] if i < len(dev_rows) else pd.Series(dtype=object)

            overall_status = "MATCH"
            row_data = [query1_file, query2_file, id_value]

            for col in comparison_columns:
                value1 = str(qa_row.get(col, "N/A")).strip()
                value2 = str(dev_row.get(col, "N/A")).strip()
                status = "MATCH" if value1 == value2 else "MISMATCH"
                if status == "MISMATCH":
                    overall_status = "MISMATCH"
                    has_mismatch = True
                    mismatch_count += 1
                row_data.extend([status, value1, value2])

            row_data.append(current_date)
            ws_discrepancy.append([overall_status] + row_data)

    final_status = "MISMATCH" if has_mismatch else "MATCH"
    ws_processed.append([f"{query1_file} | {query2_file}", final_status, mismatch_count, current_date])

file_name = os.path.join(result_dir, f"sql_comparison_{datetime.now().strftime('%Y-%m-%d_%H-%M-%S')}.xlsx")
wb.save(file_name)

cursor.close()
db_conn.close()

print(f"✅ Comparison results saved to: {file_name}")
