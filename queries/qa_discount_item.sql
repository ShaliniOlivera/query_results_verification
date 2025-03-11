-- Sha's discount item
SELECT 
di.id, 
di.name AS label, 
ce.code AS centre_code,
dig.name AS discount_item_group, 
di.discount_item_type AS "type", 
di.type AS application_type, 
di.amount,
di.start_date AS "from",
coalesce(di.ceased_date,'') AS "to",
bi.id AS billable_item_id, 
bi.label AS billable_item_label, 
di.fk_billable_item_group AS billable_item_group_id,
di.fk_billable_item_group AS billable_item_group, 
bi2.label AS billable_item_group_label,
di.is_recurrent AS is_recurrent_discount,
di.disbursement_mode,
di.application_level,
di.created_at,
di.updated_at

FROM `discount_item` di
INNER JOIN `discount_item_group` dig ON dig.id = di.fk_discount_item_group 
   AND dig.status = "active"
INNER JOIN `billable_item` bi ON bi.id = di.fk_billable_item
   AND bi.active = 1 
   AND bi.fk_centre IN (1, 5, 10, 18, 16, 20)
INNER JOIN `centre` ce ON ce.id = bi.fk_centre
INNER JOIN `billable_item` bi2 ON bi2.`id` = di.`fk_billable_item_group` AND bi.`fk_centre` IN (1, 5, 10, 18, 16, 20) AND bi.`active` = 1
;
