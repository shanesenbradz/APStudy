#!/usr/bin/env python3
"""Keeps the built-in courses and the content/ folder in step.

  python3 tools/content.py export   writes every built-in course from index.html to content/
                                     and rebuilds content/manifest.json
  python3 tools/content.py bake     copies content/*.json back into index.html (BUILTIN_COURSES)

To ship new or fixed questions without a new APK:
  1. Edit the course file in content/ and raise its "version" number by 1.
  2. Run: python3 tools/content.py export --keep   (rebuilds the manifest from content/)
  3. Commit and push. Apps that check for updates download the new file.
Run bake before the next APK build so the new questions are inside the app too.
"""
import json, sys, os
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
HTML = os.path.join(ROOT, "index.html")
DIR = os.path.join(ROOT, "content")
FILES = {"builtin": "a-plus-core.json", "builtin-linux": "linux-plus-xk0-006.json", "builtin-projectplus": "project-plus-pk0-005.json",
         "builtin-netplus": "network-plus-n10-009.json", "builtin-secplus": "security-plus-sy0-701.json"}
APP = {"name": "3.7.0", "code": 41}
START = "window.BUILTIN_COURSES = "

def read_html():
    return open(HTML, encoding="utf-8").read()

def builtins(s):
    i = s.index(START); j = s.index("</script>", i)
    return json.loads(s[i + len(START):j].strip().rstrip(";")), i, j

def manifest(entries):
    return {"schema": 1, "app": {"name": APP["name"], "code": APP["code"], "notes": ""}, "courses": entries}

def export(keep):
    s = read_html()
    arr, _, _ = builtins(s)
    os.makedirs(DIR, exist_ok=True)
    entries = []
    old = {}
    mp = os.path.join(DIR, "manifest.json")
    if os.path.exists(mp):
        try: old = {c["id"]: c for c in json.load(open(mp))["courses"]}
        except Exception: old = {}
    for b in arr:
        f = FILES.get(b["id"], b["id"] + ".json")
        path = os.path.join(DIR, f)
        if keep and os.path.exists(path):
            data = json.load(open(path, encoding="utf-8"))
        else:
            data = b["data"]
            json.dump(data, open(path, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
        e = {"id": b["id"], "file": f, "version": int(data.get("version", 1)), "title": data["title"], "color": b.get("color", "#0F766E")}
        if b["id"] in old and "minApp" in old[b["id"]]: e["minApp"] = old[b["id"]]["minApp"]
        entries.append(e)
    # courses that only exist in content/ (shipped after this build) stay listed
    for cid, c in old.items():
        if not any(e["id"] == cid for e in entries) and os.path.exists(os.path.join(DIR, c["file"])):
            entries.append(c)
    json.dump(manifest(entries), open(mp, "w", encoding="utf-8"), indent=1)
    print("manifest:", [(e["id"], e["version"]) for e in entries])

def bake():
    s = read_html()
    arr, i, j = builtins(s)
    for b in arr:
        f = os.path.join(DIR, FILES.get(b["id"], b["id"] + ".json"))
        if os.path.exists(f):
            b["data"] = json.load(open(f, encoding="utf-8"))
    out = s[:i] + START + json.dumps(arr, ensure_ascii=False, indent=1) + ";\n\n" + s[j:]
    open(HTML, "w", encoding="utf-8").write(out)
    print("baked:", [(b["id"], b["data"].get("version")) for b in arr])

if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else ""
    if cmd == "export": export("--keep" in sys.argv)
    elif cmd == "bake": bake()
    else: print(__doc__)
