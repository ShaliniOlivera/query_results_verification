
WITH 
created_by_staff AS (
    SELECT 
        inv.id AS id, 
        us.lastname,
        us.firstname
    FROM invoice inv
    INNER JOIN `user` us ON us.id = inv.created_by_fk_staff
    WHERE (inv.invoice_date >= '2025-01-01 00:00:00' 
        )
    AND inv.fk_centre IN (1, 5, 10, 18, 16, 20)
),

 updated_by_staff AS (
    SELECT 
        inv.id AS id, 
        us.lastname
    FROM invoice inv
    INNER JOIN `user` us ON us.id = inv.created_by_fk_staff
    WHERE (inv.invoice_date >= '2025-01-01 00:00:00' 
        )
    AND inv.fk_centre IN (1, 5, 10, 18, 16, 20)
)

SELECT DISTINCT un.invoice_id AS id, un.child_id, un.centre_code, un.invoice_no, un.invoice_date, un.invoice_label, un.type,un.status,un.invoice_due_date,un.total_payable_amount,
un.pdf_storage_path as invoice_pdf_storage_path, un.created_by AS created_by_staff_name, un.updated_by AS updated_by_staff_name
FROM(
-- enrolled children
SELECT  
    inv.id AS invoice_id,
    ch.id AS child_id,
    ce.code AS centre_code,
    inv.invoice_no AS invoice_no,
    inv.invoice_date,
    inv.label AS invoice_label,
    inv.invoice_type AS `type`,
    inv.status,
    inv.invoice_due_date,
    (inv.total_amount+inv.total_tax_amount) AS total_payable_amount,
    inv.pdf_url_key AS pdf_storage_path,
    ifnull(cbs.lastname,'') AS created_by,
    ifnull(ubs.lastname,'') AS updated_by
FROM child ch
INNER JOIN invoice inv ON inv.fk_child = ch.id AND inv.active = 1
INNER JOIN centre ce ON ce.id = inv.fk_centre AND ce.id IN (1, 5, 10, 18, 16, 20)
LEFT JOIN created_by_staff cbs ON cbs.id = inv.id
LEFT JOIN `updated_by_staff` ubs ON ubs.id = inv.id
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
AND (inv.invoice_date  >= '2025-01-01 00:00:00' 
)
AND inv.status != "draft" AND inv.pdf_url_key IS NOT NULL
)

UNION ALL
-- registration children
SELECT DISTINCT 
    inv.id AS invoice_id,
    ch.id AS child_id,
    ce.code AS centre_code,
    inv.invoice_no AS invoice_no,
    inv.invoice_date,
    inv.label AS invoice_label,
    inv.invoice_type AS `type`,
    inv.status,
    inv.invoice_due_date,
    (inv.total_amount+inv.total_tax_amount) AS total_payable_amount,
    inv.pdf_url_key AS pdf_storage_path,
    ifnull(cbs.lastname,'') AS created_by,
    ifnull(ubs.lastname,'') AS updated_by
FROM registration_child ch
INNER JOIN invoice inv ON inv.fk_child = ch.id AND inv.active = 1
INNER JOIN centre ce ON ce.id = inv.fk_centre AND ce.id IN (1, 5, 10, 18, 16, 20)
LEFT JOIN created_by_staff cbs ON cbs.id = inv.id
LEFT JOIN `updated_by_staff` ubs ON ubs.id = inv.id
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
AND (inv.invoice_date  >= '2025-01-01 00:00:00' 
)
AND inv.status != "draft" AND inv.pdf_url_key IS NOT NULL
)

UNION ALL

-- ecda registration_children
SELECT DISTINCT 
    inv.id AS invoice_id,
    ch.id AS child_id,
    ce.code AS centre_code,
    inv.invoice_no AS invoice_no,
    inv.invoice_date,
    inv.label AS invoice_label,
    inv.invoice_type AS `type`,
    inv.status,
    inv.invoice_due_date,
    (inv.total_amount+inv.total_tax_amount) AS total_payable_amount,
    inv.pdf_url_key AS pdf_storage_path,
    ifnull(cbs.lastname,'') AS created_by,
    ifnull(ubs.lastname,'') AS updated_by
FROM ecda_registration_child ch
INNER JOIN invoice inv ON inv.fk_child = ch.id AND inv.active = 1
INNER JOIN centre ce ON ce.id = inv.fk_centre AND ce.id IN (1, 5, 10, 18, 16, 20)
LEFT JOIN created_by_staff cbs ON cbs.id = inv.id
LEFT JOIN `updated_by_staff` ubs ON ubs.id = inv.id
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
AND (inv.invoice_date  >= '2025-01-01 00:00:00' 
)
AND inv.status != "draft" AND inv.pdf_url_key IS NOT NULL
)) AS un;



