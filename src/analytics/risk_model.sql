-- ============================================================
-- LEAD RISK MODEL
-- ============================================================

DROP VIEW IF EXISTS lead_risk_scores;

CREATE VIEW lead_risk_scores AS
SELECT
    id,
    name,
    company,
    industry,
    agent,
    sdr_status,
    prioritized,
    linkedin_url,

    -- Risk points
    (
        CASE
            WHEN company IS NULL THEN 20
            ELSE 0
        END

        +

        CASE
            WHEN industry IS NULL THEN 20
            ELSE 0
        END

        +

        CASE
            WHEN invite_sent_at IS NULL THEN 20
            ELSE 0
        END

        +

        CASE
            WHEN connected_at IS NULL
                 AND invite_sent_at IS NOT NULL
            THEN 20
            ELSE 0
        END

        +

        CASE
            WHEN LOWER(sdr_status) NOT IN ('replied', 'connected')
                 OR sdr_status IS NULL
            THEN 20
            ELSE 0
        END
    ) AS risk_score

FROM public.leads;


-- ============================================================
-- RISK CLASSIFICATION
-- ============================================================

SELECT
    id,
    name,
    company,
    industry,
    sdr_status,
    risk_score,

    CASE
        WHEN risk_score >= 60 THEN 'High'
        WHEN risk_score >= 30 THEN 'Medium'
        ELSE 'Low'
    END AS risk_level

FROM lead_risk_scores
ORDER BY risk_score DESC;