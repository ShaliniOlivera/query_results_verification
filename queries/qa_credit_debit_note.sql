-- Sha Credit Debit Note
WITH
amounts AS (
    SELECT fk_credit_debit_note, 
           ABS(IFNULL(SUM(adjusted_amount - amount), 0)) AS amount
    FROM credit_debit_note_item
    WHERE active = 1
    GROUP BY fk_credit_debit_note
)

SELECT 
    cdn.`id`,
    cdn.`fk_child` AS `child_id`,
    cnt.`code` AS `centre_code`,
    cdn.`credit_debit_note_no`,
    cdn.`credit_debit_note_date`,
    cdn.`note_type` AS `type`,
    IFNULL(amt.amount, 0) AS `amount`,
    IFNULL(cdn.`pdf_url_key`, '') AS `pdf_storage_path`,
    TRIM(CONCAT(IFNULL(usr_created.`firstname`, ''), ' ', IFNULL(usr_created.`lastname`, ''))) AS `created_by_staff_name`,
    TRIM(CONCAT(IFNULL(usr_updated.`firstname`, ''), ' ', IFNULL(usr_updated.`lastname`, ''))) AS `updated_by_staff_name`,
    IFNULL(cdn.`debt_writeoff_requester`, '') AS `debt_write_off_requester`,
    IFNULL(cdn.`debt_writeoff_approver`, '') AS `debt_write_off_approver`,
    IFNULL(cdn.`debt_writeoff_other_reason`, '') AS `debt_writeoff_other_reason`,
    IFNULL(cdn.`reason_code`, '') AS `reason`,
    IFNULL(cdn.`remarks`, '') AS `remarks`,
    cdn.`created_at`, cdn.`updated_at`
from credit_debit_note cdn
LEFT JOIN amounts amt ON amt.fk_credit_debit_note = cdn.id
INNER JOIN centre cnt ON cnt.id = cdn.fk_centre
LEFT JOIN `user` usr_created ON usr_created.id = cdn.generated_by_fk_staff
LEFT JOIN `user` usr_updated ON usr_updated.id = cdn.generated_by_fk_staff
WHERE cdn.credit_debit_note_date >= '2025-01-01 00:00:00'
AND cdn.active = 1
AND cdn.fk_child IN (
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


UNION

-- registration_child
SELECT 
    cdn.`id`,
    cdn.`fk_child` AS `child_id`,
    cnt.`code` AS `centre_code`,
    cdn.`credit_debit_note_no`,
    cdn.`credit_debit_note_date`,
    cdn.`note_type` AS `type`,
    IFNULL(amt.amount, 0) AS `amount`,
    IFNULL(cdn.`pdf_url_key`, '') AS `pdf_storage_path`,
    TRIM(CONCAT(IFNULL(usr_created.`firstname`, ''), ' ', IFNULL(usr_created.`lastname`, ''))) AS `created_by_staff_name`,
    TRIM(CONCAT(IFNULL(usr_updated.`firstname`, ''), ' ', IFNULL(usr_updated.`lastname`, ''))) AS `updated_by_staff_name`,
    IFNULL(cdn.`debt_writeoff_requester`, '') AS `debt_write_off_requester`,
    IFNULL(cdn.`debt_writeoff_approver`, '') AS `debt_write_off_approver`,
    IFNULL(cdn.`debt_writeoff_other_reason`, '') AS `debt_writeoff_other_reason`,
    IFNULL(cdn.`reason_code`, '') AS `reason`,
    IFNULL(cdn.`remarks`, '') AS `remarks`,
    cdn.`created_at`, cdn.`updated_at`
FROM credit_debit_note cdn
LEFT JOIN amounts amt ON amt.fk_credit_debit_note = cdn.id
INNER JOIN centre cnt ON cnt.id = cdn.fk_centre
LEFT JOIN `user` usr_created ON usr_created.id = cdn.generated_by_fk_staff
LEFT JOIN `user` usr_updated ON usr_updated.id = cdn.generated_by_fk_staff
WHERE cdn.credit_debit_note_date >= '2025-01-01 00:00:00'
AND cdn.active = 1
AND cdn.fk_child IN (
   SELECT ch.id
   FROM child_level cl
   INNER JOIN registration_child ch ON ch.id = cl.fk_child
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

UNION

-- ecda_registration_child
SELECT 
    cdn.`id`,
    cdn.`fk_child` AS `child_id`,
    cnt.`code` AS `centre_code`,
    cdn.`credit_debit_note_no`,
    cdn.`credit_debit_note_date`,
    cdn.`note_type` AS `type`,
    IFNULL(amt.amount, 0) AS `amount`,
    IFNULL(cdn.`pdf_url_key`, '') AS `pdf_storage_path`,
    TRIM(CONCAT(IFNULL(usr_created.`firstname`, ''), ' ', IFNULL(usr_created.`lastname`, ''))) AS `created_by_staff_name`,
    TRIM(CONCAT(IFNULL(usr_updated.`firstname`, ''), ' ', IFNULL(usr_updated.`lastname`, ''))) AS `updated_by_staff_name`,
    IFNULL(cdn.`debt_writeoff_requester`, '') AS `debt_write_off_requester`,
    IFNULL(cdn.`debt_writeoff_approver`, '') AS `debt_write_off_approver`,
    IFNULL(cdn.`debt_writeoff_other_reason`, '') AS `debt_writeoff_other_reason`,
    IFNULL(cdn.`reason_code`, '') AS `reason`,
    IFNULL(cdn.`remarks`, '') AS `remarks`,
    cdn.`created_at`, cdn.`updated_at`
FROM credit_debit_note cdn
LEFT JOIN amounts amt ON amt.fk_credit_debit_note = cdn.id
INNER JOIN centre cnt ON cnt.id = cdn.fk_centre
LEFT JOIN `user` usr_created ON usr_created.id = cdn.generated_by_fk_staff
LEFT JOIN `user` usr_updated ON usr_updated.id = cdn.generated_by_fk_staff
WHERE cdn.credit_debit_note_date >= '2025-01-01 00:00:00'
AND cdn.active = 1
AND cdn.fk_child IN (
   SELECT ch.id
   FROM child_level cl
   INNER JOIN ecda_registration_child ch ON ch.id = cl.fk_child
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

