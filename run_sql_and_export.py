import pymysql
import pandas as pd
import os
import datetime
from db_config import get_connection  # Import DB connection function

# Directories
sql_dir = "/Users/shaliniolivera/Documents/Automation/LSH_Premium/queries"
result_dir = "/Users/shaliniolivera/Documents/Automation/LSH_Premium/result_jsonQuery_verification"

# File paths
sql_file = os.path.join(sql_dir, "qa_foliettes.sql")

# Generate timestamped filename
timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
output_file = os.path.join(result_dir, f"qa_foliettes_result_{timestamp}.csv")

try:
    # Get DB connection
    conn = get_connection(env="ms_dev02")  

    with conn.cursor() as cursor:
        # Step 1: Call stored procedure to create temp table
        print("🔄 Calling stored procedure: create_temp_child()...")
        cursor.execute("CALL create_temp_child();")
        print("✅ Temporary table created successfully!")

        # Step 2: Read and execute SQL file
        with open(sql_file, "r") as f:
            query = f.read()

        print(f"🔄 Executing query from {sql_file}...")
        cursor.execute(query)

        # Fetch all results
        result = cursor.fetchall()

        # Step 3: Convert results to DataFrame
        columns = [desc[0] for desc in cursor.description]  # Get column names
        df_sql = pd.DataFrame(result, columns=columns)

        # Step 4: Save query result to CSV with timestamp
        df_sql.to_csv(output_file, index=False)
        print(f"✅ Query result saved to: {output_file}")

except Exception as e:
    print(f"❌ Error: {e}")

finally:
    conn.close()
    print("🔒 Database connection closed.")

# Print output filename for verify_sql_vs_jsonFiles.py
print(f"OUTPUT_FILE={output_file}")
