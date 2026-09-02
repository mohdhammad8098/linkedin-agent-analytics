import os
from pathlib import Path

import psycopg
from dotenv import load_dotenv

# Finding the project roots
project_root= Path(__file__).resolve().parents[2]

#load enviorment variables
load_dotenv (project_root/ ".env")


def get_connection():
    """Create and return a postgreSQL database connection"""
    return psycopg.connect(
        host= os.getenv("DB_HOST"),
        port= int(os.getenv("DB_PORT")),
        dbname= os.getenv("DB_NAME"),
        user= os.getenv("DB_USER"),
        password= os.getenv("DB_PASSWORD")
    )