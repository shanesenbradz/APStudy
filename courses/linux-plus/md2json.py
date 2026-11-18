import json, re, sys, collections

FILES = ["d1-system-management.md", "d2-services-users.md", "d3-security.md",
         "d4-automation.md", "d5-troubleshooting.md"]

course = {
    "title": "Linux+ Study Lab",
    "subtitle": "CompTIA Linux+ XK0-006 practice bank (322 questions)",
    "version": 1,
    "note": "Original practice questions plus reviewed and corrected community items. Not affiliated with CompTIA. Check the official XK0-006 objectives before you book.",
    "modules": []
}

def parse(text):
    mod = con = q = None
    for raw in text.splitlines():
        line = raw.rstrip()
        if not line.strip():
            continue
        if line.startswith("# MODULE "):
            mid, title, exam, color = [x.strip() for x in line[9:].split("|")]
            mod = {"id": mid, "title": title, "exam": exam, "color": color, "concepts": []}
            course["modules"].append(mod); con = None
        elif line.startswith("## CONCEPT "):
            cid, title = [x.strip() for x in line[11:].split("|")]
            con = {"id": cid, "title": title, "learn": {"points": []}, "cards": [], "questions": []}
            mod["concepts"].append(con); q = None
        elif line.startswith("@"):
            q = {"type": line[1:].strip()}
            if q["type"] == "mc": q["options"] = []; q["_right"] = []
            if q["type"] == "match": q["pairs"] = []
            if q["type"] == "order": q["steps"] = []
            con["questions"].append(q)
        elif q is None and con is not None:
            k, v = line.split(":", 1); v = v.strip()
            if k == "point": con["learn"]["points"].append(v)
            elif k == "card":
                front, back = v.split(" => ", 1)
                con["cards"].append({"front": front.strip(), "back": back.strip()})
            else: con["learn"][k] = v
        elif line.startswith("Q: "): q["q"] = line[3:].strip()
        elif line.startswith("E: "): q["explain"] = line[3:].strip()
        elif line.startswith("U: "): q["unit"] = line[3:].strip()
        elif line.startswith("A: "):
            v = line[3:].strip()
            q["answer"] = (v == "true") if q["type"] == "tf" else float(v) if "." in v else int(v)
        elif line.startswith("* ") or line.startswith("- "):
            body = line[2:].strip()
            t = q["type"]
            if t == "mc":
                if line[0] == "*": q["_right"].append(len(q["options"]))
                q["options"].append(body)
            elif t == "match":
                l, r = body.split(" => ")
                q["pairs"].append([l.strip(), r.strip()])
            elif t == "order":
                q["steps"].append(body)
        else:
            raise ValueError("Unparsed line: " + line)

for f in FILES:
    parse(open(f, encoding="utf-8").read())

# finalise question objects in the app's field order
for m in course["modules"]:
    for c in m["concepts"]:
        out = []
        for q in c["questions"]:
            t = q["type"]
            if t == "mc":
                r = q.pop("_right")
                out.append({"type": "mc", "q": q["q"], "options": q["options"], "answer": r[0] if len(r) == 1 else r, "explain": q["explain"]})
            elif t == "tf":
                out.append({"type": "tf", "q": q["q"], "answer": q["answer"], "explain": q["explain"]})
            elif t == "match":
                out.append({"type": "match", "q": q["q"], "pairs": q["pairs"], "explain": q["explain"]})
            elif t == "order":
                out.append({"type": "order", "q": q["q"], "steps": q["steps"], "explain": q["explain"]})
            elif t == "calc":
                out.append({"type": "calc", "q": q["q"], "answer": q["answer"], "unit": q.get("unit", ""), "tolerance": 0, "explain": q["explain"]})
        c["questions"] = out

# ---- validation: mirrors validateCourse() in A+StudyLab v3.4 ----
errs = []
isStr = lambda v: isinstance(v, str) and v.strip() != ""
mids = set()
for mi, m in enumerate(course["modules"]):
    assert m["id"] not in mids; mids.add(m["id"])
    assert re.fullmatch(r"#[0-9a-fA-F]{6}", m["color"])
    cids = set()
    for c in m["concepts"]:
        assert c["id"] not in cids; cids.add(c["id"])
        assert all(isStr(p) for p in c["learn"]["points"])
        assert all(isStr(x["front"]) and isStr(x["back"]) for x in c["cards"])
        for qi, q in enumerate(c["questions"]):
            p = f"{m['id']}/{c['id']}/{qi}"
            if not isStr(q.get("q")): errs.append(p + " no q")
            if not isStr(q.get("explain")): errs.append(p + " no explain")
            t = q["type"]
            if t == "mc":
                n = len(q["options"])
                if n < 2 or not all(isStr(o) for o in q["options"]): errs.append(p + " options")
                if len(set(q["options"])) != n: errs.append(p + " duplicate option")
                a = q["answer"]
                if isinstance(a, list):
                    if len(a) < 2 or len(set(a)) != len(a): errs.append(p + " multi answer")
                elif not (isinstance(a, int) and 0 <= a < n): errs.append(p + " answer")
            elif t == "tf":
                if not isinstance(q["answer"], bool): errs.append(p + " tf")
            elif t == "match":
                if len(q["pairs"]) < 2 or len({x[0] for x in q["pairs"]}) != len(q["pairs"]): errs.append(p + " match left")
                if len({x[1] for x in q["pairs"]}) != len(q["pairs"]): errs.append(p + " match right dup")
            elif t == "order":
                if len(q["steps"]) < 2 or len(set(q["steps"])) != len(q["steps"]): errs.append(p + " order")
            elif t == "calc":
                if not isinstance(q["answer"], (int, float)): errs.append(p + " calc")
            else:
                errs.append(p + " bad type")

# duplicate question text across the bank
seen = collections.Counter(q["q"] for m in course["modules"] for c in m["concepts"] for q in c["questions"])
errs += ["duplicate q: " + k for k, v in seen.items() if v > 1]

# no em or en dashes anywhere (house style)
blob = json.dumps(course, ensure_ascii=False)
if "\u2014" in blob or "\u2013" in blob: errs.append("em/en dash found")

print("ERRORS:", errs if errs else "none")
total = 0
types = collections.Counter()
for m in course["modules"]:
    n = sum(len(c["questions"]) for c in m["concepts"])
    total += n
    print(f"{m['title']:45} {n:4} q {sum(len(c['cards']) for c in m['concepts']):4} cards  " + ", ".join(f"{c['id']}={len(c['questions'])}" for c in m["concepts"]))
    for c in m["concepts"]:
        for q in c["questions"]:
            types[q["type"] + ("-multi" if q["type"] == "mc" and isinstance(q["answer"], list) else "")] += 1
print("TOTAL", total)
print("TYPES", dict(types))

json.dump(course, open("linux-plus-xk0-006.json", "w", encoding="utf-8"), ensure_ascii=False, indent=1)
with open("XK0-006-question-bank.md", "w", encoding="utf-8") as out:
    out.write("# CompTIA Linux+ XK0-006 Question Bank (322)\n\n")
    out.write("Format: `@type` starts a question. `*` marks a correct option, `-` a wrong one. Match pairs use `=>`. Order steps are listed in the correct order. `card: front => back` lines are flashcards.\n\n")
    for f in FILES:
        out.write(open(f, encoding="utf-8").read().strip() + "\n\n")
