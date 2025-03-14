-- kai refund
SELECT 
	rcb.`id`,
    rcb.`fk_child` AS `child_id`,
    cnt.`code` AS `centre_code`,
    rcb.`refund_no`,
    rcb.`requested_at` AS `requested_date`,
    rcb.`refund_at` AS `refund_completed_date`,
    rcb.`refund_mode` AS `refund_mode`,
    IF(rcb.`refund_mode` IN ('giro_cda', 'nets_cda', 'offset_cda'), 'CDA', 'Non-CDA') AS `refund_type`,
    rcb.`amount`,
    IFNULL(TRIM(CONCAT(IFNULL(usr_created.`firstname`, ''), ' ' , usr_created.`lastname`)), '') AS `created_by_staff_name`,
    IFNULL(rcb.`remark`, '') AS `remarks`,
    rcb.`created_at`, rcb.`updated_at`
FROM (
SELECT cl.fk_child, min(cl.`from`) AS earliest_from
FROM child_level cl
WHERE
	cl.fk_centre IN (1, 5, 10, 18, 16, 20)
    AND
	(cl.`to` IS NULL OR cl.`to` >= CURRENT_TIMESTAMP)
    AND
	cl.`active` = 1
GROUP BY cl.fk_child
) active_child
	INNER JOIN refund_child_balance rcb ON rcb.`fk_child` = active_child.`fk_child`
    INNER JOIN centre cnt ON cnt.`id` = rcb.`fk_centre` AND cnt.`active` = 1
    LEFT OUTER JOIN `user` usr_created ON usr_created.`id` = rcb.`requested_by_fk_staff`
WHERE
	rcb.`status` = 'completed'
    AND (rcb.`created_at` >= '2025-01-01 00:00:00' OR rcb.`updated_at` >= '2025-01-01 00:00:00' OR rcb.`refund_at` >= '2025-01-01 00:00:00' OR rcb.`requested_at` >= '2025-01-01 00:00:00')

UNION

-- refund for registration_child
SELECT 
	rcb.`id`,
    active_child.`fk_child` AS `child_id`,
    cnt.`code` AS `centre_code`,
    rcb.`refund_no`,
    rcb.`requested_at` AS `requested_date`,
    rcb.`refund_at` AS `refund_completed_date`,
    rcb.`refund_mode` AS `refund_mode`,
    IF(rcb.`refund_mode` IN ('giro_cda', 'nets_cda', 'offset_cda'), 'CDA', 'Non-CDA') AS `refund_type`,
    rcb.`amount`,
    IFNULL(TRIM(CONCAT(IFNULL(usr_created.`firstname`, ''), ' ' , usr_created.`lastname`)), '') AS `created_by_staff_name`,
    IFNULL(rcb.`remark`, '') AS `remarks`,
    rcb.`created_at`, rcb.`updated_at`
FROM (
SELECT cl.fk_child, min(cl.`from`) AS earliest_from
FROM child_level cl
WHERE
	cl.fk_centre IN (1, 5, 10, 18, 16, 20)
    AND
	(cl.`to` IS NULL OR cl.`to` >= CURRENT_TIMESTAMP)
    AND
	cl.`active` = 1
GROUP BY cl.fk_child
) active_child
	INNER JOIN `registration_child` rc ON rc.`fk_child` = active_child.`fk_child`
	INNER JOIN refund_child_balance rcb ON rcb.`fk_registration_child` = rc.`id`
    INNER JOIN centre cnt ON cnt.`id` = rcb.`fk_centre` AND cnt.`active` = 1
    LEFT OUTER JOIN `user` usr_created ON usr_created.`id` = rcb.`requested_by_fk_staff`
WHERE
	rcb.`status` = 'completed'
    AND (rcb.`created_at` >= '2025-01-01 00:00:00' OR rcb.`updated_at` >= '2025-01-01 00:00:00' OR rcb.`refund_at` >= '2025-01-01 00:00:00' OR rcb.`requested_at` >= '2025-01-01 00:00:00')

UNION

-- Refund for ecda_registration_child
SELECT 
	rcb.`id`,
    active_child.`fk_child` AS `child_id`,
    cnt.`code` AS `centre_code`,
    rcb.`refund_no`,
    rcb.`requested_at` AS `requested_date`,
    rcb.`refund_at` AS `refund_completed_date`,
    rcb.`refund_mode` AS `refund_mode`,
    IF(rcb.`refund_mode` IN ('giro_cda', 'nets_cda', 'offset_cda'), 'CDA', 'Non-CDA') AS `refund_type`,
    rcb.`amount`,
    IFNULL(TRIM(CONCAT(IFNULL(usr_created.`firstname`, ''), ' ' , usr_created.`lastname`)), '') AS `created_by_staff_name`,
    IFNULL(rcb.`remark`, '') AS `remarks`,
    rcb.`created_at`, rcb.`updated_at`
FROM (
SELECT cl.fk_child, min(cl.`from`) AS earliest_from
FROM child_level cl
WHERE
	cl.fk_centre IN (1, 5, 10, 18, 16, 20)
    AND
	(cl.`to` IS NULL OR cl.`to` >= CURRENT_TIMESTAMP)
    AND
	cl.`active` = 1
GROUP BY cl.fk_child
) active_child
	INNER JOIN `ecda_registration_child` rc ON rc.`fk_child` = active_child.`fk_child`
	INNER JOIN refund_child_balance rcb ON rcb.`fk_ecda_registration_child` = rc.`id`
    INNER JOIN centre cnt ON cnt.`id` = rcb.`fk_centre` AND cnt.`active` = 1
    LEFT OUTER JOIN `user` usr_created ON usr_created.`id` = rcb.`requested_by_fk_staff`
WHERE
	rcb.`status` = 'completed'
    AND (rcb.`created_at` >= '2025-01-01 00:00:00' OR rcb.`updated_at` >= '2025-01-01 00:00:00' OR rcb.`refund_at` >= '2025-01-01 00:00:00' OR rcb.`requested_at` >= '2025-01-01 00:00:00')
;