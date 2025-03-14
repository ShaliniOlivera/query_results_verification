-- Child details
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
    cla.label AS current_class_name,
    
DATE_FORMAT(
    COALESCE(
        (SELECT MIN(cl2.from)
         FROM child_level cl2
         WHERE cl2.fk_child = ch.id
         AND cl2.fk_centre = ce.id
         AND cl2.active = 1
         AND cl2.fk_centre IN (1, 5, 10, 18, 16, 20)
         AND cl2.from > (
            SELECT MAX(cl3.from)
            FROM child_level cl3
            WHERE cl3.fk_child = cl2.fk_child
            AND cl3.fk_centre = cl2.fk_centre
            AND cl3.active = 1
            AND cl3.move_reason IN (4, 64)
         )
        ),
        (SELECT MIN(cl4.from)
         FROM child_level cl4
         WHERE cl4.fk_child = ch.id
         AND cl4.fk_centre = ce.id
         AND cl4.active = 1
         AND cl4.fk_centre IN (1, 5, 10, 18, 16, 20)
        ),
        '1900-01-01'
    ), '%Y-%m-%d'
) AS current_centre_enrolment_date,



    
    -- Withdrawal details (only for 2025)
    COALESCE(wd.effective_date, '') AS withdrawal_effective_date, 

    -- Transfer details (only for 2025)
    COALESCE(tr.effective_date, '') AS transfer_effective_date, 
    COALESCE(dest_ce.code, '') AS transfer_destination_centre_code,
    ch.created_at AS created_at, 
    ch.updated_at AS updated_at

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


LEFT JOIN withdrawal wd
    ON wd.fk_child = cl.fk_child
    AND wd.fk_centre = cl.fk_centre
    AND wd.active = 1
    AND YEAR(wd.effective_date) = 2025


LEFT JOIN transfer tr
    ON tr.fk_child = cl.fk_child
    AND tr.fk_level = cl.fk_level
    AND tr.fk_program = cl.fk_program
    AND tr.active = 1
    AND YEAR(tr.effective_date) = 2025


LEFT JOIN `centre` dest_ce
    ON dest_ce.id = tr.destination_centre

WHERE cl.active = 1
AND ch.active = 1
AND cl.fk_centre IN (1, 5, 10, 18, 16, 20)
AND cl.from = (
    SELECT MAX(cl2.from)
    FROM child_level cl2
    WHERE cl2.fk_child = cl.fk_child
    AND cl2.active = 1
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
