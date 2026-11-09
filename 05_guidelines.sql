USE StoneyCreekWQ;
DROP TABLE IF EXISTS guidelines;

CREATE TABLE guidelines (
    guideline_id        INT IDENTITY(1,1) PRIMARY KEY,
    bc_wqg_id           INT           NOT NULL,
    chemical_name       VARCHAR(75)   NOT NULL,
    guideline_fraction  VARCHAR(10)   NOT NULL,
    limit_value         DECIMAL(18,6) NULL,
    limit_unit          VARCHAR(10)   NOT NULL,
    hardness_min        DECIMAL(10,2) NULL,
    hardness_max        DECIMAL(10,2) NULL,
    hardness_slope      DECIMAL(10,4) NULL,
    hardness_intercept  DECIMAL(10,4) NULL,
    status              VARCHAR(20)   NOT NULL,
    notes               VARCHAR(255)  NULL
);

INSERT INTO guidelines (bc_wqg_id, chemical_name, guideline_fraction, limit_value, limit_unit, hardness_min, hardness_max, hardness_slope, hardness_intercept, status, notes)
VALUES
(100, 'Antimony Total (fl. conc.)', 'Total', 74, 'ug/L', NULL, NULL, NULL, NULL, 'Approved', NULL),
(107, 'Arsenic Total (fl. conc.)', 'Total', 5, 'ug/L', NULL, NULL, NULL, NULL, 'Approved', NULL),
(116, 'Barium Total (fl. conc.)', 'Total', 1, 'mg/L', NULL, NULL, NULL, NULL, 'Working', NULL),
(143, 'Beryllium Total (fl. conc.)', 'Total', 0.13, 'ug/L', NULL, NULL, NULL, NULL, 'Working', NULL),
(154, 'Boron Total (fl. conc.)', 'Total', 1.2, 'mg/L', NULL, NULL, NULL, NULL, 'Approved', NULL),
(196, 'Chloride Dissolved (fl. conc.)', 'Total', 150, 'mg/L', NULL, NULL, NULL, NULL, 'Approved', 'Guideline is total; dissolved measured. Assumes chloride fully dissolved.'),
(272, 'Cobalt Total (fl. conc.)', 'Dissolved', 0.39, 'ug/L', NULL, 52, NULL, NULL, 'Approved', 'Applies when hardness <= 52 mg/L'),
(167, 'Cadmium Total (fl. conc.)', 'Dissolved', NULL, 'ug/L', 3.4, 285, 0.736, -4.943, 'Approved', 'Hardness-dependent: exp(0.736*ln(H) - 4.943)'),
(313, 'Cyanide WAD (fl. conc.)', 'Total', 5, 'ug/L', NULL, NULL, NULL, NULL, 'Approved', NULL),
(559, 'Molybdenum Total (fl. conc.)', 'Total', 7.6, 'mg/L', NULL, NULL, NULL, NULL, 'Approved', NULL),
(719, 'Selenium Total (fl. conc.)', 'Total', 2, 'ug/L', NULL, NULL, NULL, NULL, 'Approved', NULL),
(724, 'Silver Total (fl. conc.)', 'Total', 0.12, 'ug/L', NULL, NULL, NULL, NULL, 'Approved', NULL),
(772, 'Thallium Total (fl. conc.)', 'Total', 0.03, 'ug/L', NULL, NULL, NULL, NULL, 'Working', NULL),
(817, 'Uranium Total (fl. conc.)', 'Total', 7.5, 'ug/L', NULL, NULL, NULL, NULL, 'Working', NULL),
(822, 'Vanadium Total (fl. conc.)', 'Total', 60, 'ug/L', NULL, NULL, NULL, NULL, 'Working', NULL),
(1174, 'Strontium Total (fl. conc.)', 'Dissolved', 1250, 'ug/L', NULL, NULL, NULL, NULL, 'Working', NULL);

SELECT COUNT(*) AS n_guidelines FROM guidelines;