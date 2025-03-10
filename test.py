import pandas as pd
import mysql.connector
import os
from openpyxl import Workbook
from datetime import datetime
from db_config import *

# Directories
sql_dir = '/Users/shaliniolivera/Documents/Automation/LSH_Premium/queries'
result_dir = '/Users/shaliniolivera/Documents/Automation/LSH_Premium/result'

# List of SQL query file names
sql_files = [
    ('qa_child_details.sql', 'dev_child_profile.sql'),
    ('qa_parent_details.sql', 'dev_child_profile.sql')
]

# Columns to verify (QA Query first)
columns_to_verify = {
    ('qa_child_details.sql', 'dev_child_profile.sql'): [
        "id", "child_firstname", "child_lastname", "child_birth_certificate",
        "date_of_birth", "gender", "race", "nationality", "profile_photo_storage_path", "current_level_enrolment_date",
        "current_centre_code", "current_level", "current_program", "current_class_enrolment_date", "current_class_id", "current_class_name"
    ],
    
    ('qa_parent_details.sql', 'dev_child_profile.sql'): [
        "parent_one_id", "parent_one_relation", "parent_one_firstname", "parent_one_lastname",
        "parent_one_nric", "parent_one_email", "parent_one_mobile_number", "parent_one_home_phone",
        "parent_one_date_of_birth", "parent_one_nationality", "parent_one_race", "parent_one_marital_status",
        "parent_one_qualification", "parent_one_occupation", "parent_one_working_status", "parent_one_workplace_association",
        "parent_one_pr_commencement_date", "parent_two_id", "parent_two_relation", "parent_two_firstname",
        "parent_two_lastname", "parent_two_nric", "parent_two_email", "parent_two_mobile_number", "parent_two_home_phone",
        "parent_two_date_of_birth", "parent_two_nationality", "parent_two_race", "parent_two_e_marital_status",
        "parent_two_qualification", "parent_two_occupation", "parent_two_working_status", "parent_two_pr_commencement_date",
        "address_postal_code", "address_city", "address_country","address_line_1", "address_block", "address_floor", "address_unit_no"
    ]
}

# Create a new workbook
wb = Workbook()

# Create the "Processed" sheet (summary)
ws_processed = wb.active
ws_processed.title = "Processed"
ws_processed.append(["SQL Files Verified", "Status", "Date Executed"])

# Connect to MySQL database
db_conn = mysql.connector.connect(**dev1)
cursor = db_conn.cursor()

current_date = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

for query1_file, query2_file in sql_files:
    with open(os.path.join(sql_dir, query1_file), 'r') as file:
        query1 = file.read()
    with open(os.path.join(sql_dir, query2_file), 'r') as file:
        query2 = file.read()
    
    cursor.execute(query1)
    data1 = cursor.fetchall()
    columns1 = [desc[0] for desc in cursor.description]
    df1 = pd.DataFrame(data1, columns=columns1)
    
    cursor.execute(query2)
    data2 = cursor.fetchall()
    columns2 = [desc[0] for desc in cursor.description]
    df2 = pd.DataFrame(data2, columns=columns2)
    
    df1.set_index('id', inplace=True)
    df2.set_index('id', inplace=True)
    
    comparison_columns = columns_to_verify.get((query1_file, query2_file), [])

    # Generate a valid sheet name
    sheet_name = f"{query1_file} vs {query2_file}".replace('.sql', '').replace('_', ' ')
    sheet_name = sheet_name[:31]  # Excel sheet names are limited to 31 characters

    # Create a new sheet for this comparison
    ws_discrepancy = wb.create_sheet(title=sheet_name)

    # Header for discrepancies sheet with updated column names
    header = ["Overall Result", "QA Query", "Dev Query"]
    if comparison_columns:
        header.append(comparison_columns[0])  # Dynamically setting the correct column name
    
    for col in comparison_columns[1:]:
        header.append(f"{col} Status")
        header.append(f"{col} - QA Query")
        header.append(f"{col} - Dev Query")
    header.append("Date Executed")
    
    ws_discrepancy.append(header)

    has_mismatch = False

    for id_value in df1.index:
        if id_value in df2.index:
            row1 = df1.loc[id_value]
            row2 = df2.loc[id_value]
            
            overall_status = "MATCH"
            row_data = [query1_file, query2_file, id_value]

            for col in comparison_columns[1:]:
                if col in df1.columns and col in df2.columns:
                    value1, value2 = str(row1[col]).strip(), str(row2[col]).strip()
                    status = "MATCH" if value1 == value2 else "MISMATCH"

                    if status == "MISMATCH":
                        overall_status = "MISMATCH"
                        has_mismatch = True 

                    row_data.extend([status, value1, value2])
                else:
                    row_data.extend(["N/A", "N/A", "N/A"])

            row_data.append(current_date)
            ws_discrepancy.append([overall_status] + row_data)

    # Results
    final_status = "MISMATCH" if has_mismatch else "MATCH"
    ws_processed.append([f"{query1_file} | {query2_file}", final_status, current_date])

# Save the workbook
file_name = os.path.join(result_dir, f"sql_comparison_{datetime.now().strftime('%Y-%m-%d_%H-%M-%S')}.xlsx")
wb.save(file_name)

# Close connections
cursor.close()
db_conn.close()

print(f"Comparison results saved to: {file_name}")