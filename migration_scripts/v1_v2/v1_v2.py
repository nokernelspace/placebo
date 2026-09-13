import json
from pathlib import Path
import pdb

# need to rename files to ISO-8601

dir_path = Path("./old")
files = [f.resolve() for f in dir_path.iterdir() if f.is_file() and f.suffix == ".mood"]

output = []

for i in range(len(files)):
    file_json = json.loads(files[i].read_text())
    out_path = Path(f"new/{file_json["created_time"]}.mood")

    with open(out_path, "a+") as f:
        out_path.write_text(files[i].read_text())

pdb.set_trace()
