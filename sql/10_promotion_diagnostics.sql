-- Summarize source promotion coverage
SELECT
    COUNT(*) AS promotion_records,
    COUNT(DISTINCT store_id) AS covered_stores,
    MIN(week_no) AS first_week,
    MAX(week_no) AS last_week
FROM raw.causal_data;


-- Count source promotion records by channel
SELECT
    CASE
        WHEN display <> '0' AND mailer <> '0' THEN 'display_and_mailer'
        WHEN display <> '0' THEN 'display_only'
        WHEN mailer <> '0' THEN 'mailer_only'
        ELSE 'no_promotion_code'
    END AS promotion_type,
    COUNT(*) AS promotion_records
FROM raw.causal_data
GROUP BY promotion_type
ORDER BY promotion_records DESC;


-- Inspect recorded display codes
SELECT
    display AS display_code,
    COUNT(*) AS promotion_records
FROM raw.causal_data
GROUP BY display
ORDER BY promotion_records DESC;


-- Inspect recorded mailer codes
SELECT
    mailer AS mailer_code,
    COUNT(*) AS promotion_records
FROM raw.causal_data
GROUP BY mailer
ORDER BY promotion_records DESC;
