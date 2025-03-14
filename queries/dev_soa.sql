
select 
	distinct
    soa.`id`,
	ch.id AS `child_id`, 
    cnt.`code` AS `centre_code`,
	-- Custom logic to add 1 month to date field as per FE
    DATE_FORMAT(DATE_ADD(soa.`date`, INTERVAL 1 MONTH), '%Y-%m-%d') AS `document_date`,
    soa.`url` AS `document_storage_path`,
    soa.`total_outstanding` AS `total_outstanding_amount`,
    soa.`created_at`,
    soa.`updated_at`
from (
select distinct cl.fk_child, cl.fk_level, cl.fk_program, cl.fk_centre
from child_level cl
where
	cl.fk_centre in (1, 5, 10, 18, 16, 20)
    AND (cl.`to` is null or cl.`to` > current_timestamp())
	AND cl.`active` = true
) active_child
	inner join `child` ch ON ch.`id` = active_child.`fk_child` AND ch.`active` = 1
	inner join `soa_monthly_pdf` soa ON soa.`fk_child` = active_child.`fk_child`
    inner join `centre` cnt ON cnt.`id` = soa.`fk_centre`
WHERE
	cnt.`id` in (1, 5, 10, 18, 16, 20)
    AND soa.`created_at` >= '2025-01-01 00:00:00'
;