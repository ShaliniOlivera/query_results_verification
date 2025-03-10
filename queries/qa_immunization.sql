WITH Immunization AS (
    SELECT
        ca.fk_child,
        it.disease,
        it.is_exists
    FROM child_attribute ca,
    JSON_TABLE(
        ca.value,
        '$.immunizations.immunizationDetails[*]'
        COLUMNS (
            disease VARCHAR(50) PATH '$.disease',
            is_exists BOOLEAN PATH '$.exists'
        )
    ) AS it
)

SELECT 
    ch.id,
             
    -- Immunization Status
    CASE 
        WHEN JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.immunizations.isImmunized')) = 'true' THEN 'Yes'
        ELSE 'No'
    END AS is_immunized,

    -- Immunization Disease
    COALESCE(MAX(CASE WHEN i.disease = 'bcg' AND i.is_exists = 1 THEN 'Yes' ELSE 'No' END), 'No') AS bcg,
    COALESCE(MAX(CASE WHEN i.disease = 'hep_b' AND i.is_exists = 1 THEN 'Yes' ELSE 'No' END), 'No') AS hep_b,
    COALESCE(MAX(CASE WHEN i.disease = 'ipv' AND i.is_exists = 1 THEN 'Yes' ELSE 'No' END), 'No') AS ipv,
    COALESCE(MAX(CASE WHEN i.disease = 'hib' AND i.is_exists = 1 THEN 'Yes' ELSE 'No' END), 'No') AS hib,
    COALESCE(MAX(CASE WHEN i.disease = 'pcv10' AND i.is_exists = 1 THEN 'Yes' ELSE 'No' END), 'No') AS pcv10,
    COALESCE(MAX(CASE WHEN i.disease = 'var' AND i.is_exists = 1 THEN 'Yes' ELSE 'No' END), 'No') AS var,
    COALESCE(MAX(CASE WHEN i.disease = 'inf' AND i.is_exists = 1 THEN 'Yes' ELSE 'No' END), 'No') AS inf,
    COALESCE(MAX(CASE WHEN i.disease = 'dtap_1d' AND i.is_exists = 1 THEN 'Yes' ELSE 'No' END), 'No') AS dtap_1d,
    COALESCE(MAX(CASE WHEN i.disease = 'dtap_2d' AND i.is_exists = 1 THEN 'Yes' ELSE 'No' END), 'No') AS dtap_2d,
    COALESCE(MAX(CASE WHEN i.disease = 'dtap_3d' AND i.is_exists = 1 THEN 'Yes' ELSE 'No' END), 'No') AS dtap_3d, 
    COALESCE(MAX(CASE WHEN i.disease = 'dtap_18m' AND i.is_exists = 1 THEN 'Yes' ELSE 'No' END), 'No') AS dtap_18m, 
    COALESCE(MAX(CASE WHEN i.disease = 'mmr_1d' AND i.is_exists = 1 THEN 'Yes' ELSE 'No' END), 'No') AS mmr_1d, 
    COALESCE(MAX(CASE WHEN i.disease = 'mmr_2d' AND i.is_exists = 1 THEN 'Yes' ELSE 'No' END), 'No') AS mmr_2d
    
    

    
FROM child ch
LEFT JOIN child_attribute ca ON ca.fk_child = ch.id AND ca.fk_code = "2013"
LEFT JOIN Immunization i ON i.fk_child = ch.id
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
