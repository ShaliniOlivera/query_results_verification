
select 
	iv.`id`,
    active_child.`fk_child` AS `child_id`,
    cnt.`code` AS `centre_code`,
    iv.`invoice_no`, iv.`invoice_date`, iv.`label` AS `invoice_label`, iv.`invoice_type` AS `type`,
    iv.`status`, iv.`invoice_due_date`, 
    iv.`total_tax_amount`+iv.`total_amount` AS `total_payable_amount`,
    iv.`pdf_url_key` AS `invoice_pdf_storage_path`,
    IFNULL(TRIM(CONCAT(IFNULL(usr_created.`firstname`, ''), ' ' , usr_created.`lastname`)), '') AS `created_by_staff_name`, 
    IFNULL(TRIM(CONCAT(IFNULL(usr_updated.`firstname`, ''), ' ' , usr_updated.`lastname`)), '') AS `updated_by_staff_name`,
    iv.`created_at`, iv.`updated_at`
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
    inner join centre cnt on cnt.`id` = iv.`fk_centre`
    left outer join `user` usr_created ON usr_created.`id` = iv.`created_by_fk_staff`
    left outer join `user` usr_updated ON usr_updated.`id` = iv.`created_by_fk_staff`
where
	cnt.id in (1, 5, 10, 18, 16, 20)
    AND iv.`status` != 'draft'
    and
    iv.`pdf_url_key` is not null
    AND iv.`invoice_date` >= '2025-01-01 00:00:00'
union

-- Registration child
select 
	iv.`id`,
    active_child.`fk_child` AS `child_id`,
    cnt.`code` AS `centre_code`,
    iv.`invoice_no`, iv.`invoice_date`, iv.`label` AS `invoice_label`, iv.`invoice_type` AS `type`,
    iv.`status`, iv.`invoice_due_date`, 
    iv.`total_tax_amount`+iv.`total_amount` AS `total_payable_amount`,
    iv.`pdf_url_key` AS `invoice_pdf_storage_path`,
    IFNULL(TRIM(CONCAT(IFNULL(usr_created.`firstname`, ''), ' ' , usr_created.`lastname`)), '') AS `created_by_staff_name`, 
    IFNULL(TRIM(CONCAT(IFNULL(usr_updated.`firstname`, ''), ' ' , usr_updated.`lastname`)), '') AS `updated_by_staff_name`,
    iv.`created_at`, iv.`updated_at`
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
    inner join centre cnt on cnt.`id` = iv.`fk_centre`
    left outer join `user` usr_created ON usr_created.`id` = iv.`created_by_fk_staff`
    left outer join `user` usr_updated ON usr_updated.`id` = iv.`created_by_fk_staff`
where
	cnt.id in (1, 5, 10, 18, 16, 20)
    AND iv.`status` != 'draft'
    and
    iv.`pdf_url_key` is not null
    AND iv.`invoice_date` >= '2025-01-01 00:00:00'

union

-- ECDA Registration child
select 
	iv.`id`,
    active_child.`fk_child` AS `child_id`,
    cnt.`code` AS `centre_code`,
    iv.`invoice_no`, iv.`invoice_date`, iv.`label` AS `invoice_label`, iv.`invoice_type` AS `type`,
    iv.`status`, iv.`invoice_due_date`, 
    iv.`total_tax_amount`+iv.`total_amount` AS `total_payable_amount`,
    iv.`pdf_url_key` AS `invoice_pdf_storage_path`,
    IFNULL(TRIM(CONCAT(IFNULL(usr_created.`firstname`, ''), ' ' , usr_created.`lastname`)), '') AS `created_by_staff_name`, 
    IFNULL(TRIM(CONCAT(IFNULL(usr_updated.`firstname`, ''), ' ' , usr_updated.`lastname`)), '') AS `updated_by_staff_name`,
    iv.`created_at`, iv.`updated_at`
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
    inner join centre cnt on cnt.`id` = iv.`fk_centre`
    left outer join `user` usr_created ON usr_created.`id` = iv.`created_by_fk_staff`
    left outer join `user` usr_updated ON usr_updated.`id` = iv.`created_by_fk_staff`
where
	cnt.id in (1, 5, 10, 18, 16, 20)
    AND iv.`status` != 'draft'
    and
    iv.`pdf_url_key` is not null
    AND iv.`invoice_date` >= '2025-01-01 00:00:00'
;