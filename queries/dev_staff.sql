select 
	usr.`id`, stf.`staff_id`, 
    -- usr.`email`,
    REPLACE(REPLACE(REPLACE(usr.`email`, CONCAT('_x', usr.id, '_xax_'), '@'), 'sn2hulk+', ''), '@gmail.com', '') as `email`, 
    usr.`firstname`, usr.`lastname`, 
    IFNULL(stf.`display_name`, '') AS `display_name`, IFNULL(usr.`mobile_phone`, '') AS `mobile_phone`, IFNULL(usr.`image_key`, '') AS `profile_photo_storage_path`, 
    group_concat(distinct rl.`label`) AS `role`,
    group_concat(distinct IF(uac_cl_cnt.`id` is not null, uac_cl_cnt.`code`, IFNULL(uac_centre.`code`, ''))) AS `centre_codes`,
    IFNULL(group_concat(distinct cts.`fk_class`, ''), '') AS `class_ids`,
    usr.`created_at`, usr.`updated_at`
from `user_access_control` uac
	inner join `staff` stf on stf.`fk_user` = uac.`fk_user` and stf.`active` = 1
    inner join `user` usr on usr.`id` = stf.`fk_user` and usr.`active` = 1
    inner join `user_role_relation` urr ON urr.`fk_user` = usr.`id` AND urr.`fk_role` in (8, 6, 23, 32, 76, 89, 29, 20) AND urr.`active` = 1
    inner join `role` rl on rl.`id` = urr.`fk_role` and rl.`active` = 1
    left outer join `centre` uac_centre ON uac_centre.`id` = uac.`fk_centre`
    left outer join `class` uac_cl on uac_cl.`id` = uac.`fk_class` AND uac_cl.`active` = 1 AND (uac_cl.`to` is null or uac_cl.`to` >= '2025-01-01 00:00:00')
    left outer join `centre` uac_cl_cnt ON uac_cl_cnt.`id` = uac_cl.`fk_centre`
    left outer join `class_teacher` cts ON cts.`fk_teacher` = uac.`fk_user` AND cts.`fk_class` = uac_cl.`id` AND cts.`active` = 1
		AND cts.fk_class in (
			select distinct 
	cl.`id`
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
        )
where
	uac.fk_centre in (1, 5, 10, 18, 16, 20)
    and uac.`active` = 1
    and stf.`is_resigned` = 0
group by usr.id, stf.`staff_id`, usr.`email`, usr.`firstname`, usr.`lastname`, usr.`mobile_phone`, usr.`image_key`, usr.`created_at`, usr.`updated_at`




union
-- HQ users
select 
	usr.`id`, stf.`staff_id`, 
    -- usr.`email`,
    REPLACE(REPLACE(REPLACE(usr.`email`, CONCAT('_x', usr.id, '_xax_'), '@'), 'sn2hulk+', ''), '@gmail.com', '') as `email`,
    usr.`firstname`, usr.`lastname`, 
    IFNULL(stf.`display_name`, '') AS `display_name`, IFNULL(usr.`mobile_phone`, '') AS `mobile_phone`, IFNULL(usr.`image_key`, '') AS `profile_photo_storage_path`, 
    group_concat(distinct rl.`label`) AS `role`,
    (SELECT group_concat(cnt.`code`) FROM `centre` cnt WHERE cnt.id in (1, 5, 10, 18, 16, 20)) as `centre_codes`,
    '' AS `class_ids`,
    usr.`created_at`, usr.`updated_at`
from `user_access_control` uac
	inner join `staff` stf on stf.`fk_user` = uac.`fk_user` and stf.`active` = 1
    inner join `user` usr on usr.`id` = stf.`fk_user` and usr.`active` = 1
    inner join `user_role_relation` urr ON urr.`fk_user` = usr.`id` AND urr.`fk_role` in (20) AND urr.`active` = 1
    inner join `role` rl on rl.`id` = urr.`fk_role` and rl.`active` = 1
where
	rl.`id` = 20
    and
	uac.fk_school = 2
    and uac.`active` = 1
    and stf.`is_resigned` = 0
group by usr.id, stf.`staff_id`, usr.`email`, usr.`firstname`, usr.`lastname`, usr.`mobile_phone`, usr.`image_key`, usr.`created_at`, usr.`updated_at`
;