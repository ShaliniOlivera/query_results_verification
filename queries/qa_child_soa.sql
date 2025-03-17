-- Sha Child SOA Details
WITH

child_active AS (
SELECT ch.id, cl.fk_centre
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


SELECT fd.id,
ch.id AS child_id,
ce.code AS centre_code,
fd.uploaded_at AS document_date,
IF(fd.`url` LIKE '/%', SUBSTRING(fd.`url`, 2), fd.`url`) AS storage_path

FROM `finance_document` fd
INNER JOIN `child_active` ch ON ch.id = JSON_UNQUOTE(JSON_EXTRACT(fd.report_request_dto, '$.childID'))
INNER JOIN `centre` ce ON ce.id = ch.fk_centre AND ce.id = JSON_UNQUOTE(JSON_EXTRACT(fd.report_request_dto, '$.centreID'))
WHERE fd.status = "successful"
AND fd.active = 1
AND fd.`uploaded_at` >= '2025-01-01 00:00:00'
AND JSON_UNQUOTE(JSON_EXTRACT(fd.report_request_dto, '$.centreID')) IN (1, 5, 10, 18, 16, 20)
ORDER BY ch.id ASC
-- AND soa.created_at >= "2025-01-01 00:00:00"