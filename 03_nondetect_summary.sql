USE StoneyCreekWQ;

-- How results should be REPORTED: non-detects shown as "<MDL", never as 0 or blank
SELECT s.sample_date,
       r.chemical_name,
       CASE WHEN r.detect_flag = 'N'
            THEN '<' + CONVERT(VARCHAR(20), CAST(r.method_detection_limit AS FLOAT))
            ELSE CONVERT(VARCHAR(20), CAST(r.result_value AS FLOAT))
       END AS reported_value,
       COALESCE(r.result_unit, r.detection_limit_unit) AS unit
FROM results AS r
JOIN samples AS s ON s.sys_sample_code = r.sys_sample_code
ORDER BY r.chemical_name, s.sample_date;

-- Per-analyte summary that keeps detects and non-detects separate
SELECT chemical_name,
       COUNT(*) AS n_results,
       SUM(CASE WHEN detect_flag = 'Y' THEN 1 ELSE 0 END) AS n_detected,
       MAX(CASE WHEN detect_flag = 'Y' THEN result_value END) AS max_detected,
       MAX(CASE WHEN detect_flag = 'N' THEN method_detection_limit END) AS highest_nd_limit
FROM results
GROUP BY chemical_name
ORDER BY n_detected, chemical_name;