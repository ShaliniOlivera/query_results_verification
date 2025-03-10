-- Child profile until classes with correct active child_level and child_class selection
SELECT 
    ch.id, 
    ch.firstname AS child_firstname, 
    ch.lastname AS child_lastname, 
    ch.birth_certificate AS child_birth_certificate, 
    ch.date_of_birth, 
    ch.gender, 
    ch.race, 
    ch.nationality, 
    ch.image_key AS profile_photo_storage_path, 
    cl.`from` AS current_level_enrolment_date, 
    ce.code AS current_centre_code, 
    le.code AS current_level, 
    pr.code AS current_program, 
    ccla.`from` AS current_class_enrolment_date, 
    cla.id AS current_class_id, 
    cla.label AS current_class_name
FROM child_level cl
INNER JOIN child ch 
    ON ch.id = cl.fk_child
INNER JOIN `centre` ce 
    ON ce.id = cl.fk_centre
INNER JOIN `level` le 
    ON le.id = cl.fk_level
INNER JOIN `program` pr 
    ON pr.id = cl.fk_program
LEFT JOIN `child_class` ccla 
    ON ccla.fk_child = ch.id
    AND ccla.active = 1
    AND ccla.from = (
        SELECT MAX(ccla2.from)
        FROM child_class ccla2
        WHERE ccla2.fk_child = ch.id
        AND ccla2.active = 1
        -- Prioritize records where ccla2.to > CURRENT_DATE
        AND (
            ccla2.to > CURRENT_DATE
            OR (
                ccla2.to IS NULL 
                AND NOT EXISTS (
                    SELECT 1 FROM child_class ccla3 
                    WHERE ccla3.fk_child = ch.id 
                    AND ccla3.active = 1 
                    AND ccla3.to > CURRENT_DATE
                )
            )
        )
    )
LEFT JOIN `class` cla 
    ON cla.id = ccla.fk_class
WHERE cl.active = 1
AND ch.active = 1
AND cl.fk_centre IN (1, 5, 10, 18, 16, 20)
AND cl.from = (
    SELECT MAX(cl2.from)
    FROM child_level cl2
    WHERE cl2.fk_child = cl.fk_child
    AND cl2.active = 1
    -- Prioritize records where cl2.to > CURRENT_DATE
    AND (
        cl2.to > CURRENT_DATE
        OR (
            cl2.to IS NULL 
            AND NOT EXISTS (
                SELECT 1 FROM child_level cl3 
                WHERE cl3.fk_child = cl.fk_child 
                AND cl3.active = 1 
                AND cl3.to > CURRENT_DATE
            )
        )
    )
);
