"""
Cleans data/raw/superstore.csv and loads it into retail_analytics.db.

Run from the project root:
    python scripts/clean_data.py
"""

import re
import sqlite3
from pathlib import Path

import pandas as pd

PROJECT_ROOT = Path(__file__).resolve().parent.parent
RAW_PATH = PROJECT_ROOT / "data" / "raw" / "superstore.csv"
CLEANED_PATH = PROJECT_ROOT / "data" / "cleaned" / "superstore_cleaned.csv"
DB_PATH = PROJECT_ROOT / "retail_analytics.db"

# Collects one log line per cleaning decision, written out to
# validation/qa_report.md by build_qa_report() so every change is traceable.
change_log = []


def log(message):
    change_log.append(message)
    print(message)


def to_snake_case(name):
    name = name.strip()
    name = re.sub(r"[\s\-]+", "_", name)
    name = re.sub(r"([a-z0-9])([A-Z])", r"\1_\2", name)
    return name.lower()


def load_raw():
    # Source file is Excel-exported and not valid UTF-8 (contains cp1252-only
    # characters, e.g. non-breaking spaces / curly quotes in product names).
    df = pd.read_csv(RAW_PATH, encoding="cp1252")
    log(f"Loaded raw file: {RAW_PATH.name} — {len(df)} rows, {len(df.columns)} columns (encoding=cp1252)")
    return df


def standardize_columns(df):
    original = list(df.columns)
    df.columns = [to_snake_case(c) for c in df.columns]
    log(f"Standardized column names to snake_case: {original} -> {list(df.columns)}")
    return df


def parse_dates(df):
    for col in ["order_date", "ship_date"]:
        before_nulls = df[col].isna().sum()
        df[col] = pd.to_datetime(df[col], format="%m/%d/%Y", errors="coerce")
        after_nulls = df[col].isna().sum()
        unparseable = after_nulls - before_nulls
        if unparseable:
            log(f"WARNING: {unparseable} values in '{col}' could not be parsed as dates and were set to NaT")
        else:
            log(f"Parsed '{col}' to datetime (no parsing failures)")
    return df


def drop_duplicates(df):
    before = len(df)
    dupes = df[df.duplicated(keep="first")]
    df = df.drop_duplicates(keep="first").reset_index(drop=True)
    removed = before - len(df)
    log(f"Duplicate rows removed: {removed} (kept first occurrence of each)")
    return df, removed


def handle_missing_values(df):
    null_counts = df.isna().sum()
    null_counts = null_counts[null_counts > 0]

    if null_counts.empty:
        log("No missing values found in any column")
        return df, {}

    handling = {}
    for col, count in null_counts.items():
        if col == "postal_code":
            df[col] = df[col].fillna(0).astype("Int64")
            handling[col] = f"{count} nulls filled with 0 (unknown postal code) — postal code is not used in any analysis, only descriptive"
        else:
            handling[col] = f"{count} nulls left as-is (no safe default; flagged for review)"
        log(f"Missing values in '{col}': {handling[col]}")
    return df, handling


def clean_categorical_text(df):
    categorical_cols = [
        "ship_mode", "segment", "country", "city", "state", "region",
        "category", "sub_category", "product_name", "customer_name",
    ]
    fixes = {}
    for col in categorical_cols:
        if col not in df.columns:
            continue
        before_values = df[col].copy()
        df[col] = df[col].astype(str).str.strip()
        df[col] = df[col].str.replace(r"\s+", " ", regex=True)
        if col in ["ship_mode", "segment", "region", "category", "sub_category", "country"]:
            df[col] = df[col].str.title()
        changed = (before_values.astype(str) != df[col]).sum()
        if changed:
            fixes[col] = changed
            log(f"Normalized whitespace/casing in '{col}': {changed} values changed")
    return df, fixes


def flag_outliers(df):
    negative_profit = int((df["profit"] < 0).sum())
    log(f"Rows with negative profit (loss-making orders): {negative_profit} — kept, flagged via 'is_loss' column")
    df["is_loss"] = df["profit"] < 0

    high_discount = int((df["discount"] >= 0.5).sum())
    log(f"Rows with discount >= 50%: {high_discount} — kept, flagged via 'is_high_discount' column")
    df["is_high_discount"] = df["discount"] >= 0.5

    zero_or_negative_sales = int((df["sales"] <= 0).sum())
    log(f"Rows with sales <= 0: {zero_or_negative_sales} — none dropped, informational only")

    return df


def add_calculated_columns(df):
    df["order_year"] = df["order_date"].dt.year
    df["order_month"] = df["order_date"].dt.month
    df["profit_margin"] = df["profit"] / df["sales"]
    log("Added calculated columns: order_year, order_month, profit_margin (profit / sales)")
    return df


def export_cleaned(df):
    CLEANED_PATH.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(CLEANED_PATH, index=False)
    log(f"Exported cleaned dataset to {CLEANED_PATH.relative_to(PROJECT_ROOT)} ({len(df)} rows)")


def load_to_sqlite(df):
    conn = sqlite3.connect(DB_PATH)
    df.to_sql("sales_orders", conn, if_exists="replace", index=False)
    conn.close()
    log(f"Loaded {len(df)} rows into table 'sales_orders' in {DB_PATH.name}")


def write_change_log():
    log_path = PROJECT_ROOT / "validation" / "clean_data_log.txt"
    log_path.parent.mkdir(parents=True, exist_ok=True)
    with open(log_path, "w") as f:
        f.write("\n".join(change_log))
    print(f"\nFull change log written to {log_path.relative_to(PROJECT_ROOT)}")


def main():
    df = load_raw()
    df = standardize_columns(df)
    df = parse_dates(df)
    df, _ = drop_duplicates(df)
    df, _ = handle_missing_values(df)
    df, _ = clean_categorical_text(df)
    df = flag_outliers(df)
    df = add_calculated_columns(df)
    export_cleaned(df)
    load_to_sqlite(df)
    write_change_log()


if __name__ == "__main__":
    main()
