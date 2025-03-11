select 
	filtered_data.`id`, filtered_data.`child_name`, filtered_data.`child_birth_certificate`, filtered_data.`relationship`,
    cnt.`code` AS `centre_code`,
    IF(gcv.`id` IS NOT NULL, 'Yes', 'No') AS `is_centre_verified`,
    filtered_data.`guardian_id`, filtered_data.`guardian_firstname`, filtered_data.`guardian_lastname`, filtered_data.`guardian_identification_no`, 
    filtered_data.`guardian_email`, filtered_data.`guardian_mobile_phone_country_code`, filtered_data.`guardian_mobile_phone`, filtered_data.`guardian_gender`, 
    filtered_data.`guardian_profile_photo_storage_path`, 
    filtered_data.`guardian_ic_front_image_storage_path`, filtered_data.`guardian_ic_back_image_storage_path`, 
    filtered_data.`created_at`, filtered_data.`updated_at`, 
    filtered_data.`created_by`
from (
select 
	distinct
	-- ch.id, ch.firstname as `child_firstname`, ch.lastname as `child_lastname`, ch.`birth_certificate` AS `child_birth_certificate`, 
    ch.id AS `id`, 
    ch.`fullname` as `child_name`, 
    ch.`birth_certificate` AS `child_birth_certificate`, 
    code_gcr.`description` AS `relationship`,
    gdr.`id` as `guardian_id`, 
    gdr.`firstname` AS `guardian_firstname`, gdr.`lastname` AS `guardian_lastname`, gdr.`identification_no` AS `guardian_identification_no`, 
    IFNULL(gdr.`email`, '') AS `guardian_email`, IFNULL(gdr.`mobile_phone_country_code`, '') AS `guardian_mobile_phone_country_code`, IFNULL(gdr.`mobile_phone`, '') AS `guardian_mobile_phone`, IFNULL(gdr.`gender`, '') AS `guardian_gender`,
    gdr.`profile_photo_key` AS `guardian_profile_photo_storage_path`,
    IFNULL(gdr.`ic_front_image_key`, '') AS `guardian_ic_front_image_storage_path`, IFNULL(gdr.`ic_back_image_key`, '') AS `guardian_ic_back_image_storage_path`,
    gdr.`created_at`, gdr.`updated_at`
    , TRIM(CONCAT(usr.`firstname`, ' ', usr.`lastname`)) AS `created_by`,
    (SELECT cl.`id` FROM `child_level` cl WHERE cl.`fk_child` = ch.`id` AND cl.`from` = active_child.`earliest_from` AND (cl.`to` is null or cl.`to` >= current_timestamp) AND cl.`active` = 1 limit 1) AS `current_enrolled_child_level_id`
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
	inner join child ch on ch.id = active_child.fk_child
		and ch.`active` = 1
	inner join `guardian_child_relation` gcr ON gcr.`fk_child` = ch.`id` and gcr.`active` = 1
    inner join `guardian` gdr ON gdr.`id` = gcr.`fk_guardian` AND gdr.`active` = 1
    inner join `code` code_gcr ON code_gcr.`id` = gcr.`fk_relation`
    left outer join `user` usr on usr.`id` = gdr.`created_by`
) filtered_data
	inner join `child_level` cl ON cl.`id` = filtered_data.`current_enrolled_child_level_id` AND cl.`active` = 1
    inner join `centre` cnt ON cnt.`id` = cl.`fk_centre`
    left outer join `guardian_centre_verification` gcv ON gcv.`fk_guardian` = filtered_data.`guardian_id`
		AND gcv.`fk_centre` = cl.`fk_centre`
        AND gcv.`status` != 'rejected'
		AND gcv.`active` = 1
;