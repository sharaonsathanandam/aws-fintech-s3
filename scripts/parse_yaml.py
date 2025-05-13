import yaml, json, sys, os, subprocess

input_file = sys.argv[1]
with open(input_file) as f:
    data = yaml.safe_load(f)

folder_name = os.path.basename(os.path.dirname(input_file))
print(folder_name)

if input_file.startswith("datasets/"):
    data["is_bucket_onboarding"] = True
    data["is_access_request"] = False
    if folder_name == "finance":
        data["Data_Classification"] = "fin_analysis"
    elif folder_name == "treasury-ops":
        data["Data_Classification"] = "treas_ops"
    else:
        data["Data_Classification"] = "general"
else:
    # Auto-inject principal ARN based on user_id (for access-requests)
    if input_file.startswith("access-requests/") and "user_id" in data:
        account_id = subprocess.check_output([
            "/usr/local/bin/aws", "sts", "get-caller-identity", "--query", "Account", "--output", "text"
        ]).decode("utf-8").strip()
        data["principal_arn"] = f"arn:aws:iam::{account_id}:user/{data['user_id']}"
        data["is_access_request"] = True
        data["is_bucket_onboarding"] = False

out_path = "pipeline-config/terraform.tfvars.json"

with open(out_path, "w") as out:
    json.dump(data, out, indent=2)