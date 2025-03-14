-- sha refund
WITH
created_by AS (
SELECT rcb.id, us.firstname, us.lastname 
FROM `user` us
INNER JOIN `refund_child_balance` rcb ON rcb.requested_by_fk_staff = us.id
)

-- enrolled
SELECT rcb.id, 
ch.id AS child_id,
ce.code AS centre_code,
rcb.refund_no,
rcb.requested_at AS requested_date,
rcb.refund_at AS refund_completed_date,
rcb.refund_mode AS refund_mode,
IF(rcb.`refund_mode` IN ('giro_cda', 'nets_cda', 'offset_cda'), 'CDA', 'Non-CDA') AS `refund_type`,
rcb.amount,
ifnull(trim(concat(cb.firstname,' ', cb.lastname)),'') AS created_by_staff_name,
ifnull(rcb.remark,'') AS remarks,
rcb.created_at,
rcb.updated_at
FROM child ch
INNER JOIN `refund_child_balance` rcb ON rcb.fk_child = ch.id AND (rcb.`created_at` >= '2025-01-01 00:00:00' OR rcb.`updated_at` >= '2025-01-01 00:00:00' OR rcb.`refund_at` >= '2025-01-01 00:00:00' OR rcb.`requested_at` >= '2025-01-01 00:00:00') AND rcb.status = "completed"
INNER JOIN `centre` ce ON ce.id = rcb.fk_centre AND ce.id IN (1, 5, 10, 18, 16, 20)
LEFT JOIN created_by cb ON cb.id = rcb.id
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

UNION

-- registration_child
SELECT rcb.id, 
ch.id AS child_id,
ce.code AS centre_code,
rcb.refund_no,
rcb.requested_at AS requested_date,
rcb.refund_at AS refund_completed_date,
rcb.refund_mode AS refund_mode,
IF(rcb.`refund_mode` IN ('giro_cda', 'nets_cda', 'offset_cda'), 'CDA', 'Non-CDA') AS `refund_type`,
rcb.amount,
ifnull(trim(concat(cb.firstname,' ', cb.lastname)),'') AS created_by_staff_name,
ifnull(rcb.remark,'') AS remarks,
rcb.created_at,
rcb.updated_at
FROM `registration_child` ch
INNER JOIN `refund_child_balance` rcb ON rcb.fk_child = ch.id AND (rcb.`created_at` >= '2025-01-01 00:00:00' OR rcb.`updated_at` >= '2025-01-01 00:00:00' OR rcb.`refund_at` >= '2025-01-01 00:00:00' OR rcb.`requested_at` >= '2025-01-01 00:00:00') AND rcb.status = "completed"
INNER JOIN `centre` ce ON ce.id = rcb.fk_centre AND ce.id IN (1, 5, 10, 18, 16, 20)
LEFT JOIN created_by cb ON cb.id = rcb.id
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

UNION 
-- ecda registration_child
SELECT rcb.id, 
ch.id AS child_id,
ce.code AS centre_code,
rcb.refund_no,
rcb.requested_at AS requested_date,
rcb.refund_at AS refund_completed_date,
rcb.refund_mode AS refund_mode,
IF(rcb.`refund_mode` IN ('giro_cda', 'nets_cda', 'offset_cda'), 'CDA', 'Non-CDA') AS `refund_type`,
rcb.amount,
ifnull(trim(concat(cb.firstname,' ', cb.lastname)),'') AS created_by_staff_name,
ifnull(rcb.remark,'') AS remarks,
rcb.created_at,
rcb.updated_at
FROM `registration_child` ch
INNER JOIN `refund_child_balance` rcb ON rcb.fk_child = ch.id AND (rcb.`created_at` >= '2025-01-01 00:00:00' OR rcb.`updated_at` >= '2025-01-01 00:00:00' OR rcb.`refund_at` >= '2025-01-01 00:00:00' OR rcb.`requested_at` >= '2025-01-01 00:00:00') AND rcb.status = "completed"
INNER JOIN `centre` ce ON ce.id = rcb.fk_centre AND ce.id IN (1, 5, 10, 18, 16, 20)
LEFT JOIN created_by cb ON cb.id = rcb.id
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



