--1 Total number of leaads
select count(*) as total_leads 
from public.leads;

-- 2. Number of leads assigned to each agent
select agent, count(*) as total_leads
from public.leads
group by agent
order by total_leads desc;

-- 3. Number of leads by SDR status
select sdr_status, count(*) as total_leads
from public.leads
group by sdr_status
order by total_leads desc;

-- 4. Number of prioritized vs non-prioritized leads
select prioritized, count(*) as total_leads
from public.leads
group by prioritized
order  by total_leads desc;

-- 5. Hot score summary
select count(*) as total_leads,
	round(avg(hot_score), 2) as average_hot_score,
	max(hot_score) as maximum_hot_score,
	min(hot_score) as minimum_hot_score
from public.leads;


-- 6. Contacted vs not contacted leads
select 
	case
		when last_contacted is null then 'Not Contacted'
		else 'Contacted'
		end as Contact_status,
		count(*) as total_leads
from public.leads
group by last_contacted
order by total_leads desc;


-- 7. Connected vs not connected leads
select
	case
		when connected_at is null then 'Not Contacted'
		else 'Contacted'
		end as Connection_status,
		count(*) as total_leads
from public.leads
group by Connection_status
order by total_leads desc;

-- 8. Connection rate
select count(*) as total_leads,
    count(connected_at) as connected_leads,
    round(count(connected_at)*100.0/ nullif(count(*) ,0) ,2) as connection_rate_percentage
from public.leads;


-- 9. Leads by source
select source, count(*) as total_leads
from public.leads
group by source
order by total_leads desc;

-- 10. Leads by industry
select industry, count(*) as total_leads
from public.leads
group by industry
order by total_leads desc;

-- 11. Leads by location
select location , count(*) as total_leads
from public.leads
group by location
order by total_leads desc;

-- 12. Top 10 hottest leads
select
    name,
    job_title,
    company,
    indusstry,
    hot_score,
    linkedin_url,
from public.leads
where sdr_status = 'replied'
order by sdr_status desc
limit 10;


-- ============================================================
-- Risk / Anomaly Summary
-- ============================================================

SELECT
    COUNT(*) AS total_leads,

    COUNT(*) FILTER (
        WHERE company IS NULL
    ) AS missing_company,

    COUNT(*) FILTER (
        WHERE industry IS NULL
    ) AS missing_industry,

    COUNT(*) FILTER (
        WHERE hot_score IS NULL
    ) AS missing_hot_score,

    COUNT(*) FILTER (
        WHERE invite_sent_at IS NULL
    ) AS missing_invite_timestamp,

    COUNT(*) FILTER (
        WHERE connected_at IS NULL
    ) AS not_connected
FROM public.leads;

-- ============================================================
-- POWER BI DATASET
-- ============================================================

CREATE OR REPLACE VIEW powerbi_lead_summary AS
SELECT
    l.id,
    l.name,
    l.job_title,
    l.company,
    l.industry,
    l.location,
    l.agent,
    l.sdr_status,
    l.comment_status,
	l.source,
    l.prioritized,
    l.linkedin_url,
    l.added_on,
    l.last_contacted,
    l.invite_sent_at,
    l.connected_at,

    CASE
        WHEN l.invite_sent_at IS NOT NULL THEN 1
        ELSE 0
    END AS invite_sent,

    CASE
        WHEN l.connected_at IS NOT NULL THEN 1
        ELSE 0
    END AS connected,

    CASE
        WHEN LOWER(l.sdr_status) = 'replied' THEN 1
        ELSE 0
    END AS replied,

    COALESCE(r.risk_score, 0) AS risk_score,

    CASE
        WHEN r.risk_score >= 60 THEN 'High'
        WHEN r.risk_score >= 30 THEN 'Medium'
        ELSE 'Low'
    END AS risk_level

FROM public.leads l
LEFT JOIN lead_risk_scores r
    ON l.id = r.id;