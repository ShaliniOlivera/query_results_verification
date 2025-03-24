WITH latest_child_level AS (
    SELECT cl.*
    FROM child_level cl
    WHERE cl.active = 1
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
      )
),
latest_child_class AS (
    SELECT ccla.*
    FROM child_class ccla
    WHERE ccla.active = 1
      AND ccla.from = (
          SELECT MAX(ccla2.from)
          FROM child_class ccla2
          WHERE ccla2.fk_child = ccla.fk_child
            AND ccla2.active = 1
            AND (
                ccla2.to > CURRENT_DATE
                OR (
                    ccla2.to IS NULL 
                    AND NOT EXISTS (
                        SELECT 1 FROM child_class ccla3 
                        WHERE ccla3.fk_child = ccla.fk_child 
                          AND ccla3.active = 1 
                          AND ccla3.to > CURRENT_DATE
                    )
                )
            )
      )
),
withdrawal_2025 AS (
    SELECT wd.fk_child, wd.effective_date
    FROM withdrawal wd
    WHERE wd.active = 1
      AND wd.effective_date >= current_date
),
transfer_2025 AS (
    SELECT 
    cl_all.id, 
    cl_all.`from`, 
    cl_all.`to`, 
    cl_all.move_reason, 
    tr.fk_child, 
    tr.fk_level, 
    tr.fk_program, 
    CASE 
        WHEN cl_all.move_reason = 8 THEN tr.effective_date 
        ELSE NULL 
    END AS effective_date,
    CASE 
        WHEN cl_all.move_reason = 8 THEN tr.destination_centre 
        ELSE NULL 
    END AS destination_centre
FROM `child_level` cl_all
LEFT JOIN `transfer` tr 
    ON tr.fk_child = cl_all.fk_child 
    AND tr.active = 1 
    AND tr.effective_date >= current_date
LEFT JOIN `transfer_draft_item` tdi 
    ON tdi.fk_transfer = tr.id
),

current_centre_enrolment AS (
    SELECT cl.fk_child,
           DATE_FORMAT(
               COALESCE(
                   (SELECT MIN(cl2.from)
                    FROM child_level cl2
                    WHERE cl2.fk_child = cl.fk_child
                      AND cl2.fk_centre = cl.fk_centre
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
                    WHERE cl4.fk_child = cl.fk_child
                      AND cl4.fk_centre = cl.fk_centre
                      AND cl4.active = 1
                      AND cl4.fk_centre IN (1, 5, 10, 18, 16, 20)
                   ),
                   '1900-01-01'
               ), '%Y-%m-%d'
           ) AS enrolment_date
    FROM latest_child_level cl
)
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
    lcl.from AS current_level_enrolment_date, 
    ce.code AS current_centre_code, 
    le.code AS current_level, 
    pr.code AS current_program, 
    lccl.from AS current_class_enrolment_date, 
    cla.id AS current_class_id, 
    cla.label AS current_class_name,
    cce.enrolment_date AS current_centre_enrolment_date,
    COALESCE(wd.effective_date, '') AS withdrawal_effective_date, 
    COALESCE(tr.effective_date, '') AS transfer_effective_date, 
    COALESCE(dest_ce.code, '') AS transfer_destination_centre_code,
    ch.created_at, 
    ch.updated_at
FROM latest_child_level lcl
INNER JOIN child ch ON ch.id = lcl.fk_child
INNER JOIN centre ce ON ce.id = lcl.fk_centre
INNER JOIN level le ON le.id = lcl.fk_level
INNER JOIN program pr ON pr.id = lcl.fk_program
LEFT JOIN latest_child_class lccl ON lccl.fk_child = ch.id
LEFT JOIN class cla ON cla.id = lccl.fk_class
LEFT JOIN withdrawal_2025 wd ON wd.fk_child = lcl.fk_child
LEFT JOIN transfer_2025 tr ON tr.fk_child = lcl.fk_child
LEFT JOIN centre dest_ce ON dest_ce.id = tr.destination_centre
LEFT JOIN current_centre_enrolment cce ON cce.fk_child = ch.id