-- Kai's Child Deposit Data Export
SELECT 
	unique_deposit_invoice_per_child.`id`,
    cnt.`code` AS `centre_code`,
    iv.`invoice_no` AS `invoice_no`,
    -- iv.sn1_uid_invoice_key,
    ii.`total_amount` AS `total_deposit_amount`,
    rr.`receipt_no`,
    -- rr.sn1_uid_receipt_key,
	rr.`document_no` AS `receipt_document_no`,
	-- ri.`total_amount` AS 	`receipt_paid_amount`,
    IF(ri.`total_amount` IS NULL AND rr.`amount` = ii.`total_amount`, rr.`amount`, ri.`total_amount`) AS 	`receipt_paid_amount`,
	IF(rr.`payment_type` LIKE '%CDA', 'CDA', 'Non-CDA') AS `receipt_payment_mode`,
	rr.`payment_type` AS `receipt_payment_type`,
	IFNULL(ba.`bill_reference_number`, '') AS `bank_account_no`,
	-- Masked GIRO account
    -- IF(LENGTH(IFNULL(ba.`bill_reference_number`, '')) > 4, CONCAT(substring(IFNULL(ba.`bill_reference_number`, ''), 1, LENGTH(IFNULL(ba.`bill_reference_number`, ''))-4), 'XXX', substring(IFNULL(ba.`bill_reference_number`, ''), -1, 1)), IFNULL(ba.`bill_reference_number`, '')) AS `bank_account_no`,
	IF(ba.`id` IS NULL OR rr.`payment_type` NOT LIKE '%CDA', '', IF(ba.`is_sibling_cda`=1, 'Yes', 'NO')) AS `is_sibling_cda`
	
	
	
FROM (
SELECT 
		active_child.`fk_child` AS `id`,
        MAX(ii.`id`) AS `invoice_item_id`
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
	INNER JOIN `invoice` iv ON iv.`fk_child` = active_child.`fk_child`
    INNER JOIN `invoice_item` ii ON ii.`fk_invoice` = iv.`id` AND ii.`active`=1 AND ii.`label` LIKE 'deposit%' 
WHERE
    iv.`fk_centre` IN (1, 5, 10, 18, 16, 20)
    AND iv.`status` = 'completed'
    AND
	(iv.`invoice_type` = 'deposit' OR 
		iv.`label` LIKE 'deposit%' OR 
		ii.`id` IS NOT NULL
    )
GROUP BY `id`
) unique_deposit_invoice_per_child
	INNER JOIN `invoice_item` ii ON ii.`id` = unique_deposit_invoice_per_child.`invoice_item_id` AND ii.`active`=1 -- AND ii.`label` like 'deposit%' 
    INNER JOIN `billable_item` bi ON bi.`id` = ii.`fk_billable_item` AND bi.`active` = 1
    INNER JOIN `invoice` iv ON iv.`id`= ii.`fk_invoice` AND iv.`active` = 1
	INNER JOIN `centre` cnt ON cnt.`id` = iv.`fk_centre` AND cnt.`active` = 1
	LEFT OUTER JOIN `receipt_item` ri ON ri.`fk_invoice_item` = unique_deposit_invoice_per_child.`invoice_item_id` AND ri.`active` = 1
    LEFT OUTER JOIN `receipt` rr ON rr.`id` = ri.`fk_receipt` AND rr.`active` = 1
    LEFT OUTER JOIN `bank_account` ba ON ba.`id`= rr.`fk_bank_account`
WHERE
	rr.`cancelled_date` IS NULL
-- AND id = "57"
ORDER BY unique_deposit_invoice_per_child.`id`;