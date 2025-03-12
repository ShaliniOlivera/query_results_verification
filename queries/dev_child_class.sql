-- Kai's child_class
select 
	active_child.`fk_child` AS `id`,
    cnt.`code` AS `centre_code`,
    cls.`id` AS `class_id`,
    lv.`code` AS `level_code`,
    cl.`from`, cl.`to`,
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
	inner join `child_class` cl on cl.`fk_child` = active_child.`fk_child` AND cl.`active` = 1
    inner join `class` cls on cls.`id` = cl.`fk_class` AND cls.`active` = 1
    inner join `centre` cnt on cnt.`id` = cls.`fk_centre`
	inner join `level` lv ON lv.`id` = cls.`fk_level`
WHERE
	cnt.`id` in (1, 5, 10, 18, 16, 20)
	AND (cl.`to` is null or cl.`to` > current_timestamp())
ORDER BY `id`, cl.`from` ASC;