-- Sha SOA
SELECT soa.id,
soa.fk_child AS child_id,
ce.code AS centre_code,
DATE_FORMAT(DATE_ADD(soa.`date`, INTERVAL 1 MONTH), '%Y-%m-%d') AS `document_date`,
soa.url AS document_storage_path,
soa.total_outstanding as total_outstanding_amount,
soa.created_at,
soa.updated_at

FROM `soa_monthly_pdf` soa
INNER JOIN `centre` ce ON ce.id = soa.fk_centre AND ce.id IN (1, 5, 10, 18, 16, 20)
WHERE soa.fk_child IN (
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
AND soa.created_at >= '2025-01-01 00:00:00';
