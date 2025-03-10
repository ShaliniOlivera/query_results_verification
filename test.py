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
    ('qa_parent_details.sql', 'dev_child_profile.sql'),
    ('qa_child_attributes.sql', 'dev_child_profile.sql'),
    ('qa_doctor_details.sql', 'dev_child_profile.sql'),
    ('qa_immunization.sql', 'dev_child_profile.sql'),
    ('qa_physicalConditions.sql', 'dev_child_profile.sql'),
    ('qa_specialNeeds.sql', 'dev_child_profile.sql'),
    ('qa_foodAllergies.sql', 'dev_child_profile.sql'),
    ('qa_nonFoodAllergies.sql', 'dev_child_profile.sql')
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
        "address_postal_code", "address_city", "address_country", "address_line_1", "address_block", "address_floor", "address_unit_no"
    ],
    ('qa_child_attributes.sql', 'dev_child_profile.sql'): [
        "id", "emergency_contact_name", "emergency_contact_identification_no", "emergency_contact_address_postal_code",
        "emergency_contact_address_line_1", "emergency_contact_address_floor_no", "emergency_contact_address_unit_no",
        "emergency_contact_address_block_no", "emergency_contact_email", "emergency_contact_mobile_phone", "emergency_contact_relationship"                                                   
    ],
    
    ('qa_doctor_details.sql', 'dev_child_profile.sql'):[
        "id", "family_doctor_clinic_name", "family_doctor_name", "family_doctor_email", "family_doctor_contact_no", "family_doctor_clinic_unit_no",
        "family_doctor_clinic_floor_no", "family_doctor_clinic_block_no", "family_doctor_clinic_address_1", "family_doctor_clinic_postal_code",
        "family_doctor_remarks"
    ],
    
    ('qa_medical_records.sql', 'dev_child_profile.sql'):[
        "id","is_immunized", "bcg", "hep_b", "ipv", "hib", "pcv10", "var", "inf", "dtap_1d", "dtap_2d", "dtap_3d", "dtap_18m", "mmr_1d", "mmr_2d", 
        "physical_condition_fits", "physical_condition_asthma", "physical_condition_diabetes", "physical_condition_hepatitis_b", 
        "physical_condition_hepatitis_a", "physical_condition_others", "physical_condition_remarks", "special_needs_adhd", "special_needs_autism", 
        "special_needs_auditory_issues", "special_needs_dyslexia", "special_needs_down_syndrome", "special_needs_global_development_delay", 
        "special_needs_others", "special_needs_remarks", "food_allergies_dairy", "food_allergies_nuts", "food_allergies_eggs", 
        "food_allergies_mushrooms", "food_allergies_gluten", "food_allergies_fish", "food_allergies_others", "food_allergies_remarks", 
        "non_food_allergies_pollen", "non_food_allergies_others", "non_food_allergies_remarks"
    ],
    
    ('qa_immunization.sql', 'dev_child_profile.sql'):[
        "id", "is_immunized", "bcg", "hep_b", "ipv", "hib", "pcv10", "var", "inf", "dtap_1d", "dtap_2d", "dtap_3d", "dtap_18m", "mmr_1d", "mmr_2d"
    ],
    
    ('qa_physicalConditions.sql', 'dev_child_profile.sql'):[
        "id", "physical_condition_fits", "physical_condition_asthma", "physical_condition_diabetes", "physical_condition_hepatitis_b", 
        "physical_condition_hepatitis_a", "physical_condition_others", "physical_condition_remarks"
    ],
    
    ('qa_specialNeeds.sql', 'dev_child_profile.sql'):[
        "id", "special_needs_adhd", "special_needs_autism", "special_needs_auditory_issues", "special_needs_dyslexia", 
        "special_needs_down_syndrome", "special_needs_global_development_delay", "special_needs_others", "special_needs_remarks"
    ],
    
    ('qa_foodAllergies.sql', 'dev_child_profile.sql'):[
        "food_allergies_dairy", "food_allergies_nuts", "food_allergies_eggs", "food_allergies_mushrooms", "food_allergies_gluten", 
        "food_allergies_fish", "food_allergies_others", "food_allergies_remarks"
    ],
    
    ('qa_nonFoodAllergies.sql', 'dev_child_profile.sql'):[
        "non_food_allergies_pollen", "non_food_allergies_others", "non_food_allergies_remarks"
    ]
}

# Create a new workbook
wb = Workbook()

# Create the "Processed" sheet (summary)
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
        
        # Validate if cursor.description exists
        if cursor.description is None:
            print(f"⚠️ WARNING: No data returned for {query_name} (cursor.description is None).")
            return None, None
        
        columns = [desc[0] for desc in cursor.description]
        return data, columns

    except mysql.connector.Error as err:
        print(f"❌ ERROR: Query execution failed for {query_name}: {err}")
        return None, None

for query1_file, query2_file in sql_files:
    print(f"🔍 Verifying SQL Files: {query1_file} and {query2_file}...")  # Log which files are being verified
    
    with open(os.path.join(sql_dir, query1_file), 'r') as file:
        query1 = file.read()
    with open(os.path.join(sql_dir, query2_file), 'r') as file:
        query2 = file.read()

    # Execute queries with validation
    data1, columns1 = execute_query(query1, query1_file)
    data2, columns2 = execute_query(query2, query2_file)

    # Skip comparison if either query failed
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

    comparison_columns = columns_to_verify.get((query1_file, query2_file), [])

    sheet_name = f"{query1_file} vs {query2_file}".replace('.sql', '').replace('_', ' ')
    sheet_name = sheet_name[:31]  # Excel sheet names limit

    ws_discrepancy = wb.create_sheet(title=sheet_name)
    header = ["Overall Result", "QA Query", "Dev Query", comparison_columns[0]]
    
    for col in comparison_columns[1:]:
        header.extend([f"{col} Status", f"{col} - QA Query", f"{col} - Dev Query"])
    header.append("Date Executed")
    
    ws_discrepancy.append(header)

    has_mismatch = False
    mismatch_count = 0

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
                        mismatch_count += 1
                    row_data.extend([status, value1, value2])
                else:
                    row_data.extend(["N/A", "N/A", "N/A"])

            row_data.append(current_date)
            ws_discrepancy.append([overall_status] + row_data)

    final_status = "MISMATCH" if has_mismatch else "MATCH"
    ws_processed.append([f"{query1_file} | {query2_file}", final_status, mismatch_count, current_date])

file_name = os.path.join(result_dir, f"sql_comparison_{datetime.now().strftime('%Y-%m-%d_%H-%M-%S')}.xlsx")
wb.save(file_name)

cursor.close()
db_conn.close()

print(f"✅ Comparison results saved to: {file_name}")
