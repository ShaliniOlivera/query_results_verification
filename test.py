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
    ('qa_child_details.sql', 'dev_child_profile.sql'),
    ('qa_parent_details.sql', 'dev_child_profile.sql'),
    ('qa_child_attributes.sql', 'dev_child_profile.sql'),
    ('qa_doctor_details.sql', 'dev_child_profile.sql'),
    ('qa_immunization.sql', 'dev_child_profile.sql'),
    ('qa_physicalConditions.sql', 'dev_child_profile.sql'),
    ('qa_specialNeeds.sql', 'dev_child_profile.sql'),
    ('qa_foodAllergies.sql', 'dev_child_profile.sql'),
    ('qa_nonFoodAllergies.sql', 'dev_child_profile.sql'),
    ('qa_guardian_data.sql', 'dev_guardian_data.sql'),
    ('qa_centre_data.sql', 'dev_centre_data.sql'),
    ('qa_discount_item.sql', 'dev_discount_item.sql'),
    ('qa_child_fee_tier.sql', 'dev_child_fee_tier.sql')
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

    if 'id' not in df1.columns or 'id' not in df2.columns:
        print(f"❌ ERROR: 'id' column missing in one of the datasets ({query1_file}, {query2_file})")
        ws_processed.append([f"{query1_file} | {query2_file}", "FAILED (Missing ID)", "N/A", current_date])
        continue

    df1.set_index('id', inplace=True)
    df2.set_index('id', inplace=True)

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

    for id_value in df1.index.union(df2.index):
        row1 = df1.loc[id_value] if id_value in df1.index else None
        row2 = df2.loc[id_value] if id_value in df2.index else None

        if isinstance(row1, pd.DataFrame):
            row1 = row1.iloc[-1]  # Take the latest entry if multiple exist
        if isinstance(row2, pd.DataFrame):
            row2 = row2.iloc[-1]

        row1 = row1.fillna("N/A") if row1 is not None else pd.Series(["N/A"] * len(comparison_columns), index=comparison_columns)
        row2 = row2.fillna("N/A") if row2 is not None else pd.Series(["N/A"] * len(comparison_columns), index=comparison_columns)

        overall_status = "MATCH"
        row_data = [query1_file, query2_file, id_value]

        for col in comparison_columns:
            value1 = str(row1[col]).strip() if col in row1 else "N/A"
            value2 = str(row2[col]).strip() if col in row2 else "N/A"
            
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
