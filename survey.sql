CREATE TABLE "postgres"."Hospital_data".Tableau_File AS

WITH hospital_beds_prep AS 
(
    SELECT 
        LPAD(CAST(provider_ccn AS TEXT), 6, '0') AS provider_ccn,
        hospital_name,
        TO_DATE(fiscal_year_begin_date, 'MM/DD/YYYY') AS fiscal_year_begin_date,
        TO_DATE(fiscal_year_end_date, 'MM/DD/YYYY') AS fiscal_year_end_date,
        number_of_beds,
        row_number() OVER (PARTITION BY provider_ccn ORDER BY TO_DATE(fiscal_year_end_date, 'MM/DD/YYYY') DESC) AS nth_row
    FROM "Hospital_data".hospital_beds
)
-- Now the second part that uses the CTE defined above
SELECT 
    LPAD(CAST(hcahps.facility_id AS TEXT), 6, '0') AS provider_ccn
    ,TO_DATE(hcahps.start_date, 'MM/DD/YYYY') AS start_date_converted
    ,TO_DATE(hcahps.end_date, 'MM/DD/YYYY') AS end_date_converted
    ,hcahps.*
	,beds.number_of_beds
	,beds.fiscal_year_begin_date AS beds_start_report_period
	,beds.fiscal_year_end_date AS beds_end_report_period
	
FROM "Hospital_data"."hcahps_data" AS hcahps
LEFT JOIN hospital_beds_prep AS beds
    ON LPAD(CAST(hcahps.facility_id AS TEXT), 6, '0') = beds.provider_ccn
    AND beds.nth_row = 1;
