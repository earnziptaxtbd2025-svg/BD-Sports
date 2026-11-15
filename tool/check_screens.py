"""Checks that the screen list, the generated Dart registry and docs/SCREENS.md agree.
Run:  python3 tool/check_screens.py   (exit code 1 on any problem)
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from screens_data import SCREENS  # noqa: E402

problems = []
ids = [s[0] for s in SCREENS]
paths = [s[2] for s in SCREENS]
if len(set(ids)) != len(ids):
    problems.append("duplicate screen ids")
if len(set(paths)) != len(paths):
    problems.append("duplicate screen paths")

dart = open(os.path.join(ROOT, "lib/core/navigation/screen_registry.dart")).read()
doc = open(os.path.join(ROOT, "docs/SCREENS.md")).read()

dart_paths = re.findall(r"path: '([^']+)'", dart)
if sorted(dart_paths) != sorted(paths):
    problems.append("screen_registry.dart is out of date. Run tool/generate_screens.py")

for p in paths:
    if f"`{p}`" not in doc:
        problems.append(f"docs/SCREENS.md is missing {p}")

for s in SCREENS:
    perm, path = s[7], s[2]
    if s[6] == "permission" and not perm:
        problems.append(f"{s[0]}: permission screen without a permission")
    scoped = perm in {"editTournament", "manageRegistrations", "manageFixtures", "enterScore", "manageSquad",
                      "sendAnnouncement", "viewFinance", "manageFinance", "resolveProtest", "disqualifyTeam", "assignScorer"}
    if scoped and ":id" not in path:
        problems.append(f"{s[0]}: tournament permission needs :id in the path")
    if s[8] and ":" in path:
        problems.append(f"{s[0]}: hub screens cannot have parameters")
    if not re.match(r"^\d+B?\.\d+$", s[5]):
        problems.append(f"{s[0]}: bad step '{s[5]}'")

if problems:
    print("PROBLEMS:")
    for p in problems:
        print(" -", p)
    sys.exit(1)
print(f"ok: {len(SCREENS)} screens, registry and docs agree")
