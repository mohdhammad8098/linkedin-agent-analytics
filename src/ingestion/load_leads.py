from src.db.connection import get_connection
import os
from pathlib import Path

import pandas as pd
import psycopg
from dotenv import load_dotenv

# Load environment variables from .env file
project_root = Path(__file__).resolve().parents[2]
load_dotenv(project_root/ ".env")

#csv location
csv_path= project_root/"raw_data"/"newton-leads-all-70-2026-08-26.csv"

# CSV → PostgreSQL column mapping
column_mapping= {
    "Name": "name",
    "Job Title": "job_title",
    "Company": "company",
    "Industry": "industry",
    "Location": "location",
    "Agent": "agent",
    "SDR Status": "sdr_status",
    "Comment Status": "comment_status",
    "Hot Score": "hot_score",
    "Source": "source",
    "Prioritized": "prioritized",
    "LinkedIn URL": "linkedin_url",
    "Added On": "added_on",
    "Last Contacted": "last_contacted",
    "Invite Sent At": "invite_sent_at",
    "Connected At": "connected_at",
    }

def load_leads():
    #Read csv
    df =pd.read_csv(csv_path)
    print(f"CSV rows found: {len(df)}")

    #Rename column
    df= df.rename(columns= column_mapping)

    # Convert timestamp columns to datetime
    timestamp_columns= [
        "added_on", 
        "last_contacted",
        "invite_sent_at", 
        "connected_at"
    ]

    for column in timestamp_columns:
        df[column]= pd.to_datetime(df[column], errors= "coerce")

    #convert empty values to none
    df= df.astype(object).where(pd.notna(df), None)


    connection= get_connection()

    insert_sql= """
    INSERT INTO leads (
        name, job_title, company, industry, location, agent, sdr_status,
        comment_status, hot_score, source, prioritized, linkedin_url,
        added_on, last_contacted, invite_sent_at, connected_at
    ) VALUES (
        %(name)s, %(job_title)s, %(company)s, %(industry)s, %(location)s,
        %(agent)s, %(sdr_status)s, %(comment_status)s, %(hot_score)s,
        %(source)s, %(prioritized)s, %(linkedin_url)s,
        %(added_on)s, %(last_contacted)s, %(invite_sent_at)s,
        %(connected_at)s
    )
    on conflict (linkedin_url) do nothing;
    """

    inserted= 0
    skipped= 0

    with connection:
        with connection.cursor() as cursor:
            for record in df.to_dict("records"):
                cursor.execute(insert_sql, record)

                if cursor.rowcount== 1:
                    inserted += 1
                else:
                    skipped += 1
    print("lead loading completed successfully.")
    print(f"Inserted: {inserted}")
    print(f"Skipped: {skipped}")
if __name__== "__main__":
    load_leads()