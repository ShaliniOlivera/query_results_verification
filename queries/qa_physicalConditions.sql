WITH PhysicalConditionDetails AS (
    SELECT
        ca.fk_child,
        jt.disease,
        jt.`exists`
    FROM child_attribute ca,
    JSON_TABLE(
        ca.value,
        '$.physicalConditions.medicalConditions[*]'
        COLUMNS (
            disease VARCHAR(50) PATH '$.disease',
            `exists` TINYINT PATH '$.exists'
        )
    ) AS jt
)

SELECT 
    ch.id,
             
    -- Physical Conditions
    MAX(CASE WHEN pc.disease = 'fits' AND pc.`exists` = 1 THEN 'Yes' ELSE 'No' END) AS `physical_condition_fits`,
    MAX(CASE WHEN pc.disease = 'asthma' AND pc.`exists` = 1 THEN 'Yes' ELSE 'No' END) AS `physical_condition_asthma`,
    MAX(CASE WHEN pc.disease = 'diabetes' AND pc.`exists` = 1 THEN 'Yes' ELSE 'No' END) AS `physical_condition_diabetes`,
    MAX(CASE WHEN pc.disease = 'hepatitis_b' AND pc.`exists` = 1 THEN 'Yes' ELSE 'No' END) AS `physical_condition_hepatitis_b`,
    MAX(CASE WHEN pc.disease = 'hepatitis_a' AND pc.`exists` = 1 THEN 'Yes' ELSE 'No' END) AS `physical_condition_hepatitis_a`,
    MAX(CASE WHEN pc.disease = 'others' AND pc.`exists` = 1 THEN 'Yes' ELSE 'No' END) AS `physical_condition_others`,

    -- Physical Condition Remarks
    MAX(CASE WHEN JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.physicalConditions.medicalConditionRemarks')) NOT IN ('', 'null') 
             THEN JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.physicalConditions.medicalConditionRemarks')) 
             ELSE '' END) AS `physical_condition_remarks`
    
    

    
FROM child ch
LEFT JOIN child_attribute ca ON ca.fk_child = ch.id AND ca.fk_code = "2013"
LEFT JOIN PhysicalConditionDetails pc ON pc.fk_child = ca.fk_child
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
