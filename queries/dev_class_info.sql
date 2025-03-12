-- Kai's class_info
select distinct 
	cl.`id`,
    cl.`label`, cl.`description`,
    cnt.`code` AS `centre_code`, 
    lv.`code` AS `level_code`,
    IFNULL(cl.`from`, '') AS `from`, IFNULL(cl.`to`, '') AS `to`,
    IFNULL(cl.`cover_photo_key`, '') AS `banner_url_path`,
    IFNULL(cl.`profile_photo_key`, '') AS `profile_photo_url_path`,
    IF(cl.`is_default`=1, 'Yes', 'No') AS `is_default_class`,
    cl.`created_at`, cl.`updated_at`
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
	inner join child_class cc ON cc.`fk_child` = active_child.`fk_child` AND cc.`active` = 1
		AND (cc.`to` is null or cc.`to` > current_timestamp())
    inner join class cl on cl.`id` = cc.`fk_class` and cl.`active` = 1
    inner join centre cnt on cnt.`id` = cl.fk_centre AND cnt.`active` = 1
    inner join `level`lv ON lv.`id` = cl.`fk_level` AND lv.`active` = 1
WHERE
	cnt.`id` in (1, 5, 10, 18, 16, 20)
    AND
	(cl.`to` is null or cl.`to` > current_timestamp())
