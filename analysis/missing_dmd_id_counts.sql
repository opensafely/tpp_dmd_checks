-- Internal project for data curation, no need for AllowedPatientsWithTypeOneDissent

;with
    cte
    as
    (
        SELECT
            d.MultilexDrug_ID,
            d.dmd_id,
            d.FullName,
            cast(count(*) as float) as IssueCount
        FROM MedicationIssue i
            JOIN MedicationDictionary d
            on i.MultilexDrug_ID = d.MultilexDrug_ID
        WHERE 
            ISNUMERIC(d.dmd_id) = 0
            AND NOT EXISTS (
                SELECT 1 
                FROM OpenCoronaTempTables..CustomMedicationDictionary c 
                WHERE c.MultilexDrug_ID = d.MultilexDrug_ID
            )
            AND year(i.ConsultationDate)>=2018
        GROUP BY
            d.MultilexDrug_ID,
            d.dmd_id,
            d.FullName
    )

select
    MultilexDrug_ID,
    dmd_id,
    FullName,
    cast(CASE WHEN IssueCount=0 THEN 0 ELSE (CEILING(IssueCount/6)*6) - 3 END as int) as IssueCount_midpoint6
from cte
order by 1,2,3,4