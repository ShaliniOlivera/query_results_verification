WITH specialNeeds AS (
    SELECT
        ca.fk_child,
        sn.disease,
        sn.`exists`
    FROM child_attribute ca,
    JSON_TABLE(
        ca.value,
        '$.specialNeeds.medicalConditions[*]'
        COLUMNS (
            disease VARCHAR(50) PATH '$.disease',
            `exists` TINYINT PATH '$.exists'
        )
    ) AS sn
)

SELECT 
    ch.id,
             
    -- Physical Conditions
        -- Special Need
    MAX(CASE WHEN sn.disease = 'adhd' AND sn.`exists` = 1 THEN 'Yes' ELSE 'No' END) AS special_needs_adhd,
    MAX(CASE WHEN sn.disease = 'autism' AND sn.`exists` = 1 THEN 'Yes' ELSE 'No' END) AS special_needs_autism,
    MAX(CASE WHEN sn.disease = 'auditory issues' AND sn.`exists` = 1 THEN 'Yes' ELSE 'No' END) AS special_needs_auditory_issues,
    MAX(CASE WHEN sn.disease = 'dyslexia' AND sn.`exists` = 1 THEN 'Yes' ELSE 'No' END) AS special_needs_dyslexia,
    MAX(CASE WHEN sn.disease = 'down_syndrome' AND sn.`exists` = 1 THEN 'Yes' ELSE 'No' END) AS special_needs_down_syndrome,
    MAX(CASE WHEN sn.disease = 'global_development_delay' AND sn.`exists` = 1 THEN 'Yes' ELSE 'No' END) AS special_needs_global_development_delay,
    MAX(CASE WHEN sn.disease = 'others' AND sn.`exists` = 1 THEN 'Yes' ELSE 'No' END) AS special_needs_others,

    -- Special Needs Remarks
    MAX(CASE WHEN JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.specialNeeds.medicalConditionRemarks')) NOT IN ('', 'null') 
             THEN JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.specialNeeds.medicalConditionRemarks')) 
             ELSE '' END) AS special_needs_remarks    
    

    
FROM child ch
LEFT JOIN child_attribute ca ON ca.fk_child = ch.id AND ca.fk_code = "2013"
LEFT JOIN specialNeeds sn ON sn.fk_child = ca.fk_child
WHERE ch.id IN (
    SELECT ch.id
    FROM child_level cl
    INNER JOIN child ch ON ch.id = cl.fk_child
    WHERE cl.active = 1
    AND ch.active = 1
    AND cl.fk_centre IN (1, 5, 10, 18, 16, 20)
    AND (cl.`to` >= CURRENT_DATE OR cl.`to` IS NULL)
    AND cl.from = (
        SELECT MAX(cl2.from)
        FROM child_level cl2
        WHERE cl2.fk_child = cl.fk_child
        AND cl2.active = 1
        AND (cl2.`to` >= CURRENT_DATE OR cl2.`to` IS NULL)
    )
)
GROUP BY ch.id, ca.value;
