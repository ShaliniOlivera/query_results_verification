-- Kai's Child Fee Tier
select 
	filtered_data.`fk_child` AS `id`,
    filtered_data.`child_firstname`,
    filtered_data.`child_lastname`,
    filtered_data.`child_birth_certificate`,
    filtered_data.`nationality`,
    filtered_data.`fee_group`,
    filtered_data.`fee_tier`,
    filtered_data.`fk_fee_tier` AS `fee_tier_id`,
    filtered_data.`effective_from`,
    IFNULL(filtered_data.`effective_to`, '') AS `effective_to`,
    filtered_data.`centre_code`,
    lv.`code` AS `level_code`,
    prg.`code` AS `program_code`
from (
select active_child.`fk_child`, 
	ch.firstname as `child_firstname`, ch.lastname as `child_lastname`, ch.`birth_certificate` AS `child_birth_certificate`, 
    ch.`nationality` AS `nationality`,
    fg.`group_code` AS `fee_group`, ft.`label` AS `fee_tier`, ft.`id` AS `fk_fee_tier`,
    cft.`from` AS `effective_from`, cft.`to` AS `effective_to`,
    cnt.`code` AS `centre_code`,
    (SELECT cl.`id` FROM `child_level` cl WHERE cl.`fk_child` = ch.`id` AND cl.`from` = active_child.`earliest_from` AND (cl.`to` is null or cl.`to` >= current_timestamp) AND cl.`active` = 1 limit 1) AS `current_enrolled_child_level_id`
	-- count(*) as total
	-- fg.`group_code`
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
	inner join child_fee_tier cft ON cft.`fk_child` = active_child.`fk_child`
		AND (cft.`to` is null or cft.`to` > current_timestamp)
        AND cft.`active` = 1
	inner join fee_tier ft on ft.id = cft.fk_fee_tier and ft.active = 1
    inner join fee_group fg on fg.`id`= ft.`fk_group`
    inner join centre cnt on cnt.`id` = ft.`fk_centre`
)
	filtered_data
    inner join `child_level` cl ON cl.`id` = filtered_data.`current_enrolled_child_level_id` AND cl.`active` = 1
    inner join fee ff on ff.`fk_fee_tier` = filtered_data.`fk_fee_tier`
		and ff.`nationality` = filtered_data.`nationality`
        and ff.`fk_level` = cl.`fk_level`
        and ff.`fk_program` = cl.`fk_program`
		and ff.`active` = 1
        and ff.`effective_to` is null
	inner join `level` lv on lv.`id` = ff.`fk_level`
    inner join `program` prg on prg.`id` = ff.`fk_program`
;