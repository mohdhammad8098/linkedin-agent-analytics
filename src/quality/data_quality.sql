-- 1. Completeness check
SELECT
    COUNT(*) AS total_leads,
    COUNT(name) AS name_present,
    COUNT(company) AS company_present,
    COUNT(job_title) AS job_title_present,
    COUNT(industry) AS industry_present,
    COUNT(location) AS location_present,
    COUNT(agent) AS agent_present,
    COUNT(sdr_status) AS sdr_status_present,
    COUNT(linkedin_url) AS linkedin_url_present
FROM public.leads;

-- 2. Uniqueness check
SELECT
    COUNT(*) AS total_leads,
    COUNT(linkedin_url) AS linkedin_urls_present,
    COUNT(DISTINCT linkedin_url) AS unique_linkedin_urls,
    COUNT(*) - COUNT(DISTINCT linkedin_url) AS duplicate_count
FROM public.leads;

-- 3. Validity check
SELECT
    COUNT(*) AS total_leads,
    COUNT(*) FILTER (
        WHERE linkedin_url LIKE 'http%'
    ) AS valid_linkedin_urls,
    COUNT(*) FILTER (
        WHERE hot_score IS NOT NULL
        AND hot_score >= 0
    ) AS valid_hot_scores,
    COUNT(*) FILTER (
        WHERE sdr_status IS NOT NULL
    ) AS valid_sdr_status
FROM public.leads;

-- 4. Timeliness check
SELECT
    COUNT(*) AS total_leads,
    COUNT(added_on) AS leads_with_added_date,
    MIN(added_on) AS earliest_added,
    MAX(added_on) AS latest_added
FROM public.leads;

-- 5. Composite Data Quality score
WITH dq AS (
    SELECT
        COUNT(*) AS total_leads,

        -- Completeness
        COUNT(name) * 100.0 / COUNT(*) AS name_completeness,
        COUNT(company) * 100.0 / COUNT(*) AS company_completeness,
        COUNT(job_title) * 100.0 / COUNT(*) AS job_title_completeness,
        COUNT(industry) * 100.0 / COUNT(*) AS industry_completeness,

        -- Uniqueness
        COUNT(DISTINCT linkedin_url) * 100.0
            / NULLIF(COUNT(linkedin_url), 0) AS uniqueness,

        -- Validity
        COUNT(*) FILTER (
            WHERE linkedin_url LIKE 'http%'
        ) * 100.0 / COUNT(*) AS linkedin_validity,

        -- Timeliness / date availability
        COUNT(added_on) * 100.0 / COUNT(*) AS timeliness
    FROM public.leads
)

SELECT
    ROUND(
        (
            name_completeness +
            company_completeness +
            job_title_completeness +
            industry_completeness +
            uniqueness +
            linkedin_validity +
            timeliness
        ) / 7,
        2
    ) AS overall_dq_score
FROM dq;

-- 6. Referential Integrity Check

SELECT
    COUNT(*) AS total_fact_records,
    COUNT(*) FILTER (
        WHERE dl.lead_key IS NULL
    ) AS orphan_leads
FROM fact_lead_activity f
LEFT JOIN dim_lead dl
    ON f.lead_key = dl.lead_key;

-- 7. DQ Results History

CREATE TABLE IF NOT EXISTS dq_results (
    dq_run_id BIGSERIAL PRIMARY KEY,
    run_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total_records INTEGER NOT NULL,
    dq_score NUMERIC(5,2) NOT NULL,
    pass_threshold NUMERIC(5,2) NOT NULL DEFAULT 80.00,
    status TEXT NOT NULL
);

INSERT INTO dq_results (
    total_records,
    dq_score,
    status
)
VALUES (
    70,
    83.67,
    CASE
        WHEN 83.67 >= 80.00 THEN 'PASS'
        ELSE 'FAIL'
    END
);

SELECT *
FROM dq_results;