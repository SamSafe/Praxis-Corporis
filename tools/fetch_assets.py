"""Download only the public, pinned atlas files in the local source manifest."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import pathlib
import sys
import tempfile
import urllib.request

ROOT = pathlib.Path(__file__).resolve().parents[1]


def verified(path: pathlib.Path, record: dict) -> bool:
    return (path.is_file() and path.stat().st_size == record["bytes"]
            and hashlib.sha256(path.read_bytes()).hexdigest() == record["sha256"])


def fetch(record: dict, root: pathlib.Path = ROOT) -> str:
    destination = (root / record["local_path"]).resolve()
    if not destination.is_relative_to(root.resolve()):
        raise ValueError("Asset destination must remain inside the project")
    if verified(destination, record):
        return f"Verified {record['local_path']}"
    destination.parent.mkdir(parents=True, exist_ok=True)
    request = urllib.request.Request(record["url"], headers={"User-Agent": "Praxis-Corporis-feasibility"})
    temporary = None
    try:
        with tempfile.NamedTemporaryFile(dir=destination.parent, delete=False) as output:
            temporary = pathlib.Path(output.name)
            with urllib.request.urlopen(request, timeout=120) as response:
                remaining = record["bytes"]
                while block := response.read(min(1024 * 1024, remaining + 1)):
                    remaining -= len(block)
                    if remaining < 0:
                        raise ValueError("Response exceeds the pinned asset size")
                    output.write(block)
        if not verified(temporary, record):
            raise ValueError(f"Size or SHA-256 mismatch for {record['local_path']}")
        os.replace(temporary, destination)
        return f"Downloaded and verified {record['local_path']}"
    finally:
        if temporary is not None:
            temporary.unlink(missing_ok=True)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--verify-only", action="store_true", help="Check local files without network access")
    parser.add_argument("--manifest", type=pathlib.Path, default=ROOT / "content/source_manifest.json", help="Pinned source manifest, defaulting to the HRA prototype sources")
    args = parser.parse_args()
    manifest = json.loads(args.manifest.read_text())
    failures = []
    for record in manifest["files"]:
        try:
            if args.verify_only:
                if not verified(ROOT / record["local_path"], record):
                    raise ValueError(f"Missing or modified: {record['local_path']}")
                print(f"Verified {record['local_path']}")
            else:
                print(fetch(record), flush=True)
        except (OSError, ValueError) as error:
            failures.append(str(error))
    for failure in failures:
        print(failure, file=sys.stderr)
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
