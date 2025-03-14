-- sha receipts
WITH 
   collected_by AS (
   SELECT 
        re.id AS re_id, 
        us.lastname,
        us.firstname
    FROM receipt re
    INNER JOIN `user` us ON us.id = re.collected_by_fk_staff 
    where re.fk_centre IN (1, 5, 10, 18, 16, 20)
   ),
   
   cancelled_by AS (
   SELECT 
        re.id AS re_id, 
        us.lastname,
        us.firstname
    FROM receipt re
    INNER JOIN `user` us ON us.id = re.cancelled_by_fk_staff 
    WHERE re.fk_centre IN (1, 5, 10, 18, 16, 20)
   )
   
-- advanced payment
SELECT DISTINCT re.id AS id,
ch.id AS child_id,
ce.code AS centre_code,
re.receipt_no,
re.collected_date,
ifnull(ba.bill_reference_number,'') AS bank_account_no,
re.payment_type,
IF(re.`payment_type` IN ('giro_cda', 'nets_cda', 'offset_cda'), 'CDA', 'Non-CDA') AS `payment_mode`,
re.document_no,
IF(re.`amount` = 0 AND re.`amount_received` > 0, re.`amount_received`, re.`amount`) AS `total_receipt_amount`,
re.pdf_url_key AS pdf_storage_path,
ifnull(trim(concat(cob.firstname,' ',cob.lastname)),'') AS collected_by_staff_name,
ifnull(trim(concat(cab.firstname,' ',cab.lastname)),'') AS cancelled_by_staff_name,
ifnull(re.cancelled_date ,'') AS cancellation_date,
ifnull(re.cancelation_reason,'') AS cancellation_reason,
re.created_at,
re.updated_at

FROM child ch
INNER JOIN `receipt` re ON re.fk_child = ch.id AND re.active = 1
INNER JOIN `centre` ce ON ce.id = re.fk_centre AND ce.id IN (1, 5, 10, 18, 16, 20)
LEFT JOIN `bank_account` ba ON ba.id = fk_bank_account AND ba.active = 1
LEFT JOIN `collected_by` AS cob ON cob.re_id = re.id
LEFT JOIN `cancelled_by` AS cab ON cab.re_id = re.id
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
AND (re.created_at >= '2025-01-01 00:00:00' OR re.updated_at >= '2025-01-01 00:00:00' OR collected_date >= '2025-01-01 00:00:00' )
AND NOT EXISTS (SELECT 1 FROM `receipt_item` ri WHERE ri.`fk_receipt` = re.`id` AND ri.`active` = 1)
)

UNION
-- linked receipts
SELECT DISTINCT re.id AS id,
ch.id AS child_id,
ce.code AS centre_code,
re.receipt_no,
re.collected_date,
ifnull(ba.bill_reference_number,'') AS bank_account_no,
re.payment_type,
IF(re.`payment_type` IN ('giro_cda', 'nets_cda', 'offset_cda'), 'CDA', 'Non-CDA') AS `payment_mode`,
re.document_no,
IF(re.`amount` = 0 AND re.`amount_received` > 0, re.`amount_received`, re.`amount`) AS `total_receipt_amount`,
re.pdf_url_key AS pdf_storage_path,
ifnull(trim(concat(cob.firstname,' ',cob.lastname)),'') AS collected_by_staff_name,
ifnull(trim(concat(cab.firstname,' ',cab.lastname)),'') AS cancelled_by_staff_name,
ifnull(re.cancelled_date ,'') AS cancellation_date,
ifnull(re.cancelation_reason,'') AS cancellation_reason,
re.created_at,
re.updated_at

FROM child ch
INNER JOIN `receipt` re ON re.fk_child = ch.id AND re.active = 1
INNER JOIN `centre` ce ON ce.id = re.fk_centre AND ce.id IN (1, 5, 10, 18, 16, 20)
INNER JOIN `receipt_item` ri ON ri.fk_receipt = re.id AND ri.active = 1
INNER JOIN `invoice` inv ON inv.id = ri.fk_invoice AND  inv.invoice_date >= '2025-01-01 00:00:00' AND inv.status != "draft" AND inv.pdf_url_key IS NOT NULL
LEFT JOIN `bank_account` ba ON ba.id = fk_bank_account AND ba.active = 1
LEFT JOIN `collected_by` AS cob ON cob.re_id = re.id
LEFT JOIN `cancelled_by` AS cab ON cab.re_id = re.id
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
AND (re.created_at >= '2025-01-01 00:00:00' OR re.updated_at >= '2025-01-01 00:00:00' OR collected_date >= '2025-01-01 00:00:00' )
)

