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
    for _ in range(4):
        if target.exists() and target.stat().st_size > 0:
            return None
        target.unlink(missing_ok=True)
        subprocess.run(["curl", "-s", "-f", "-m", "120", "-o", str(target), BASE + folder + name])
    target.unlink(missing_ok=True)
    return name
with ThreadPoolExecutor(8) as pool:
    missing = [n for n in pool.map(fetch, names[:count]) if n]
# Volume builders skip slices that are absent, so record what the server did not supply.
(out / "missing.txt").write_text("\n".join(missing) + ("\n" if missing else ""))
print(body, "slices listed", len(names), "requested", min(count, len(names)), "missing", missing)
