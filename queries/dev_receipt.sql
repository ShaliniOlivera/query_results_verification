-- kai receipts
select rp.`id`, 
	active_child.`fk_child` AS `child_id`,
	cnt.`code` AS `centre_code`,
    rp.`receipt_no`, rp.`collected_date`,
    IFNULL(ba.`bill_reference_number`, '') AS `bank_account_no`,
    rp.`payment_type`,
    IF(rp.`payment_type` IN ('giro_cda', 'nets_cda', 'offset_cda'), 'CDA', 'Non-CDA') AS `payment_mode`,
    rp.`document_no`,
    IF(rp.`amount` = 0 AND rp.`amount_received` > 0, rp.`amount_received`, rp.`amount`) AS `total_receipt_amount`,
    rp.`pdf_url_key` AS `pdf_storage_path`,
    TRIM(CONCAT(IFNULL(usr_collected.`firstname`, ''), ' ', IFNULL(usr_collected.`lastname`, ''))) AS `collected_by_staff_name`,
    TRIM(CONCAT(IFNULL(usr_cancelled.`firstname`, ''), ' ', IFNULL(usr_cancelled.`lastname`, ''))) AS `cancelled_by_staff_name`,
    IFNULL(rp.`cancelled_date`, '') AS `cancellation_date`,
    IFNULL(rp.`cancelation_reason`, '') AS `cancellation_reason`,
    rp.`created_at`, rp.`updated_at`
from (
select cl.fk_child, min(cl.`from`) as earliest_from
from child_level cl
where
	cl.fk_centre in (1, 5, 10, 18, 16, 20)
    and
	(cl.`to` is null or cl.`to` >= current_timestamp)
    and
	cl.`active` = 1
group by cl.fk_child
) active_child
	inner join receipt rp ON rp.`fk_child` = active_child.`fk_child`
		AND rp.`active` = 1
	inner join `centre` cnt ON cnt.`id` = rp.`fk_centre`
    left outer join `bank_account` ba on ba.`id` = rp.`fk_bank_account`
    left outer join `user` usr_collected on usr_collected.`id` = rp.`collected_by_fk_staff`
    left outer join `user` usr_cancelled on usr_cancelled.`id` = rp.`cancelled_by_fk_staff`

WHERE
	rp.fk_centre in (1, 5, 10, 18, 16, 20)
    AND NOT EXISTS(SELECT 1 FROM `receipt_item` ri where ri.`fk_receipt` = rp.`id` AND ri.`active` = 1)
    AND (rp.`created_at` >= '2025-01-01 00:00:00' OR rp.`updated_at` >= '2025-01-01 00:00:00' OR rp.`collected_date` >= '2025-01-01 00:00:00')
    
union

-- Normal receipts
select 
	rp.`id`, 
    filtered_invoice.`child_id` AS `child_id`,
	cnt.`code` AS `centre_code`,
    rp.`receipt_no`, rp.`collected_date`,
    IFNULL(ba.`bill_reference_number`, '') AS `bank_account_no`,
    rp.`payment_type`,
    IF((ba.`id` is not null AND ba.`is_cda`='1') OR rp.`payment_type` IN ('giro_cda', 'nets_cda', 'offset_cda'), 'CDA', 'Non-CDA') AS `payment_mode`,
    rp.`document_no`,
    IF(rp.`amount` = 0 AND rp.`amount_received` > 0, rp.`amount_received`, rp.`amount`) AS `total_receipt_amount`,
    rp.`pdf_url_key` AS `pdf_storage_path`,
    TRIM(CONCAT(IFNULL(usr_collected.`firstname`, ''), ' ', IFNULL(usr_collected.`lastname`, ''))) AS `collected_by_staff_name`,
    TRIM(CONCAT(IFNULL(usr_cancelled.`firstname`, ''), ' ', IFNULL(usr_cancelled.`lastname`, ''))) AS `cancelled_by_staff_name`,
    IFNULL(rp.`cancelled_date`, '') AS `cancellation_date`,
    IFNULL(rp.`cancelation_reason`, '') AS `cancellation_reason`,
    rp.`created_at`, rp.`updated_at`