UNION

-- registration child receipts
SELECT DISTINCT re.id AS id,
ch.id AS child_id,
ce.code AS centre_code,
re.receipt_no,
re.collected_date,
ifnull(ba.bill_reference_number,'') AS bank_account_no,
re.payment_type,
IF(re.`payment_type` IN ('giro_cda', 'nets_cda', 'offset_cda'), 'CDA', 'Non-CDA') AS `payment_mode`,
re.document_no,
IF(re.`amount` = 0 AND re.`amount_received` > 0, re.`amount_received`, re.`amount`) AS `total_receipt_amount`,
re.pdf_url_key AS pdf_storage_path,
ifnull(trim(concat(cob.firstname,' ',cob.lastname)),'') AS collected_by_staff_name,
ifnull(trim(concat(cab.firstname,' ',cab.lastname)),'') AS cancelled_by_staff_name,
ifnull(re.cancelled_date ,'') AS cancellation_date,
ifnull(re.cancelation_reason,'') AS cancellation_reason,
re.created_at,
re.updated_at

FROM registration_child ch
INNER JOIN `receipt` re ON re.fk_child = ch.id AND re.active = 1
INNER JOIN `centre` ce ON ce.id = re.fk_centre AND ce.id IN (1, 5, 10, 18, 16, 20)
INNER JOIN `receipt_item` ri ON ri.fk_receipt = re.id AND ri.active = 1
INNER JOIN `invoice` inv ON inv.id = ri.fk_invoice AND  inv.invoice_date >= '2025-01-01 00:00:00' AND inv.status != "draft" AND inv.pdf_url_key IS NOT NULL
LEFT JOIN `bank_account` ba ON ba.id = fk_bank_account AND ba.active = 1
LEFT JOIN `collected_by` AS cob ON cob.re_id = re.id
LEFT JOIN `cancelled_by` AS cab ON cab.re_id = re.id
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
AND (re.created_at >= '2025-01-01 00:00:00' OR re.updated_at >= '2025-01-01 00:00:00' OR collected_date >= '2025-01-01 00:00:00' )
AND ch.active = 1
)

UNION

-- ecda registration child receipts
SELECT DISTINCT re.id AS id,
ch.id AS child_id,
ce.code AS centre_code,
re.receipt_no,
re.collected_date,
ifnull(ba.bill_reference_number,'') AS bank_account_no,
re.payment_type,
IF(re.`payment_type` IN ('giro_cda', 'nets_cda', 'offset_cda'), 'CDA', 'Non-CDA') AS `payment_mode`,
re.document_no,
IF(re.`amount` = 0 AND re.`amount_received` > 0, re.`amount_received`, re.`amount`) AS `total_receipt_amount`,
re.pdf_url_key AS pdf_storage_path,
ifnull(trim(concat(cob.firstname,' ',cob.lastname)),'') AS collected_by_staff_name,
ifnull(trim(concat(cab.firstname,' ',cab.lastname)),'') AS cancelled_by_staff_name,
ifnull(re.cancelled_date ,'') AS cancellation_date,
ifnull(re.cancelation_reason,'') AS cancellation_reason,
re.created_at,
re.updated_at

FROM ecda_registration_child ch
INNER JOIN `receipt` re ON re.fk_child = ch.id AND re.active = 1
INNER JOIN `centre` ce ON ce.id = re.fk_centre AND ce.id IN (1, 5, 10, 18, 16, 20)
INNER JOIN `receipt_item` ri ON ri.fk_receipt = re.id AND ri.active = 1
INNER JOIN `invoice` inv ON inv.id = ri.fk_invoice AND  inv.invoice_date >= '2025-01-01 00:00:00' AND inv.status != "draft" AND inv.pdf_url_key IS NOT null
LEFT JOIN `bank_account` ba ON ba.id = fk_bank_account AND ba.active = 1
LEFT JOIN `collected_by` AS cob ON cob.re_id = re.id
LEFT JOIN `cancelled_by` AS cab ON cab.re_id = re.id
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
AND (re.created_at >= '2025-01-01 00:00:00' OR re.updated_at >= '2025-01-01 00:00:00' OR collected_date >= '2025-01-01 00:00:00' )
AND ch.active = 1
)
;
