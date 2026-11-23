"""Download the top slices of a Visible Human normal CT series (NLM, no licence needed;
NLM Terms and Conditions require acknowledging the National Library of Medicine).
usage: download.py male|female OUT_DIR COUNT"""
import sys, pathlib, re, subprocess, urllib.request
from concurrent.futures import ThreadPoolExecutor
BASE = "https://data.lhncbc.nlm.nih.gov/public/Visible-Human/"
SERIES = {"male": ("Male-Images/radiological/normalCT/", r"c_vm\d+\.fre\.Z"),
          "female": ("Female-Images/radiological/normalCT/", r"c_vf\d+\.fre\.Z")}
body, out, count = sys.argv[1], pathlib.Path(sys.argv[2]), int(sys.argv[3])
folder, pattern = SERIES[body]
out.mkdir(parents=True, exist_ok=True)
index = urllib.request.urlopen(BASE + folder + "index.html", timeout=60).read().decode()
names = sorted(set(re.findall(pattern, index)))
(out / "list.txt").write_text("\n".join(names) + "\n")
def fetch(name):
    target = out / name
    if not target.exists():
        subprocess.run(["curl", "-s", "-f", "-m", "120", "-o", str(target), BASE + folder + name], check=True)
with ThreadPoolExecutor(8) as pool:
    list(pool.map(fetch, names[:count]))
print(body, "slices listed", len(names), "downloaded", count)
