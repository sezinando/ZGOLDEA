#!/usr/bin/env python3
"""Stage 92 reference extractor.

Normalizes the Zeus tester log into a compact event stream for replay comparison.
This tool does not infer missing behavior and does not execute trading logic.
"""

from __future__ import annotations

import csv
import re
import sys
from collections import Counter
from pathlib import Path

OPEN = re.compile(r"(?P<ts>\d{4}\.\d{2}\.\d{2} \d{2}:\d{2}:\d{2})\s+Zeus.*?: open #(?P<t>\d+) (?P<dir>buy stop|sell stop) (?P<lot>[0-9.]+) XAUUSD at (?P<p>[0-9.]+) ok")
EXEC = re.compile(r"(?P<ts>\d{4}\.\d{2}\.\d{2} \d{2}:\d{2}:\d{2})\s+Tester: order #(?P<t>\d+), (?P<dir>buy|sell) (?P<lot>[0-9.]+) XAUUSD is opened at (?P<p>[0-9.]+)")
MOD = re.compile(r"(?P<ts>\d{4}\.\d{2}\.\d{2} \d{2}:\d{2}:\d{2})\s+Zeus.*?: modify #(?P<t>\d+) (?P<dir>buy stop|sell stop) (?P<lot>[0-9.]+) XAUUSD at (?P<p>[0-9.]+)")
CB = re.compile(r"(?P<ts>\d{4}\.\d{2}\.\d{2} \d{2}:\d{2}:\d{2}).*order #(?P<t>\d+) was closed by order #(?P<by>\d+)")


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: stage92_observation_extract.py <Comportamento EA.log> <output.csv>")
        return 2

    src = Path(sys.argv[1])
    dst = Path(sys.argv[2])
    rows: list[list[object]] = []
    counts = Counter()

    for line in src.read_text(encoding="utf-8", errors="ignore").splitlines():
        m = OPEN.search(line)
        if m:
            rows.append([m["ts"], "CREATE", int(m["t"]), m["dir"], float(m["lot"]), float(m["p"]), ""])
            counts["CREATE"] += 1
            continue
        m = EXEC.search(line)
        if m:
            rows.append([m["ts"], "EXECUTE", int(m["t"]), m["dir"], float(m["lot"]), float(m["p"]), ""])
            counts["EXECUTE"] += 1
            continue
        m = MOD.search(line)
        if m:
            rows.append([m["ts"], "MODIFY", int(m["t"]), m["dir"], float(m["lot"]), float(m["p"]), ""])
            counts["MODIFY"] += 1
            continue
        m = CB.search(line)
        if m:
            rows.append([m["ts"], "CLOSEBY", int(m["t"]), "", 0.0, 0.0, int(m["by"])])
            counts["CLOSEBY"] += 1

    with dst.open("w", encoding="utf-8", newline="") as fh:
        writer = csv.writer(fh, delimiter=";")
        writer.writerow(["Timestamp", "EventType", "Ticket", "Direction", "Lots", "Price", "ByTicket"])
        writer.writerows(rows)

    print(f"rows={len(rows)}")
    for name in ("CREATE", "MODIFY", "EXECUTE", "CLOSEBY"):
        print(f"{name}={counts[name]}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
