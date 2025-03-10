WITH NonFoodAllergies AS (
    SELECT
        ca.fk_child,
        nfa.disease,
        nfa.`exists`
    FROM child_attribute ca,
    JSON_TABLE(
        ca.value,
        '$.nonFoodAllergies.medicalConditions[*]'
        COLUMNS (
            disease VARCHAR(50) PATH '$.disease',
            `exists` TINYINT PATH '$.exists'
        )
    ) AS nfa
)

SELECT 
    ch.id,
             
       -- Non-Food Allergies
    MAX(CASE WHEN nfa.disease = 'pollen' AND nfa.`exists` = 1 THEN 'Yes' ELSE 'No' END) AS non_food_allergies_pollen,
    MAX(CASE WHEN nfa.disease = 'others' AND nfa.`exists` = 1 THEN 'Yes' ELSE 'No' END) AS non_food_allergies_others,

    -- Non-Food Allergies Remarks
    MAX(CASE WHEN JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.nonFoodAllergies.medicalConditionRemarks')) NOT IN ('', 'null') 
             THEN JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.nonFoodAllergies.medicalConditionRemarks')) 
             ELSE '' END) AS non_food_allergies_remarks 
    

    
FROM child ch
LEFT JOIN child_attribute ca ON ca.fk_child = ch.id AND ca.fk_code = "2013"
LEFT JOIN NonFoodAllergies nfa ON nfa.fk_child = ca.fk_child
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
