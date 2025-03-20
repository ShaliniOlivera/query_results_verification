import os
import json
import ast
import pandas as pd
import subprocess
import time
start_time = time.time()
from datetime import datetime

# Directories
result_dir = "/Users/shaliniolivera/Documents/Automation/LSH_Premium/result_jsonQuery_verification"
json_dir = "/Users/shaliniolivera/Documents/Automation/LSH_Premium/json_files"

# JSON file
json_file = "class_activity_20250320_1236.json"
json_file_path = os.path.join(json_dir, json_file)

# ✅ Step 1: Run SQL query to fetch latest results
print("🔄 Running SQL query to fetch latest results...")
result = subprocess.run(["python3", "run_sql_export_class_activity.py"], capture_output=True, text=True)
output_lines = result.stdout.split("\n")

# ✅ Step 2: Extract the latest output file from run_sql_and_export.py
sql_result_path = None
for line in output_lines:
    if "OUTPUT_FILE=" in line:
        sql_result_path = line.split("OUTPUT_FILE=")[-1].strip()

if not sql_result_path or not os.path.exists(sql_result_path):
    print(f"❌ SQL result file not found: {sql_result_path}")
    exit(1)

# ✅ Step 3: Load SQL result
df_sql = pd.read_csv(sql_result_path)

# ✅ Step 4: Load JSON data
with open(json_file_path, "r", encoding="utf-8") as f:
    json_data = json.load(f)

# Convert JSON to DataFrame
json_records = []
for record in json_data:
    # Rearrange 'medias' field to ensure the order: type, source_path, display_order, created_at, updated_at
    medias = record.get("medias", [])
    
    # Sort medias by 'display_order'
    sorted_medias = sorted(medias, key=lambda x: x["display_order"])

    rearranged_medias = []
    for media in sorted_medias:  # Use sorted medias here
        rearranged_media = {
            "type": media["type"],
            "source_path": media["source_path"],
            "display_order": media["display_order"],
            "created_at": media["created_at"],
            "updated_at": media["updated_at"]
        }
        rearranged_medias.append(rearranged_media)
    
    # Append the rearranged 'medias' along with other fields to json_records
    json_records.append({
        "id": record["id"],
        "type": record["type"],
        "title": record["title"],
        "description": record["description"],
        "interpretation": record.get("interpretation", ""),
        "status": record["status"],
        "published_at": record["published_at"],
        "created_at": record["created_at"],
        "updated_at": record["updated_at"],
        "display_date": record["display_date"],
        "centres": json.dumps(record["centres"], sort_keys=True), 
        "children": json.dumps(record.get("children", ""), sort_keys=True),
        "classes": json.dumps(record.get("classes", ""), sort_keys=True),
        "medias": json.dumps(rearranged_medias, sort_keys=True),  # Use sorted 'medias'
        "tags": json.dumps(record.get("tags", ""), sort_keys=True),
        #"lesson_plans": json.dumps(record.get("lesson_plans", ""), sort_keys=True),
        "link": record.get("link", ""),
        #"learning_goals": json.dumps(record.get("learning_goals", ""), sort_keys=True),
        #"development_and_learning_area": json.dumps(record.get("development_and_learning_area", ""), sort_keys=True),
    })

df_json = pd.DataFrame(json_records)

# ✅ Step 5: Merge SQL and JSON data on "id" to compare values
df_sql["centres"] = df_sql["centres"].apply(lambda x: json.dumps(eval(x), sort_keys=True) if isinstance(x, str) else x)
def safe_json_parse(value):
    if pd.isna(value) or value in ["", "null", "None", "[]", "{}"]:
        return json.dumps([])  # Convert nulls and empty values to an empty list for uniformity

    if isinstance(value, str):
        try:
            return json.dumps(json.loads(value), sort_keys=True)
        except json.JSONDecodeError:
            try:
                return json.dumps(ast.literal_eval(value), sort_keys=True)
            except (ValueError, SyntaxError):
                return json.dumps([])  # Default to empty list if parsing fails
    return value

# Apply to SQL and JSON datasets
df_sql["children"] = df_sql["children"].apply(safe_json_parse)
df_json["children"] = df_json["children"].apply(safe_json_parse)

df_sql["classes"] = df_sql["classes"].apply(lambda x: json.dumps(json.loads(x), sort_keys=True) if isinstance(x, str) else x)
def clean_medias(x):
    if x in [None, "null"]:  # If it's already null, return None
        return None
    try:
        parsed = json.loads(x)
        # Check if the parsed value is a list and contains only null-like objects
        if isinstance(parsed, list) and all(
            isinstance(obj, dict) and all(v is None for v in obj.values()) for obj in parsed
        ):
            return "[]"  # Convert to an empty list representation
        return json.dumps(parsed, sort_keys=True)  # Keep valid JSON
    except json.JSONDecodeError:
        return x  # Return original if it's not valid JSON

df_sql["medias"] = df_sql["medias"].apply(clean_medias)


