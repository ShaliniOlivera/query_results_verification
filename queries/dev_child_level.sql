-- Kai's child_level
SELECT 
	active_child.`fk_child` AS `id`,
    lv.`code` AS `level_code`,
    prg.`code` AS `program_code`,
    cl.`from`, cl.`to`,
    IFNULL(cl.`move_reason`, '') AS `move_reason`,
    cl.`created_at`, cl.`updated_at`
FROM (
SELECT cl.fk_child, min(cl.`from`) AS earliest_from
FROM child_level cl
WHERE
	cl.fk_centre IN (1, 5, 10, 18, 16, 20)
    AND
	(cl.`to` IS NULL OR cl.`to` >= CURRENT_TIMESTAMP)
    AND
	cl.`active` = 1
GROUP BY cl.fk_child
) active_child
	INNER JOIN `child_level` cl ON cl.`fk_child` = active_child.`fk_child` AND cl.`active` = 1
	INNER JOIN `level` lv ON lv.`id` = cl.`fk_level`
    INNER JOIN `program` prg ON prg.`id` = cl.`fk_program`
WHERE
	cl.fk_centre IN (1, 5, 10, 18, 16, 20)
    AND
	(cl.`to` IS NULL OR cl.`to` > CURRENT_TIMESTAMP())
ORDER BY `id`, cl.`from` ASC;