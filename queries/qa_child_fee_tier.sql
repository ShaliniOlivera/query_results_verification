-- Sha's Child fee tier
SELECT DISTINCT 
    ch.id, 
    ch.firstname AS child_firstname, 
    ch.lastname AS child_lastname,
    ch.birth_certificate AS child_birth_certificate,
    ch.nationality,
    fg.group_code AS fee_group,
    ft.label AS fee_tier,
    ft.id AS fee_tier_id,
    cft.`from` AS effective_from,
    COALESCE(cft.`to`, '') AS effective_to,
    ce.code AS centre_code,
    cl_centre.level_code,
    cl_centre.program_code
FROM `child` ch
INNER JOIN `child_fee_tier` cft 
    ON cft.fk_child = ch.id 
    AND cft.active = 1 
    AND (cft.`to` IS NULL OR cft.`to` > CURRENT_TIMESTAMP)
INNER JOIN `fee_tier` ft 
    ON ft.id = cft.fk_fee_tier 
    AND ft.fk_centre IN (1, 5, 10, 18, 16, 20) 
    AND ft.active = 1
INNER JOIN `fee_group` fg 
    ON ft.fk_group = fg.id 
    AND fg.active = 1
INNER JOIN `centre` ce 
    ON ce.id = ft.fk_centre 
    AND ce.id IN (1, 5, 10, 18, 16, 20)
LEFT JOIN (
    SELECT cl.fk_child, 
           cl.fk_centre, 
           c.code, 
           le.code AS level_code, 
           pr.code AS program_code
    FROM child_level cl
    INNER JOIN centre c ON c.id = cl.fk_centre
    INNER JOIN `level` le ON le.id = cl.fk_level
    INNER JOIN `program` pr ON pr.id = cl.fk_program
    WHERE cl.active = 1
    AND cl.fk_centre IN (1, 5, 10, 18, 16, 20)
    AND pr.active = 1
    AND le.active = 1
    AND (
        (cl.to IS NULL AND NOT EXISTS (
            SELECT 1 FROM child_level cl2 
            WHERE cl2.fk_child = cl.fk_child 
            AND cl2.fk_centre = cl.fk_centre
            AND cl2.to > CURRENT_DATE
            AND cl2.active = 1
        ))
        OR cl.to > CURRENT_DATE
    )
    AND cl.from = (
        SELECT MAX(cl2.from)
        FROM child_level cl2
        WHERE cl2.fk_child = cl.fk_child
        AND cl2.active = 1
        AND cl2.fk_centre IN (1, 5, 10, 18, 16, 20)
        AND (
            (cl2.to IS NULL AND NOT EXISTS (
                SELECT 1 FROM child_level cl3 
                WHERE cl3.fk_child = cl2.fk_child 
                AND cl3.fk_centre = cl2.fk_centre
                AND cl3.to > CURRENT_DATE
                AND cl3.active = 1
            ))
            OR cl2.to > CURRENT_DATE
        )
    )
) AS cl_centre ON cl_centre.fk_child = ch.id  -- << Moved alias here
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
);
