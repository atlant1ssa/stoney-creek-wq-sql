-- 02_load.sql
-- Step 1: location and samples (5 rows, entered directly).
-- Step 2: results. The cleaned EDD (TestResultQC_v5 tab) was exported to results_import.csv
--         and loaded into staging table stg_results with SSMS "Import Flat File"
--         (all used columns as nvarchar(MAX)); 3 blank rows from the CSV were removed.
-- Step 3: typed insert from staging into results.
USE StoneyCreekWQ;

INSERT INTO locations (sys_loc_code, loc_name, loc_desc, loc_type, latitude, longitude)
VALUES ('E277911', 'STATION #5 AT NORTH ROAD; STONEY CREEK',
        'Station #5, Stoney Creek on Burnaby Mountain', 'SW', 49.27675, -122.9);

INSERT INTO samples (sys_sample_code, sys_loc_code, lab_sample_id, sample_date, matrix_code, sample_method)
VALUES ('E277911-20100127', 'E277911', 'S57219', '2010-01-27 13:30', 'WS', 'GB'),
       ('E277911-20100210', 'E277911', 'S76433', '2010-02-10 00:00', 'WS', 'GB'),
       ('E277911-20100219', 'E277911', 'S89385', '2010-02-19 00:00', 'WS', 'GB'),
       ('E277911-20121009', 'E277911', 'EV2993', '2012-10-09 00:00', 'WS', 'GB');

-- Remove blank rows carried over from the CSV export
DELETE FROM stg_results
WHERE sys_sample_code IS NULL OR LTRIM(RTRIM(sys_sample_code)) = '';

-- Pre-check: values that would not convert (expect 0 rows)
SELECT sys_sample_code, chemical_name, result_value, method_detection_limit, analysis_date
FROM stg_results
WHERE (NULLIF(LTRIM(RTRIM(result_value)),'') IS NOT NULL AND TRY_CAST(result_value AS FLOAT) IS NULL)
   OR (NULLIF(LTRIM(RTRIM(method_detection_limit)),'') IS NOT NULL AND TRY_CAST(method_detection_limit AS FLOAT) IS NULL)
   OR (NULLIF(LTRIM(RTRIM(analysis_date)),'') IS NOT NULL AND TRY_CAST(analysis_date AS DATETIME2) IS NULL);

INSERT INTO results (sys_sample_code, cas_rn, chemical_name, fraction,
                     result_value, result_unit, detect_flag,
                     method_detection_limit, detection_limit_unit,
                     lab_anl_method_name, analysis_date, result_comment)
SELECT
    LTRIM(RTRIM(sys_sample_code)),
    NULLIF(LTRIM(RTRIM(cas_rn)), ''),
    LTRIM(RTRIM(chemical_name)),
    NULLIF(LTRIM(RTRIM(fraction)), ''),
    CAST(TRY_CAST(NULLIF(LTRIM(RTRIM(result_value)), '') AS FLOAT) AS DECIMAL(18,9)),
    NULLIF(LTRIM(RTRIM(result_unit)), ''),
    LTRIM(RTRIM(detect_flag)),
    CAST(TRY_CAST(NULLIF(LTRIM(RTRIM(method_detection_limit)), '') AS FLOAT) AS DECIMAL(18,9)),
    NULLIF(LTRIM(RTRIM(detection_limit_unit)), ''),
    NULLIF(LTRIM(RTRIM(lab_anl_method_name)), ''),
    TRY_CAST(NULLIF(LTRIM(RTRIM(analysis_date)), '') AS DATETIME2),
    NULLIF(LTRIM(RTRIM(result_comment)), '')
FROM stg_results;

-- Verify: expect 126 results, 33 non-detects, 4 samples summing to 126
SELECT COUNT(*) AS total_results,
       SUM(CASE WHEN detect_flag = 'N' THEN 1 ELSE 0 END) AS non_detects
FROM results;

SELECT s.sys_sample_code, s.sample_date, COUNT(r.result_id) AS n_results
FROM samples AS s
LEFT JOIN results AS r ON r.sys_sample_code = s.sys_sample_code
GROUP BY s.sys_sample_code, s.sample_date
ORDER BY s.sample_date;
