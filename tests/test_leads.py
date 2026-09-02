import pandas as pd


def test_csv_has_70_leads():
    df = pd.read_csv(
        "raw_data/newton-leads-all-70-2026-08-26.csv"
    )

    assert len(df) == 70


def test_linkedin_urls_are_unique():
    df = pd.read_csv(
        "raw_data/newton-leads-all-70-2026-08-26.csv"
    )

    urls = df["LinkedIn URL"].dropna()

    assert urls.is_unique


def test_replied_leads_count():
    df = pd.read_csv(
        "raw_data/newton-leads-all-70-2026-08-26.csv"
    )

    replied = (
        df["SDR Status"]
        .astype(str)
        .str.lower()
        .eq("replied")
        .sum()
    )

    assert replied == 25