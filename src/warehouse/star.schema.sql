-- STAR SCHEMA FOR LINKEDIN AGENT ANALYTICS

-- 1. Date dimension
CREATE TABLE IF NOT EXISTS dim_date (
    date_key INTEGER PRIMARY KEY,
    full_date DATE UNIQUE NOT NULL,
    year INTEGER NOT NULL,
    month INTEGER NOT NULL,
    month_name TEXT NOT NULL,
    day INTEGER NOT NULL
);


-- 2. Agent dimension
CREATE TABLE IF NOT EXISTS dim_agent (
    agent_key BIGSERIAL PRIMARY KEY,
    agent_name TEXT UNIQUE NOT NULL
);


-- 3. Lead dimension
CREATE TABLE IF NOT EXISTS dim_lead (
    lead_key BIGSERIAL PRIMARY KEY,
    source_lead_id BIGINT UNIQUE NOT NULL,
    name TEXT,
    job_title TEXT,
    company TEXT,
    industry TEXT,
    location TEXT,
    linkedin_url TEXT UNIQUE NOT NULL
);


-- 4. Source dimension
CREATE TABLE IF NOT EXISTS dim_source (
    source_key BIGSERIAL PRIMARY KEY,
    source_name TEXT UNIQUE NOT NULL
);


-- 5. Lead activity fact table
CREATE TABLE IF NOT EXISTS fact_lead_activity (
    activity_key BIGSERIAL PRIMARY KEY,

    lead_key BIGINT NOT NULL,
    agent_key BIGINT,
    date_key INTEGER,
    source_key BIGINT,

    sdr_status TEXT,
    comment_status TEXT,
    prioritized BOOLEAN,

    hot_score NUMERIC,

    invite_sent BOOLEAN NOT NULL DEFAULT FALSE,
    contacted BOOLEAN NOT NULL DEFAULT FALSE,
    connected BOOLEAN NOT NULL DEFAULT FALSE,
    replied BOOLEAN NOT NULL DEFAULT FALSE,

    added_at TIMESTAMP,
    last_contacted_at TIMESTAMP,
    invite_sent_at TIMESTAMP,
    connected_at TIMESTAMP,

    CONSTRAINT fk_fact_lead
        FOREIGN KEY (lead_key)
        REFERENCES dim_lead(lead_key),

    CONSTRAINT fk_fact_agent
        FOREIGN KEY (agent_key)
        REFERENCES dim_agent(agent_key),

    CONSTRAINT fk_fact_date
        FOREIGN KEY (date_key)
        REFERENCES dim_date(date_key),

    CONSTRAINT fk_fact_source
        FOREIGN KEY (source_key)
        REFERENCES dim_source(source_key)
);


-- ============================================================
-- LOAD DIMENSIONS
-- ============================================================

-- Agent dimension
INSERT INTO dim_agent (agent_name)
SELECT DISTINCT agent
FROM public.leads
WHERE agent IS NOT NULL
ON CONFLICT (agent_name) DO NOTHING;


-- Source dimension
INSERT INTO dim_source (source_name)
SELECT DISTINCT source
FROM public.leads
WHERE source IS NOT NULL
ON CONFLICT (source_name) DO NOTHING;


-- Lead dimension
INSERT INTO dim_lead (
    source_lead_id,
    name,
    job_title,
    company,
    industry,
    location,
    linkedin_url
)
SELECT
    id,
    name,
    job_title,
    company,
    industry,
    location,
    linkedin_url
FROM public.leads
ON CONFLICT (source_lead_id) DO NOTHING;


-- Date dimension
INSERT INTO dim_date (
    date_key,
    full_date,
    year,
    month,
    month_name,
    day
)
SELECT DISTINCT
    TO_CHAR(added_on::date, 'YYYYMMDD')::INTEGER,
    added_on::date,
    EXTRACT(YEAR FROM added_on)::INTEGER,
    EXTRACT(MONTH FROM added_on)::INTEGER,
    TO_CHAR(added_on, 'Month'),
    EXTRACT(DAY FROM added_on)::INTEGER
FROM public.leads
WHERE added_on IS NOT NULL
ON CONFLICT (date_key) DO NOTHING;


-- LOAD FACT TABLE

INSERT INTO fact_lead_activity (
    lead_key,
    agent_key,
    date_key,
    source_key,
    sdr_status,
    comment_status,
    prioritized,
    hot_score,
    invite_sent,
    contacted,
    connected,
    replied,
    added_at,
    last_contacted_at,
    invite_sent_at,
    connected_at
)
SELECT
    dl.lead_key,
    da.agent_key,
    dd.date_key,
    ds.source_key,

    l.sdr_status,
    l.comment_status,
    l.prioritized,
    l.hot_score,

    CASE
        WHEN l.invite_sent_at IS NOT NULL THEN TRUE
        ELSE FALSE
    END,

    CASE
        WHEN l.last_contacted IS NOT NULL THEN TRUE
        ELSE FALSE
    END,

    CASE
        WHEN l.connected_at IS NOT NULL THEN TRUE
        ELSE FALSE
    END,

    CASE
        WHEN LOWER(l.sdr_status) = 'replied' THEN TRUE
        ELSE FALSE
    END,

    l.added_on,
    l.last_contacted,
    l.invite_sent_at,
    l.connected_at

FROM public.leads l

JOIN dim_lead dl
    ON dl.source_lead_id = l.id

LEFT JOIN dim_agent da
    ON da.agent_name = l.agent

LEFT JOIN dim_source ds
    ON ds.source_name = l.source

LEFT JOIN dim_date dd
    ON dd.full_date = l.added_on::date

WHERE NOT EXISTS (
    SELECT 1
    FROM fact_lead_activity f
    WHERE f.lead_key = dl.lead_key
);


-- ============================================================
-- KPI 1: Total Leads
-- ============================================================

SELECT
    COUNT(*) AS total_leads
FROM public.leads;


-- ============================================================
-- KPI 2: Invites Sent
-- ============================================================

SELECT
    COUNT(*) AS invites_sent
FROM public.leads
WHERE invite_sent_at IS NOT NULL;


-- ============================================================
-- KPI 3: Connections
-- ============================================================

SELECT
    COUNT(*) AS connections
FROM public.leads
WHERE connected_at IS NOT NULL;


-- ============================================================
-- KPI 4: Connection Rate
-- ============================================================

SELECT
    CASE
        WHEN COUNT(invite_sent_at) = 0 THEN NULL
        ELSE ROUND(
            COUNT(connected_at) * 100.0
            / COUNT(invite_sent_at),
            2
        )
    END AS connection_rate_percent
FROM public.leads;


-- ============================================================
-- KPI 5: Reply Rate
-- ============================================================

SELECT
    ROUND(
        COUNT(*) FILTER (
            WHERE LOWER(sdr_status) = 'replied'
        ) * 100.0
        / NULLIF(COUNT(*), 0),
        2
    ) AS reply_rate_percent
FROM public.leads;

-- STAR SCHEMA VERIFICATION

SELECT
    (SELECT COUNT(*) FROM dim_lead) AS dimension_leads,
    (SELECT COUNT(*) FROM dim_agent) AS dimension_agents,
    (SELECT COUNT(*) FROM dim_source) AS dimension_sources,
    (SELECT COUNT(*) FROM dim_date) AS dimension_dates,
    (SELECT COUNT(*) FROM fact_lead_activity) AS fact_records;