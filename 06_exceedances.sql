-- 06_exceedances.sql
-- Screening comparison of single grab-sample results against BC long-term chronic
-- freshwater aquatic life guidelines (30-day means). SCREENING ONLY, not compliance.
USE StoneyCreekWQ;
GO

CREATE OR ALTER VIEW v_guideline_screening AS
WITH hardness AS (
    SELECT sys_sample_code, result_value AS hardness_mg_l
    FROM results
    WHERE cas_rn = 'HARD'
),
compared AS (
    SELECT s.sample_date, r.chemical_name, r.detect_flag, r.fraction AS result_fraction,
           r.result_value, r.method_detection_limit,
           COALESCE(r.result_unit, r.detection_limit_unit) AS unit,
           h.hardness_mg_l, g.guideline_fraction, g.status, g.bc_wqg_id,
           CASE
             WHEN (g.hardness_min IS NOT NULL AND (h.hardness_mg_l IS NULL OR h.hardness_mg_l <= g.hardness_min))
               OR (g.hardness_max IS NOT NULL AND (h.hardness_mg_l IS NULL OR h.hardness_mg_l >  g.hardness_max))
               THEN NULL
             WHEN g.hardness_slope IS NOT NULL
               THEN EXP(g.hardness_slope * LOG(h.hardness_mg_l) + g.hardness_intercept) / 1000.0
             WHEN g.limit_unit = 'ug/L' THEN g.limit_value / 1000.0
             ELSE g.limit_value
           END AS guideline_mg_l
    FROM results    AS r
    JOIN samples    AS s ON s.sys_sample_code = r.sys_sample_code
    JOIN guidelines AS g ON g.chemical_name   = r.chemical_name
    LEFT JOIN hardness AS h ON h.sys_sample_code = r.sys_sample_code
)
SELECT sample_date, chemical_name, detect_flag, result_value, method_detection_limit, unit,
       CAST(guideline_mg_l AS DECIMAL(18,9)) AS guideline_mg_l,
       guideline_fraction, status, bc_wqg_id, hardness_mg_l,
       CASE
         WHEN unit <> 'mg/l'                                THEN 'UNIT NOT COMPARABLE'
         WHEN guideline_mg_l IS NULL                        THEN 'NO GUIDELINE (hardness out of range)'
         WHEN detect_flag = 'N'
              AND method_detection_limit <= guideline_mg_l  THEN 'BELOW (non-detect)'
         WHEN detect_flag = 'N'                             THEN 'INCONCLUSIVE (MDL above guideline)'
         WHEN result_value <= guideline_mg_l                THEN 'BELOW'
         WHEN guideline_fraction = 'Dissolved'
              AND result_fraction = 'T'                     THEN 'SCREEN ONLY: total above dissolved guideline'
         ELSE 'EXCEEDS'
       END AS assessment
FROM compared;
GO

-- Detail: every result compared to its guideline
SELECT *
FROM v_guideline_screening
ORDER BY assessment, chemical_name, sample_date;

-- Summary: how many results fall in each category
SELECT assessment, COUNT(*) AS n_results
FROM v_guideline_screening
GROUP BY assessment
ORDER BY assessment;
