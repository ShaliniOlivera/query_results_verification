SELECT 
	DISTINCT
	-- ch.id, ch.firstname as `child_firstname`, ch.lastname as `child_lastname`, ch.`birth_certificate` AS `child_birth_certificate`, 
    ch.id AS `id`, 
    ch.`fullname` AS `child_name`, 
    ch.`birth_certificate` AS `child_birth_certificate`, 
    cnt.`code` AS `centre_code`,
    ba_cda.`id` AS `cda_id`, 
    IF(ba_cda.`is_cda` = 1, 'Yes', 'No') AS `is_cda_account`,
    ba_cda_bank_bic_code.`bic_code` AS `giro_account_bank_bic_code`,
    ba_cda.`bill_reference_number` AS `giro_account_reference_number`,
    ba_cda.`payer_account_name` AS `giro_account_payer_account_name`,
    ba_cda.`payer_account_number` AS `giro_account_payer_account_number`,
    IFNULL(ba_cda.`effective_from`, '') AS `giro_account_effective_from`, IFNULL(ba_cda.`effective_to`, '') AS `giro_account_effective_to`,
    IFNULL(ba_cda.`child_name`, '') AS `cda_child_name`,
    IFNULL(ba_cda.`child_birth_certificate`, '') AS `cda_child_birth_certificate`,
    IF(ba_cda.`is_sibling_cda` = 1, 'Yes', 'No') AS `giro_account_is_sibling_cda`,
    IFNULL(ba_cda.`sibling_name`, '') AS `cda_sibling_name`,
    IFNULL(ba_cda.`sibling_birth_certificate`, '') AS `cda_sibling_birth_certificate`,
    IFNULL((SELECT IF(fba.`ba_application_date` NOT IN ('', 'null'), DATE_FORMAT(fba.`ba_application_date`, '%Y-%m-%d %H:%i:%s'), '') AS `formatted_application_date` FROM (SELECT JSON_UNQUOTE(JSON_EXTRACT(baa.`value`, '$.ApplicationDate')) AS `ba_application_date` FROM `bank_account_attribute` baa WHERE baa.`fk_bank_account` = ba_cda.`id` AND baa.`active` = 1 ORDER BY baa.`created_at` DESC LIMIT 1) fba), '') AS `giro_account_application_date`,
    ba_cda.`source` AS `giro_account_source`
	, ba_cda.`status` AS `giro_account_status`
    , ba_cda.`updated_at` AS `giro_account_last_updated_at`
FROM (
SELECT active_child.`fk_child`, active_child.`earliest_from`, bba.`is_cda`, 
	MAX(bba.`created_at`) AS `giro_account_latest_created_at`
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
	INNER JOIN  `bank_account` bba ON bba.`fk_child` = active_child.`fk_child` AND bba.`active` = 1
		AND bba.`status` = 'approved'
GROUP BY active_child.`fk_child`, active_child.`earliest_from`, bba.`is_cda`
) active_child
	INNER JOIN child ch ON ch.id = active_child.`fk_child`
		AND ch.`active` = 1
	INNER JOIN `bank_account` ba_cda ON ba_cda.`fk_child` = ch.`id` AND ba_cda.`is_cda` = active_child.`is_cda` AND ba_cda.`created_at` = active_child.`giro_account_latest_created_at` AND ba_cda.`active` = 1
    LEFT OUTER JOIN `child_level` cl ON cl.`fk_child` = ch.`id` AND cl.`from` = active_child.`earliest_from` AND cl.`active` = 1
    LEFT OUTER JOIN `centre` cnt ON cnt.`id` = cl.`fk_centre` AND cl.`active` = 1
    LEFT OUTER JOIN `bank_bic_code` ba_cda_bank_bic_code ON ba_cda_bank_bic_code.`id` = ba_cda.`fk_bank_bic_code` AND ba_cda_bank_bic_code.`active` = 1
WHERE
 	ba_cda.`status` IN ('approved');