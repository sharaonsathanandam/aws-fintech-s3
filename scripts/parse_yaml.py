import yaml, json, sys, os, subprocess

input_file = sys.argv[1]
with open(input_file) as f:
    data = yaml.safe_load(f)

folder_name = os.path.basename(os.path.dirname(input_file))
print(folder_name)

if folder_name == "finance":
    data["Data_Classification"] = "fin_analysis"
elif folder_name == "treasury-ops":
    data["Data_Classification"] = "treas_ops"
else:
    data["Data_Classification"] = "general"

out_path = "pipeline-config/terraform.tfvars.json"

with open(out_path, "w") as out:
    json.dump(data, out, indent=2)