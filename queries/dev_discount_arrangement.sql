-- Kai's discount arrangement
select 
	dar.`fk_child` AS `id`,
    ch.`firstname` as `child_firstname`, 
    ch.`lastname` as `child_lastname`, 
    ch.`birth_certificate` AS `child_birth_certificate`, 
    cnt.`code` AS `centre_code`,
    di.`id` AS `discount_item_id`, di.`name` AS `discount_item_label`,
    dar.`amount`, 
    -- dar.total_quantity, dar.`unused_quantity`,
    dar.`from`, IFNULL(dar.`to`, '') AS `to`, 
    IF(dar.`is_recurrent`=1, 'Yes', 'No') AS `is_recurrent_discount`,
    TRIM(CONCAT(IFNULL(usr_created.`firstname`, ''), ' ', IFNULL(usr_created.`lastname`, ''))) AS created_by,
    TRIM(CONCAT(IFNULL(usr_updated.`firstname`, ''), ' ', IFNULL(usr_updated.`lastname`, ''))) AS updated_by,
    dar.`created_at`, dar.`updated_at`
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
	inner join `discount_arrangement` dar ON dar.`fk_child` = active_child.`fk_child`
		AND dar.`active` = 1
	inner join `centre` cnt ON cnt.`id` = dar.`fk_centre` AND cnt.`active` = 1
    inner join `child` ch on ch.`id` = dar.`fk_child` AND ch.`active` = 1
    inner join `discount_item` di ON di.`id` = dar.`fk_discount_item`
		AND di.`active` = 1
	left outer join `user` usr_created on usr_created.`id` = dar.`created_by_fk_staff`
    left outer join `user` usr_updated on usr_updated.`id` = dar.`last_updated_by_fk_staff`
WHERE
	dar.`fk_centre` in (1, 5, 10, 18, 16, 20)
    AND (dar.`to` is null or dar.`to` >= current_timestamp)
;