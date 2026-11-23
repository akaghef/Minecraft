"""Reject contact information and credential files in tracked files and Git history.

Print locations only: never print a matched contact or secret.
"""
import re
import subprocess
import sys
from pathlib import Path

EMAIL = re.compile(rb"[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}")
PHONE = re.compile(rb"(?<![\dA-Za-z])(?:\+81[- .]?[1-9]\d{0,3}[- .]?\d{2,4}[- .]?\d{3,4}|0[5789]0[- .]?\d{4}[- .]?\d{4}|0\d{1,4}-\d{1,4}-\d{3,4})(?![\dA-Za-z])")
SECRET = re.compile(rb"(?:gh[pousr]_[A-Za-z0-9]{20,}|sk-[A-Za-z0-9]{24,}|-----BEGIN [A-Z ]*PRIVATE KEY-----)")
FORBIDDEN = {"launcher_accounts.json", "launcher_profiles.json", "servers.dat", "usercache.json", ".env"}


def problems(data, label):
    return [f"{label}: {kind}" for kind, pattern in [("email", EMAIL), ("telephone", PHONE), ("credential", SECRET)] if pattern.search(data)]


def main():
    root = Path(__file__).resolve().parents[1]
    def git(*args):
        return subprocess.check_output(["git", *args], cwd=root)
    failures = []
    for item in git("ls-files", "-z").split(b"\0"):
        if not item:
            continue
        name = item.decode()
        if Path(name).name in FORBIDDEN:
            failures.append(f"{name}: forbidden file")
        path = root / name
        if path.is_file():
            failures.extend(problems(path.read_bytes(), name))
    commits = subprocess.run(["git", "rev-list", "--all"], cwd=root, capture_output=True, text=True).stdout.splitlines()
    checked = set()
    for commit in commits:
        failures.extend(problems(git("show", "-s", "--format=%an%n%ae%n%cn%n%ce%n%B", commit), "commit metadata"))
        for row in git("ls-tree", "-r", commit).decode().splitlines():
            meta, name = row.split("\t", 1)
            mode, kind, blob = meta.split()
            if kind != "blob" or blob in checked:
                continue
            checked.add(blob)
            failures.extend(problems(git("cat-file", "blob", blob), "history:" + name))
    print("\n".join(sorted(set(failures))) if failures else "PASS: tracked files and all committed history contain no detected contacts or credentials")
    return bool(failures)


if __name__ == "__main__":
    sys.exit(main())
