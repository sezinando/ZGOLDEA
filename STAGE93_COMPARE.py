#!/usr/bin/env python3
"""Stage 93 helper: normalize and compare Zeus/ZGOLD observation traces.

The reference trace may be the compact Stage 92 schema:
Timestamp;EventType;Ticket;Direction;Lots;Price;ByTicket

The observed trace may contain the richer ReplayTraceRecord columns. Missing
fields are deliberately treated as unavailable rather than inferred.
"""
from __future__ import annotations

import argparse
from dataclasses import dataclass
from pathlib import Path
import pandas as pd

REQUIRED = ["Timestamp", "EventType", "Ticket", "Lots", "Price"]
OPTIONAL = ["Direction", "ByTicket"]


@dataclass
class Result:
    compared: int
    matches: int
    first_divergence: str
    divergence_class: str


def load_trace(path: Path) -> pd.DataFrame:
    df = pd.read_csv(path, sep=";", dtype=str)
    missing = [c for c in REQUIRED if c not in df.columns]
    if missing:
        raise ValueError(f"Missing required columns in {path}: {missing}")
    for c in ["Ticket", "Lots", "Price"]:
        df[c] = pd.to_numeric(df[c], errors="coerce")
    df["Timestamp"] = pd.to_datetime(df["Timestamp"], errors="coerce")
    return df


def compare(ref: pd.DataFrame, obs: pd.DataFrame, price_tol: float, lot_tol: float) -> Result:
    n = min(len(ref), len(obs))
    for i in range(n):
        r, o = ref.iloc[i], obs.iloc[i]

        if pd.isna(r.Timestamp) or pd.isna(o.Timestamp) or r.Timestamp != o.Timestamp:
            return Result(i + 1, i, str(o.get("Timestamp", "")), "D0_TEMPORAL_ALIGNMENT")
        if r.EventType != o.EventType:
            return Result(i + 1, i, str(o.Timestamp), "D1_EVENT")
        if "Direction" in ref.columns and "Direction" in obs.columns:
            if str(r.Direction).strip().lower() != str(o.Direction).strip().lower():
                return Result(i + 1, i, str(o.Timestamp), "D2_DIRECTION")
        if not pd.isna(r.Price) and not pd.isna(o.Price) and abs(r.Price - o.Price) > price_tol:
            return Result(i + 1, i, str(o.Timestamp), "D3_PRICE_OR_GEOMETRY")
        if not pd.isna(r.Lots) and not pd.isna(o.Lots) and abs(r.Lots - o.Lots) > lot_tol:
            return Result(i + 1, i, str(o.Timestamp), "D4_LOT_OR_LIFECYCLE")
        if "ByTicket" in ref.columns and "ByTicket" in obs.columns:
            rb = str(r.ByTicket)
            ob = str(o.ByTicket)
            if rb != ob and not (rb == "nan" and ob == "nan"):
                return Result(i + 1, i, str(o.Timestamp), "D4_LOT_OR_LIFECYCLE")

    if len(ref) != len(obs):
        ts = str(obs.iloc[n].Timestamp) if len(obs) > n else "EOF"
        return Result(n + 1, n, ts, "D1_EVENT")
    return Result(n, n, "", "NONE")


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("reference")
    ap.add_argument("observed")
    ap.add_argument("--price-tol", type=float, default=0.01)
    ap.add_argument("--lot-tol", type=float, default=0.01)
    args = ap.parse_args()

    ref = load_trace(Path(args.reference))
    obs = load_trace(Path(args.observed))
    result = compare(ref, obs, args.price_tol, args.lot_tol)

    print(f"REFERENCE_ROWS={len(ref)}")
    print(f"OBSERVED_ROWS={len(obs)}")
    print(f"COMPARED={result.compared}")
    print(f"MATCHES={result.matches}")
    print(f"STATUS={'MATCH' if result.divergence_class == 'NONE' else 'DIVERGENCE'}")
    print(f"FIRST_DIVERGENCE={result.first_divergence}")
    print(f"CLASS={result.divergence_class}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
