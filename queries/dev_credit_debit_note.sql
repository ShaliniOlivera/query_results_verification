-- Credit debit note
select 
	cdn.`id`,
    cdn.`fk_child` AS `child_id`,
    cnt.`code` AS `centre_code`,
	cdn.`credit_debit_note_no`,
    cdn.`credit_debit_note_date`,
    cdn.`note_type` AS `type`,
    ABS(IFNULL((SELECT SUM(cdni.`adjusted_amount` - cdni.`amount`) FROM `credit_debit_note_item` cdni WHERE cdni.`fk_credit_debit_note` = cdn.`id` AND cdni.`active` = 1 GROUP BY cdni.`fk_credit_debit_note`), 0)) AS `amount`,
    IFNULL(cdn.`pdf_url_key`, '') AS `pdf_storage_path`,
	TRIM(CONCAT(IFNULL(usr_created.`firstname`, ''), ' ', IFNULL(usr_created.`lastname`, ''))) AS `created_by_staff_name`,
    TRIM(CONCAT(IFNULL(usr_updated.`firstname`, ''), ' ', IFNULL(usr_updated.`lastname`, ''))) AS `updated_by_staff_name`,
    IFNULL(cdn.`debt_writeoff_requester`, '') AS `debt_write_off_requester`,
    IFNULL(cdn.`debt_writeoff_approver`, '') AS `debt_write_off_approver`,
    IFNULL(cdn.`debt_writeoff_other_reason`, '') AS `debt_writeoff_other_reason`,
    IFNULL(cdn.`reason_code`, '') AS `reason`,
    IFNULL(cdn.`remarks`, '') AS `remarks`,
    cdn.`created_at`, cdn.`updated_at`
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
	inner join `credit_debit_note` cdn on cdn.`fk_child` = active_child.`fk_child` AND cdn.`active` = 1
	inner join `centre` cnt ON cnt.`id` = cdn.`fk_centre`
    left outer join `user` usr_created ON usr_created.`id` = cdn.`generated_by_fk_staff`
    left outer join `user` usr_updated ON usr_updated.`id` = cdn.`generated_by_fk_staff`
WHERE
	cdn.`credit_debit_note_date` >= '2025-01-01 00:00:00'
    
union

select 
	cdn.`id`,
    active_child.`fk_child` AS `child_id`,
    cnt.`code` AS `centre_code`,
	cdn.`credit_debit_note_no`,
    cdn.`credit_debit_note_date`,
    cdn.`note_type` AS `type`,
	ABS(IFNULL((SELECT SUM(cdni.`adjusted_amount` - cdni.`amount`) FROM `credit_debit_note_item` cdni WHERE cdni.`fk_credit_debit_note` = cdn.`id` AND cdni.`active` = 1 GROUP BY cdni.`fk_credit_debit_note`), 0)) AS `amount`,
    IFNULL(cdn.`pdf_url_key`, '') AS `pdf_storage_path`,
	TRIM(CONCAT(IFNULL(usr_created.`firstname`, ''), ' ', IFNULL(usr_created.`lastname`, ''))) AS `created_by_staff_name`,
    TRIM(CONCAT(IFNULL(usr_updated.`firstname`, ''), ' ', IFNULL(usr_updated.`lastname`, ''))) AS `updated_by_staff_name`,
    IFNULL(cdn.`debt_writeoff_requester`, '') AS `debt_write_off_requester`,
    IFNULL(cdn.`debt_writeoff_approver`, '') AS `debt_write_off_approver`,
    IFNULL(cdn.`debt_writeoff_other_reason`, '') AS `debt_writeoff_other_reason`,
    IFNULL(cdn.`reason_code`, '') AS `reason`,
    IFNULL(cdn.`remarks`, '') AS `remarks`,
    cdn.`created_at`, cdn.`updated_at`
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
	inner join `registration_child` rc ON rc.`fk_child` = active_child.`fk_child`
	inner join `credit_debit_note` cdn on cdn.`fk_registration_child` = rc.`id` AND cdn.`active` = 1
	inner join `centre` cnt ON cnt.`id` = cdn.`fk_centre`
    left outer join `user` usr_created ON usr_created.`id` = cdn.`generated_by_fk_staff`
    left outer join `user` usr_updated ON usr_updated.`id` = cdn.`generated_by_fk_staff`
WHERE
	cdn.`credit_debit_note_date` >= '2025-01-01 00:00:00'
    
union

select 
	cdn.`id`,
    active_child.`fk_child` AS `child_id`,
    cnt.`code` AS `centre_code`,
	cdn.`credit_debit_note_no`,
    cdn.`credit_debit_note_date`,
    cdn.`note_type` AS `type`,
    ABS(IFNULL((SELECT SUM(cdni.`adjusted_amount` - cdni.`amount`) FROM `credit_debit_note_item` cdni WHERE cdni.`fk_credit_debit_note` = cdn.`id` AND cdni.`active` = 1 GROUP BY cdni.`fk_credit_debit_note`), 0)) AS `amount`,
    IFNULL(cdn.`pdf_url_key`, '') AS `pdf_storage_path`,
	TRIM(CONCAT(IFNULL(usr_created.`firstname`, ''), ' ', IFNULL(usr_created.`lastname`, ''))) AS `created_by_staff_name`,
    TRIM(CONCAT(IFNULL(usr_updated.`firstname`, ''), ' ', IFNULL(usr_updated.`lastname`, ''))) AS `updated_by_staff_name`,
    IFNULL(cdn.`debt_writeoff_requester`, '') AS `debt_write_off_requester`,
    IFNULL(cdn.`debt_writeoff_approver`, '') AS `debt_write_off_approver`,
    IFNULL(cdn.`debt_writeoff_other_reason`, '') AS `debt_writeoff_other_reason`,
    IFNULL(cdn.`reason_code`, '') AS `reason`,
    IFNULL(cdn.`remarks`, '') AS `remarks`,
    cdn.`created_at`, cdn.`updated_at`
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
	inner join `ecda_registration_child` rc ON rc.`fk_child` = active_child.`fk_child`
	inner join `credit_debit_note` cdn on cdn.`fk_ecda_registration_child` = rc.`id` AND cdn.`active` = 1
	inner join `centre` cnt ON cnt.`id` = cdn.`fk_centre`
    left outer join `user` usr_created ON usr_created.`id` = cdn.`generated_by_fk_staff`
    left outer join `user` usr_updated ON usr_updated.`id` = cdn.`generated_by_fk_staff`
WHERE
	cdn.`credit_debit_note_date` >= '2025-01-01 00:00:00'
;