from (
select 
	active_child.`fk_child` AS `child_id`,
    iv.`id`,
    cnt.`code` AS `centre_code`,
    iv.`invoice_no`, iv.`invoice_date`, iv.`label` AS `invoice_label`, iv.`invoice_type` AS `type`,
    iv.`status`, iv.`invoice_due_date`, 
    iv.`total_tax_amount`, iv.`total_amount` AS `total_amount_exclude_tax`, 
    iv.`total_discount_amount`, iv.outstanding_amount, iv.`total_tax_amount`+iv.`total_amount` AS `total_payable_amount`,
    iv.`pdf_url_key` AS `invoice_pdf_storage_path`,
    IFNULL(TRIM(CONCAT(IFNULL(usr_created.`firstname`, ''), ' ' , usr_created.`lastname`)), '') AS `created_by_staff_name`, 
    IFNULL(TRIM(CONCAT(IFNULL(usr_updated.`firstname`, ''), ' ' , usr_updated.`lastname`)), '') AS `updated_by_staff_name`
	, ii.`id` AS `fk_invoice_item`
from 
(
select cl.fk_child, min(cl.`from`) as earliest_from
from child_level cl
where
	cl.fk_centre in (1, 5, 10, 18, 16, 20)
    and
	(cl.`to` is null or cl.`to` >= current_timestamp)
    and
	cl.`active` = 1
group by cl.fk_child
) active_child
	inner join invoice iv on iv.`fk_child` = active_child.`fk_child` and iv.`active` = 1
    inner join invoice_item ii on ii.fk_invoice = iv.`id` and ii.`active` = 1
    inner join centre cnt on cnt.`id` = iv.`fk_centre`
    left outer join `user` usr_created ON usr_created.`id` = iv.`created_by_fk_staff`
    left outer join `user` usr_updated ON usr_updated.`id` = iv.`created_by_fk_staff`
where
	cnt.id in (1, 5, 10, 18, 16, 20)
    AND iv.`status` != 'draft'
    and iv.`pdf_url_key` is not null
    AND iv.`invoice_date` >= '2025-01-01 00:00:00'
    
union

-- Registration child
select 
	active_child.`fk_child` AS `child_id`,
    iv.`id`,
    cnt.`code` AS `centre_code`,
    iv.`invoice_no`, iv.`invoice_date`, iv.`label` AS `invoice_label`, iv.`invoice_type` AS `type`,
    iv.`status`, iv.`invoice_due_date`, 
    iv.`total_tax_amount`, iv.`total_amount` AS `total_amount_exclude_tax`, 
    iv.`total_discount_amount`, iv.outstanding_amount, iv.`total_tax_amount`+iv.`total_amount` AS `total_payable_amount`,
    iv.`pdf_url_key` AS `invoice_pdf_storage_path`,
    IFNULL(TRIM(CONCAT(IFNULL(usr_created.`firstname`, ''), ' ' , usr_created.`lastname`)), '') AS `created_by_staff_name`, 
    IFNULL(TRIM(CONCAT(IFNULL(usr_updated.`firstname`, ''), ' ' , usr_updated.`lastname`)), '') AS `updated_by_staff_name`
    , ii.`id` AS `fk_invoice_item`
from 
(
select cl.fk_child, min(cl.`from`) as earliest_from
from child_level cl
where
	cl.fk_centre in (1, 5, 10, 18, 16, 20)
    and
	(cl.`to` is null or cl.`to` >= current_timestamp)
    and
	cl.`active` = 1
group by cl.fk_child
) active_child
	inner join `registration_child` rc ON rc.`fk_child` = active_child.`fk_child`
	inner join invoice iv on iv.`fk_registration_child` = rc.`id` and iv.`active` = 1
    inner join invoice_item ii on ii.fk_invoice = iv.`id` and ii.`active` = 1
    inner join centre cnt on cnt.`id` = iv.`fk_centre`
    left outer join `user` usr_created ON usr_created.`id` = iv.`created_by_fk_staff`
    left outer join `user` usr_updated ON usr_updated.`id` = iv.`created_by_fk_staff`
where
	cnt.id in (1, 5, 10, 18, 16, 20)
    AND iv.`status` != 'draft'
    and iv.`pdf_url_key` is not null
    AND iv.`invoice_date` >= '2025-01-01 00:00:00'
    
union
-- ECDA Registration child
select 
	active_child.`fk_child` AS `child_id`,
    iv.`id`,
    cnt.`code` AS `centre_code`,
    iv.`invoice_no`, iv.`invoice_date`, iv.`label` AS `invoice_label`, iv.`invoice_type` AS `type`,
    iv.`status`, iv.`invoice_due_date`, 
    iv.`total_tax_amount`, iv.`total_amount` AS `total_amount_exclude_tax`, 
    iv.`total_discount_amount`, iv.outstanding_amount, iv.`total_tax_amount`+iv.`total_amount` AS `total_payable_amount`,
    iv.`pdf_url_key` AS `invoice_pdf_storage_path`,
    IFNULL(TRIM(CONCAT(IFNULL(usr_created.`firstname`, ''), ' ' , usr_created.`lastname`)), '') AS `created_by_staff_name`, 
    IFNULL(TRIM(CONCAT(IFNULL(usr_updated.`firstname`, ''), ' ' , usr_updated.`lastname`)), '') AS `updated_by_staff_name`
    , ii.`id` AS `fk_invoice_item`
from 
(
select cl.fk_child, min(cl.`from`) as earliest_from
from child_level cl
where
	cl.fk_centre in (1, 5, 10, 18, 16, 20)
    and
	(cl.`to` is null or cl.`to` >= current_timestamp)
    and
	cl.`active` = 1
group by cl.fk_child
) active_child
	inner join `ecda_registration_child` rc ON rc.`fk_child` = active_child.`fk_child`
	inner join invoice iv on iv.`fk_ecda_registration_child` = rc.`id` and iv.`active` = 1
    inner join invoice_item ii on ii.fk_invoice = iv.`id` and ii.`active` = 1
    inner join centre cnt on cnt.`id` = iv.`fk_centre`
    left outer join `user` usr_created ON usr_created.`id` = iv.`created_by_fk_staff`
    left outer join `user` usr_updated ON usr_updated.`id` = iv.`created_by_fk_staff`
where
	cnt.id in (1, 5, 10, 18, 16, 20)
    AND iv.`status` != 'draft'
    and iv.`pdf_url_key` is not null
    AND iv.`invoice_date` >= '2025-01-01 00:00:00'
) filtered_invoice
	inner join receipt_item ri ON ri.`fk_invoice_item` = filtered_invoice.`fk_invoice_item` AND ri.`active`=1
    inner join receipt rp ON rp.id = ri.fk_receipt AND rp.`active`=1
    inner join `centre` cnt ON cnt.`id` = rp.`fk_centre`
    left outer join `bank_account` ba on ba.`id` = rp.`fk_bank_account`
    left outer join `user` usr_collected on usr_collected.`id` = rp.`collected_by_fk_staff`
    left outer join `user` usr_cancelled on usr_cancelled.`id` = rp.`cancelled_by_fk_staff`
WHERE
    (rp.`created_at` >= '2025-01-01 00:00:00' OR rp.`updated_at` >= '2025-01-01 00:00:00' OR rp.`collected_date` >= '2025-01-01 00:00:00')
;