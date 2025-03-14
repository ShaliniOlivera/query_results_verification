select 
	distinct
    ff.id,
	cnt.`code` as centre_code,
    ff.`label` as fee_label,
    ft.`id` AS fee_tier_id,
    ft.`label` as fee_tier_label,
    fg.`id` AS fee_group_id,
    fg.`group_code` as fee_group_label,
    lv.`code` as `level_code`,
    prg.`code` as `program_code`,
    ff.`nationality` as `nationality`,
    ff.`amount`,
    ft.`effective_for_registration_from` as `registration_from`,
    IFNULL(ft.`effective_for_registration_to`, '') as `registration_to`,
    ff.`effective_from` as `effective_from`,
    IFNULL(ff.`effective_to`, '') as `effective_to`,
    ff.created_at,
    ff.updated_at
from fee_tier ft
	inner join fee_group fg on fg.id = ft.fk_group
		and fg.`active` = true
    inner join fee ff on ff.fk_fee_tier = ft.id
		and ff.`active` = true
	inner join centre cnt on cnt.id = ft.fk_centre
		and cnt.active = true
	inner join `level` lv on lv.id = ff.fk_level
    inner join `program` prg on prg.id = ff.fk_program
where
	cnt.`id` in (1, 5, 10, 18, 16, 20)
    AND ff.`effective_from` <= current_timestamp
    AND (ff.`effective_to` is null or ff.`effective_to` > current_timestamp);