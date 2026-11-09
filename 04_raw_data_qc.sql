USE StoneyCreekWQ;

-- 1. DUPLICATES: same sample + analyte + fraction + method reported more than once
SELECT lab_sample_id, observed_property_id, fraction, analysis_method_id,
       COUNT(*) AS n_copies
FROM stg_raw_bc
GROUP BY lab_sample_id, observed_property_id, fraction, analysis_method_id
HAVING COUNT(*) > 1;
-- Expect 0 rows = "checked, no duplicates found"


-- 2a. UNITS: any analyte reported in more than one unit?
SELECT observed_property_id, COUNT(DISTINCT result_unit) AS n_units
FROM stg_raw_bc
GROUP BY observed_property_id
HAVING COUNT(DISTINCT result_unit) > 1;

-- 2b. UNITS vs. NYSDEC spelling: default (case-INsensitive) comparison
SELECT DISTINCT result_unit
FROM stg_raw_bc
WHERE result_unit NOT IN ('mg/l', 'us/cm');

-- 2c. Same check, case-SENSITIVE
SELECT DISTINCT result_unit
FROM stg_raw_bc
WHERE result_unit COLLATE Latin1_General_CS_AS NOT IN ('mg/l', 'us/cm');


-- 3. CAS NUMBERS: missing, or turned into dates
SELECT observed_property_id, cas_number,
       CASE WHEN cas_number IS NULL OR cas_number = '' THEN 'MISSING'
            WHEN cas_number LIKE '[12][0-9][0-9][0-9]-[01][0-9]-[0-3][0-9]' THEN 'LOOKS LIKE A DATE'
       END AS cas_problem,
       COUNT(*) AS n_rows
FROM stg_raw_bc
WHERE cas_number IS NULL OR cas_number = ''
   OR cas_number LIKE '[12][0-9][0-9][0-9]-[01][0-9]-[0-3][0-9]'
GROUP BY observed_property_id, cas_number
ORDER BY cas_problem, observed_property_id;