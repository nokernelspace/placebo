import json
from pathlib import Path
import pdb

new_template = {"created_time":"2026-09-11T19:56:38.343937","last_updated_time":"2026-09-11T20:01:34.034829","modes":{"relax":False,"physical":False,"working":False,"learning":False},"justice":0.0,"patience":0.0,"bravery":0.0,"perseverence":0.0,"integerity":0.0,"kindness":0.0,"people":"ME","notes":[]}
dir_path = Path("./old")
files = [f.resolve() for f in dir_path.iterdir() if f.is_file() and f.suffix == ".mood"]
files_json = [json.load(open(f, "r")) for f in files]

output = []

for mood in files_json:
    out = new_template.copy()
    out["created_time"] = mood["time"][1:-2]
    out["last_updated_time"] = mood["time"][1:-2]

    out["modes"]["learning"] = mood["modes"]["learning"]
    out["modes"]["relax"] = mood["modes"]["relax"]
    out["modes"]["physical"] = mood["modes"]["physical"]
    out["modes"]["working"] = mood["modes"]["working"]

    out["notes"] = mood["notes"]

    output.append(out)

assert(len(output) == len(files))

for i in range(len(output)):
    out_path = Path(f"new/{files[i].name}")

    with open(out_path, "a+") as f:
        print(out_path)
        f.write(json.dumps(output[i]))

pdb.set_trace()
