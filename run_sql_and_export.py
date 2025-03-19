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
proc_files = {
    "create_temp_child": os.path.join(sql_dir, "create_temp_child.sql"),
    "create_temp_child_class": os.path.join(sql_dir, "create_temp_child_class.sql"),
}

# Generate timestamped filename
timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
output_file = os.path.join(result_dir, f"qa_foliettes_result_{timestamp}.csv")

def check_and_create_procedure(cursor, conn, proc_name, proc_file, db_name):
    """Check if a stored procedure exists and create it from a file if missing."""
    cursor.execute(f"""
        SELECT COUNT(*) FROM INFORMATION_SCHEMA.ROUTINES 
        WHERE ROUTINE_TYPE = 'PROCEDURE' 
        AND ROUTINE_NAME = '{proc_name}' 
        AND ROUTINE_SCHEMA = '{db_name}';
    """)
    exists = cursor.fetchone()[0]  # Get count result

    if exists == 0:  # Procedure does not exist
        print(f"⚠️ Stored procedure {proc_name} missing. Creating it from {proc_file}...")
        with open(proc_file, "r") as f:
            sql_script = f.read()
        try:
            cursor.execute(sql_script)
            conn.commit()  # Ensure the procedure is committed
            print(f"✅ Stored procedure {proc_name} created successfully!")
        except pymysql.err.ProgrammingError as e:
            print(f"❌ Error creating procedure {proc_name}: {e}")

try:
    # Get DB connection
    conn = get_connection(env="ms_dev02")  
    db_name = "ms_dev02"  # Replace with your actual database name

    with conn.cursor() as cursor:
        # Step 1: Ensure stored procedures exist
        for proc_name, proc_file in proc_files.items():
            try:
                check_and_create_procedure(cursor, conn, proc_name, proc_file, db_name)
            except Exception as e:
                print(f"⚠️ Skipping procedure creation for {proc_name}: {e}")

        # Step 2: Call stored procedures to create temp tables
        print("🔄 Calling stored procedures...")
        try:
            cursor.execute("CALL create_temp_child();")
            conn.commit()
        except pymysql.err.OperationalError as e:
            print(f"⚠️ Skipping create_temp_child() due to error: {e}")

        try:
            cursor.execute("CALL create_temp_child_class();")
            conn.commit()
        except pymysql.err.OperationalError as e:
            print(f"⚠️ Skipping create_temp_child_class() due to error: {e}")

        print("✅ Temporary tables processed!")

        # Step 3: Read and execute main SQL query
        if os.path.exists(sql_file):
            with open(sql_file, "r") as f:
                query = f.read()
            
            print(f"🔄 Executing query from {sql_file}...")
            try:
                cursor.execute(query)
                result = cursor.fetchall()
                row_count = len(result) if result else 0
                print(f"🔍 Query executed. Rows fetched: {row_count}")

                # Step 4: Convert results to DataFrame
                if row_count > 0:
                    columns = [desc[0] for desc in cursor.description]
                    df_sql = pd.DataFrame(result, columns=columns)
                    print(f"📊 Saving {row_count} rows to CSV...")
                else:
                    df_sql = pd.DataFrame()  # Create empty DataFrame
                    print("⚠️ No data returned from query!")
            except Exception as e:
                print(f"❌ Query execution failed: {e}")
                df_sql = pd.DataFrame()  # Ensure a DataFrame is always created

        # Step 5: Ensure result directory exists
        os.makedirs(result_dir, exist_ok=True)

        # Step 6: Save query result to CSV with timestamp
        df_sql.to_csv(output_file, index=False)
        print(f"✅ Query result saved to: {output_file}")

except Exception as e:
    print(f"❌ Error: {e}")

finally:
    if 'conn' in locals() and conn.open:
        conn.close()
        print("🔒 Database connection closed.")

# Print output filename for verify_sql_vs_jsonFiles.py
print(f"OUTPUT_FILE={output_file}")
