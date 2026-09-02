CREATE TABLE IF NOT EXISTS leads (
    id BIGSERIAL PRIMARY KEY,
    name TEXT,
    job_title TEXT,
    company TEXT,
    industry TEXT,
    location TEXT,
    agent TEXT,
    sdr_status TEXT,
    comment_status TEXT,
    hot_score NUMERIC,
    source TEXT,
    prioritized BOOLEAN,
    linkedin_url TEXT UNIQUE NOT NULL,
    added_on TIMESTAMP,
    last_contacted TIMESTAMP,
    invite_sent_at TIMESTAMP,
    connected_at TIMESTAMP
);