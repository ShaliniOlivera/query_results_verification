-- Kai Child SOA Details
SELECT fd.`id`,
	fd.`fk_child` AS `child_id`,
    cnt.`code` AS `centre_code`,
    fd.`uploaded_at` AS `document_date`,
    fd.`url` AS `storage_path`
FROM (
SELECT 
	fd.`id`,
    fd.`filename`,
    IF(fd.`url` LIKE '/%', SUBSTRING(fd.`url`, 2), fd.`url`) AS `url`,
    fd.`label`,
    fd.`fk_user`,
    JSON_UNQUOTE(JSON_EXTRACT(fd.report_request_dto, '$.centreID')) AS `fk_centre`,
    JSON_UNQUOTE(JSON_EXTRACT(fd.report_request_dto, '$.childID')) AS `fk_child`,
    fd.`uploaded_at`,
    fd.`created_at`, 
    fd.`updated_at`
FROM finance_document fd
WHERE
	fd.`doc_type` = 'report' 
    AND fd.`report_code` = 'child_soa_report'
    AND fd.`status` = 'successful'
    AND fd.`uploaded_at` >= '2025-01-01 00:00:00'
	AND fd.`active` = 1
) fd
	INNER JOIN 
	(
    SELECT 
		active_child.`fk_child`,
        (SELECT cl.`id` FROM `child_level` cl WHERE cl.`fk_child` = active_child.`fk_child` AND cl.`from` = active_child.`earliest_from` AND (cl.`to` IS NULL OR cl.`to` >= CURRENT_TIMESTAMP) AND cl.`active` = 1 LIMIT 1) AS `current_enrolled_child_level_id`
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
    ) filtered_data ON filtered_data.`fk_child` = fd.`fk_child`
    INNER JOIN `child_level` cl ON cl.`fk_child` = filtered_data.`fk_child` AND cl.`id` = filtered_data.`current_enrolled_child_level_id` AND cl.`active` = 1
    INNER JOIN `centre` cnt ON cnt.`id` = cl.`fk_centre` AND cnt.`active` = 1
WHERE
	fd.`fk_centre` = cl.`fk_centre`
;