def safe_json_parse(value):
    if isinstance(value, str):
        try:
            return json.dumps(json.loads(value), sort_keys=True)
        except json.JSONDecodeError:
            try:
                return json.dumps(ast.literal_eval(value), sort_keys=True)
            except (ValueError, SyntaxError):
                return json.dumps([])  # Return an empty JSON array if parsing fails
    return value

df_sql["tags"] = df_sql["tags"].apply(safe_json_parse)
#df_sql["lesson_plans"] = df_sql["lesson_plans"].apply(lambda x: json.dumps(eval(x), sort_keys=True) if isinstance(x, str) else x)
#df_sql["learning_goals"] = df_sql["learning_goals"].apply(safe_json_parse)
#df_sql["development_and_learning_area"] = df_sql["development_and_learning_area"].apply(safe_json_parse)

df_merged = df_sql.merge(df_json, on="id", suffixes=("_sql", "_json"), how="outer", indicator=True)

# ✅ Step 6: Define the columns to compare
columns_to_compare = [
    "type","title", "description", "interpretation", "status", "published_at", "created_at",
    "updated_at", "display_date", "centres", "children", "classes", "medias", "tags", "link"
    #,"learning_goals","development_and_learning_area",, "lesson_plans"
]

# ✅ Step 7: Create status columns
# Define function outside the loop
from datetime import datetime
import json
import pandas as pd

def normalize_value(value):
    if pd.isna(value) or value in ["", "[]", "{}", None]:
        return None  # Treat blanks as equivalent

    # Convert datetime strings to a standard format
    if isinstance(value, str):
        try:
            # Ensure ISO format is normalized (handles both "T" and "Z")
            value = value.replace("T", " ").replace("Z", "")
            return datetime.fromisoformat(value).strftime("%Y-%m-%d %H:%M:%S")
        except ValueError:
            pass  # Ignore if it's not a valid datetime string

        try:
            # Convert JSON-like strings to properly formatted JSON
            parsed_value = json.loads(value)

            # If the parsed value is a dictionary, wrap it in a list for uniformity
            if isinstance(parsed_value, dict):
                parsed_value = [parsed_value]

            # Ensure unordered dictionaries or lists are sorted
            if isinstance(parsed_value, dict):
                parsed_value = {key: parsed_value[key] for key in sorted(parsed_value.keys())}
            elif isinstance(parsed_value, list):
                parsed_value = sorted(parsed_value, key=lambda x: json.dumps(x, sort_keys=True))

            return json.dumps(parsed_value, sort_keys=True)  
        except (json.JSONDecodeError, TypeError):
            pass

    return value




for col in columns_to_compare:
    df_merged[f"{col}_status"] = df_merged.apply(
        lambda row: normalize_value(row[f"{col}_sql"]) == normalize_value(row[f"{col}_json"]),
        axis=1
    )

# ✅ Step 8: Add Overall Status column
status_columns = [f"{col}_status" for col in columns_to_compare]
df_merged["Overall Status"] = df_merged[status_columns].apply(lambda x: "Mismatch" if any(x != True) else "Match", axis=1)

# ✅ Step 9: Identify missing records
df_missing_in_json = df_merged[df_merged["_merge"] == "left_only"].drop(columns=["_merge"])
df_missing_in_sql = df_merged[df_merged["_merge"] == "right_only"].drop(columns=["_merge"])

# ✅ Step 10: Rearrange columns for better readability
ordered_columns = ["Overall Status", "id"]

for col in columns_to_compare:
    ordered_columns.append(f"{col}_status")  # Status column
    ordered_columns.append(f"{col}_sql")     # SQL value
    ordered_columns.append(f"{col}_json")    # JSON value

df_all_results = df_merged[ordered_columns]

# ✅ Step 11: Save results to Excel with timestamped filename
timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
output_xlsx = os.path.join(result_dir, f"verification_result_{timestamp}.xlsx")

# Create the Excel writer
with pd.ExcelWriter(output_xlsx, engine="xlsxwriter") as writer:
    
    # First sheet: Processed file summary
    summary_df = pd.DataFrame({
        "File Name": [os.path.basename(sql_result_path)],
        "Status": ["Matched" if df_merged["Overall Status"].eq("Mismatch").sum() == 0 else "Mismatched"],
        "Execution Timestamp": [datetime.now().strftime("%Y-%m-%d %H:%M:%S")]
    })
    summary_df.to_excel(writer, sheet_name="Processed", index=False)

    # Second sheet: Detailed verification results
    df_all_results.to_excel(writer, sheet_name="Verification Details", index=False)
    
    # Third sheet: Missing in JSON
    df_missing_in_json.to_excel(writer, sheet_name="Missing in JSON", index=False)
    
    # Fourth sheet: Missing in SQL
    df_missing_in_sql.to_excel(writer, sheet_name="Missing in SQL", index=False)
    
end_time = time.time()
elapsed_time = end_time - start_time
formatted_time = f"{int(elapsed_time // 60):02}:{int(elapsed_time % 60):02}"
print(f"✅ Verification completed in {int(elapsed_time // 60)}m {int(elapsed_time % 60)}s. Results saved to: {output_xlsx}")