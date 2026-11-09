-- 01_schema.sql
-- Stoney Creek (BC EnMoDS location E277911) water-quality database.
-- One location -> many samples -> many results.
CREATE DATABASE StoneyCreekWQ;
GO
USE StoneyCreekWQ;
GO

CREATE TABLE locations (
    sys_loc_code   VARCHAR(20)  NOT NULL PRIMARY KEY,
    loc_name       VARCHAR(40)  NOT NULL,
    loc_desc       VARCHAR(255) NULL,
    loc_type       VARCHAR(20)  NULL,
    latitude       DECIMAL(9,6) NOT NULL,
    longitude      DECIMAL(9,6) NOT NULL   -- source precision is 1 decimal; trailing zeros are display padding
);

CREATE TABLE samples (
    sys_sample_code  VARCHAR(40) NOT NULL PRIMARY KEY,
    sys_loc_code     VARCHAR(20) NOT NULL REFERENCES locations(sys_loc_code),
    lab_sample_id    VARCHAR(40) NULL,
    sample_date      DATETIME2   NOT NULL,
    matrix_code      VARCHAR(10) NULL,
    sample_method    VARCHAR(40) NULL
);

CREATE TABLE results (
    result_id              INT IDENTITY(1,1) PRIMARY KEY,
    sys_sample_code        VARCHAR(40)   NOT NULL REFERENCES samples(sys_sample_code),
    cas_rn                 VARCHAR(15)   NULL,
    chemical_name          VARCHAR(75)   NOT NULL,
    fraction               VARCHAR(10)   NULL,
    result_value           DECIMAL(18,9) NULL,   -- NULL for non-detects
    result_unit            VARCHAR(15)   NULL,
    detect_flag            CHAR(1)       NOT NULL CHECK (detect_flag IN ('Y','N')),
    method_detection_limit DECIMAL(18,9) NULL,
    detection_limit_unit   VARCHAR(15)   NULL,
    lab_anl_method_name    VARCHAR(20)   NULL,
    analysis_date          DATETIME2     NULL,
    result_comment         VARCHAR(255)  NULL,
    -- a non-detect must not carry a measured value
    CONSTRAINT ck_nondetect_blank CHECK (detect_flag = 'Y' OR result_value IS NULL)
);
