WITH FoodAllergies AS (
    SELECT
        ca.fk_child,
        fa.disease,
        fa.`exists`
    FROM child_attribute ca,
    JSON_TABLE(
        ca.value,
        '$.foodAllergies.medicalConditions[*]'
        COLUMNS (
            disease VARCHAR(50) PATH '$.disease',
            `exists` TINYINT PATH '$.exists'
        )
    ) AS fa
)

SELECT 
    ch.id,
             
        -- Food Allergies
    MAX(CASE WHEN fa.disease = 'dairy' AND fa.`exists` = 1 THEN 'Yes' ELSE 'No' END) AS food_allergies_dairy,
    MAX(CASE WHEN fa.disease = 'nuts' AND fa.`exists` = 1 THEN 'Yes' ELSE 'No' END) AS food_allergies_nuts,
    MAX(CASE WHEN fa.disease = 'eggs' AND fa.`exists` = 1 THEN 'Yes' ELSE 'No' END) AS food_allergies_eggs,
    MAX(CASE WHEN fa.disease = 'mushrooms' AND fa.`exists` = 1 THEN 'Yes' ELSE 'No' END) AS food_allergies_mushrooms,
    MAX(CASE WHEN fa.disease = 'gluten' AND fa.`exists` = 1 THEN 'Yes' ELSE 'No' END) AS food_allergies_gluten,
    MAX(CASE WHEN fa.disease = 'fish' AND fa.`exists` = 1 THEN 'Yes' ELSE 'No' END) AS food_allergies_fish,
    MAX(CASE WHEN fa.disease = 'others' AND fa.`exists` = 1 THEN 'Yes' ELSE 'No' END) AS food_allergies_others,

    -- Food Allergies Remarks
    MAX(CASE WHEN JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.foodAllergies.medicalConditionRemarks')) NOT IN ('', 'null') 
             THEN JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.foodAllergies.medicalConditionRemarks')) 
             ELSE '' END) AS food_allergies_remarks   
    

    
FROM child ch
LEFT JOIN child_attribute ca ON ca.fk_child = ch.id AND ca.fk_code = "2013"
LEFT JOIN FoodAllergies fa ON fa.fk_child = ca.fk_child
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
