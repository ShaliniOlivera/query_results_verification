WITH LatestChildLevel AS (
    SELECT fk_child
    FROM (
        SELECT fk_child, `from`, 
               ROW_NUMBER() OVER (PARTITION BY fk_child ORDER BY `from` DESC) AS row_num
        FROM child_level 
        WHERE active = 1 
          AND fk_centre IN (1, 5, 10, 18, 16, 20)
          AND (`to` IS NULL OR `to` >= CURRENT_DATE)
    ) AS ranked
    WHERE row_num = 1
)

SELECT 
    ch.id AS id,

    -- applicant Parent details
    MAX(CASE WHEN cr1.type = 'applicant' THEN p1.id END) AS parent_one_id,
    MAX(CASE WHEN cr1.type = 'applicant' THEN co1.description END) AS parent_one_relation,
    MAX(CASE WHEN cr1.type = 'applicant' THEN p1.firstname END) AS parent_one_firstname,
    MAX(CASE WHEN cr1.type = 'applicant' THEN p1.lastname END) AS parent_one_lastname,
    MAX(CASE WHEN cr1.type = 'applicant' THEN p1.identification_no END) AS parent_one_nric,
    MAX(CASE WHEN cr1.type = 'applicant' THEN p1.email END) AS parent_one_email,
    MAX(CASE WHEN cr1.type = 'applicant' THEN p1.mobile_phone END) AS parent_one_mobile_number,
    MAX(CASE WHEN cr1.type = 'applicant' THEN p1.mobile_phone END) AS parent_one_home_phone,
    MAX(CASE WHEN cr1.type = 'applicant' THEN p1.birthdate END) AS parent_one_date_of_birth,
    MAX(CASE WHEN cr1.type = 'applicant' THEN p1.nationality END) AS parent_one_nationality,
    MAX(CASE WHEN cr1.type = 'applicant' THEN p1.race END) AS parent_one_race,
    MAX(CASE WHEN cr1.type = 'applicant' THEN p1.marital_status END) AS parent_one_marital_status,
    MAX(CASE WHEN cr1.type = 'applicant' THEN p1.highest_qualification END) AS parent_one_qualification,
    MAX(CASE WHEN cr1.type = 'applicant' THEN COALESCE(co_occup1.description, p1.occupational_title) END) AS parent_one_occupation,
    MAX(CASE WHEN cr1.type = 'applicant' THEN p1.working_status END) AS parent_one_working_status,
    MAX(CASE 
    WHEN cr1.type = 'applicant' AND (p1.workplace_staff IS NULL OR p1.workplace_staff = '') THEN ''
    ELSE code_mother_workplace_staff1.description 
END) AS parent_one_workplace_association,
    MAX(CASE WHEN cr1.type = 'applicant' THEN p1.permanent_residence_start_date END) AS parent_one_pr_commencement_date,

    -- Secondary Applicant details
    MAX(CASE WHEN cr2.type = 'second_applicant' THEN p2.id END) AS parent_two_id,
    MAX(CASE WHEN cr2.type = 'second_applicant' THEN co2.description END) AS parent_two_relation,
    MAX(CASE WHEN cr2.type = 'second_applicant' THEN p2.firstname END) AS parent_two_firstname,
    MAX(CASE WHEN cr2.type = 'second_applicant' THEN p2.lastname END) AS parent_two_lastname,
    MAX(CASE WHEN cr2.type = 'second_applicant' THEN p2.identification_no END) AS parent_two_nric,
    MAX(CASE WHEN cr2.type = 'second_applicant' THEN p2.email END) AS parent_two_email,
    MAX(CASE WHEN cr2.type = 'second_applicant' THEN p2.mobile_phone END) AS parent_two_mobile_number,
    MAX(CASE WHEN cr2.type = 'second_applicant' THEN p2.mobile_phone END) AS parent_two_home_phone,
    MAX(CASE WHEN cr2.type = 'second_applicant' THEN p2.birthdate END) AS parent_two_date_of_birth,  
    MAX(CASE WHEN cr2.type = 'second_applicant' THEN p2.nationality END) AS parent_two_nationality,
    MAX(CASE WHEN cr2.type = 'second_applicant' THEN p2.race END) AS parent_two_race,
    MAX(CASE WHEN cr2.type = 'second_applicant' THEN p2.marital_status END) AS parent_two_marital_status,
    MAX(CASE WHEN cr2.type = 'second_applicant' THEN p2.highest_qualification END) AS parent_two_qualification,
    MAX(CASE WHEN cr2.type = 'second_applicant' THEN COALESCE(co_occup2.description, p2.occupational_title) END) AS parent_two_occupation,  
    MAX(CASE WHEN cr2.type = 'second_applicant' THEN p2.working_status END) AS parent_two_working_status,
    MAX(CASE WHEN cr2.type = 'second_applicant' THEN p2.permanent_residence_start_date END) AS parent_two_pr_commencement_date,

    -- Address details
-- Address details
COALESCE(NULLIF(MAX(ad1.postcode), ''), 'None') AS address_postal_code,
COALESCE(NULLIF(MAX(ad1.city), ''), 'Singapore') AS address_city,
COALESCE(NULLIF(MAX(ad1.country), ''), 'Singapore') AS address_country,
COALESCE(MAX(ad1.address), 'None') AS address_line_1,
COALESCE(MAX(ad1.building), 'None') AS address_block,
COALESCE(MAX(ad1.floor), 'None') AS address_floor,
COALESCE(MAX(ad1.unit), 'None') AS address_unit_no




FROM child ch
LEFT JOIN child_relation cr1 ON ch.id = cr1.fk_child AND cr1.active = 1 AND cr1.type = 'applicant'
LEFT JOIN parent p1 ON cr1.fk_parent = p1.id AND p1.active = 1
LEFT JOIN code co1 ON cr1.fk_relation = co1.id AND co1.fk_school = 2 AND co1.active = 1
LEFT JOIN code co_occup1 ON co_occup1.label = p1.occupational_title AND co_occup1.fk_school = 2
LEFT JOIN code code_mother_workplace_staff1 ON code_mother_workplace_staff1.label = p1.workplace_staff
    AND code_mother_workplace_staff1.fk_school = 2
    AND code_mother_workplace_staff1.fk_code = '3510'
LEFT JOIN child_relation cr2 ON ch.id = cr2.fk_child AND cr2.active = 1 AND cr2.type = 'second_applicant'
LEFT JOIN parent p2 ON cr2.fk_parent = p2.id AND p2.active = 1
LEFT JOIN code co2 ON cr2.fk_relation = co2.id AND co2.fk_school = 2 AND co2.active = 1
LEFT JOIN code co_occup2 ON co_occup2.label = p2.occupational_title AND co_occup2.fk_school = 2
LEFT JOIN address ad1 ON ad1.fk_parent = p1.id
-- LEFT JOIN address ad2 ON ad2.fk_parent = p2.id
WHERE ch.id IN (SELECT fk_child FROM LatestChildLevel)
-- AND ch.id IN (13078)
GROUP BY ch.id;
