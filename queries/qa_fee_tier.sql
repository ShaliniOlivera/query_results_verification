-- Sha's fee tier
SELECT 
f.id,
ce.code AS centre_code,
f.label AS fee_label,
ft.id AS fee_tier_id,
ft.label AS fee_tier_label,
ft.fk_group as fee_group_id,
fg.group_code AS fee_group_label,
le.code AS level_code,
pr.code AS program_code,
f.nationality,
f.amount,
ft.effective_for_registration_from AS registration_from,
ifnull(ft.effective_for_registration_to,'') AS registration_to,
f.effective_from,
ifnull(f.effective_to,'') AS effective_to,
f.created_at,
f.updated_at
FROM `fee_tier` ft
INNER JOIN `centre` ce ON ce.id = ft.fk_centre AND ce.id IN (1, 5, 10, 18, 16, 20)
INNER JOIN `fee` f ON f.fk_fee_tier = ft.id AND f.active = 1 AND (f.effective_to IS NULL OR f.effective_to > CURRENT_DATE)
INNER JOIN `fee_group` fg ON fg.id = ft.fk_group AND fg.active = 1
INNER JOIN `level` le ON le.id = f.fk_level AND le.active = 1
INNER JOIN `program` pr ON pr.id = f.fk_program AND pr.active = 1
WHERE ft.active = 1;
