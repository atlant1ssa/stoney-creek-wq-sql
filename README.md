# Stoney Creek Water Quality – SQL Server Project

A small relational database (SQL Server / T-SQL) built from public BC Ministry of Environment
surface-water data for **Stoney Creek, Burnaby, BC** (EnMoDS location `E277911`, Station #5 at North Road).
It covers table design with primary/foreign keys, typed loading from staging tables,
non-detect handling, raw-data QC checks, and screening against BC Water Quality Guidelines.

## Data
| Item | Detail |
|---|---|
| Source | BC Environmental Monitoring Data System (EnMoDS), location E277911 |
| Samples | 4 grab samples (2010-01-27, 2010-02-10, 2010-02-19, 2012-10-09) |
| Results | 126 (metals, major ions, cyanide, conductivity, hardness); 33 non-detects |
| Lab | Maxxam Analytics (now Bureau Veritas) |
| Guidelines | BC Water Quality Guidelines, `all_wqgs.csv` – Aquatic Life (Freshwater), long-term chronic |
| Licence | Contains information licensed under the Open Government Licence – British Columbia |

Source results are flagged **Preliminary / Ungraded** in EnMoDS.

## Schema
```
locations (1) ──< samples (4) ──< results (126)
guidelines (16) ── matched to results by chemical name; hardness joined per sample
```
- Primary keys on every table; foreign keys enforce location → sample → result.
- `CHECK` constraints: `detect_flag` must be Y/N, and a non-detect cannot carry a `result_value`.
- `DECIMAL(18,9)` for concentrations (exact storage of values like 0.000005).

## Files
| File | Purpose |
|---|---|
| `01_schema.sql` | Create database and tables |
| `02_load.sql` | Insert location/samples; load results from a text staging table with type conversion and pre-checks |
| `03_nondetect_summary.sql` | Report non-detects as `<MDL`; per-analyte detect/non-detect summary |
| `04_raw_data_qc.sql` | Raw-file checks: duplicates, unit consistency (case-sensitive), CAS number validity |
| `05_guidelines.sql` | Guidelines table built from BC `all_wqgs.csv` (UniqueIDs retained) |
| `06_exceedances.sql` | View `v_guideline_screening` + detail and summary reports |

## Findings
**Raw-data QC (original BC export)**
- No duplicate results (sample + analyte + fraction + method).
- Cyanide CAS number `57-12-5` appears in the source export as the date `1957-12-05` (5 rows).
- 19 results across 6 analytes have no CAS number (iron, potassium, lead, lithium, hardness, conductivity).
- Units are consistent per analyte, but `mg/L` differs in case from the NYSDEC/EQuIS code `mg/l`;
  SQL Server's default case-insensitive collation hides this – it only appears with `COLLATE Latin1_General_CS_AS`.
- A trailing backslash in `sampling_agency` (`"20 - Lower Mainland\"`) caused the SSMS flat-file parser to
  treat the closing quote as escaped and shift every later column. Fixed in a copy; the original file is unchanged.
- Opening the export in Excel corrupted `µS/cm` to `ÂµS/cm` (encoding); loading as UTF-8 avoided it.

**Non-detects**
- 33 of 126 results are non-detects. Boron, lithium and both cyanide forms were never detected.
- Non-detects are reported as `<MDL` and summarised separately – never averaged as 0 or ignored.

**Guideline screening**
- 62 results had an applicable guideline (16 analytes): **44 below, 18 non-detects below, 0 exceedances, 0 inconclusive.**
- Cadmium uses the hardness-dependent guideline `exp(0.736·ln(H) − 4.943)` µg/L with each sample's own hardness.
- Logic: a non-detect is only "below" if its detection limit is below the guideline (otherwise *inconclusive*);
  a *total* result above a *dissolved* guideline is flagged *screen only*, since total ≥ dissolved.

## Limitations
- **Screening only, not compliance:** chronic guidelines are 30-day means of 5 samples; these are single grab samples.
- Not screened: aluminum, lead, zinc (guidelines need pH and/or DOC, not measured); copper, iron, manganese, nickel
  (model-based guidelines); chromium (species-specific guidelines); analytes with no BC freshwater guideline.
- Some guidelines have **Working** (not Approved) status; shown in the output.
- Chloride was measured dissolved against a total guideline (assumed fully dissolved).
- Longitude is reported to 1 decimal place in the source; `DECIMAL(9,6)` displays trailing zeros that are not real precision.

## How to run
1. SQL Server 2025 Express + SSMS.
2. Run `01_schema.sql`.
3. Import the cleaned results CSV into `stg_results` (SSMS → Tasks → Import Flat File, text columns), then run `02_load.sql`.
4. Import the raw BC export into `stg_raw_bc`, then run `03`–`06`.
