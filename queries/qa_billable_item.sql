-- Sha's Billable Items
SELECT bi.`id`, 
bi.`label`, 
bi.`sn1_str_acc_pac_account_code` AS acc_pac_code, 
bi.`type`, 
ce.`code` AS centre_code,
coalesce(bis.`name`, '') AS supplier, 
IF(bi.`is_default_subsidy` = 1,"Yes","No") AS is_default_subsidy,
bi.`display_order`,
IF(bi.`is_for_bulk_invoice` = 1,"Yes","No") AS is_for_bulk_invoice,
bi.`unit_price`,
coalesce(bi.`max_price`,'') AS max_unit_price,
bi.subsidy_type,
IF(bi.taxable = 1,"Yes","No") AS gst_taxable, 
IF(bi.cda_deductible = 1,"Yes","No") AS cda_deductible, 
bi.`from`, 
coalesce(bi.`to`,'') AS `to`, 
bi.created_at, 
bi.updated_at
 FROM billable_item bi
INNER JOIN `centre` ce ON ce.id = bi.fk_centre AND ce.id IN (1, 5, 10, 18, 16, 20)
LEFT JOIN billable_item_supplier bis ON bis.id = fk_billable_item_supplier
WHERE bi.active = 1 AND bi.`to` IS NULL OR bi.`to` > CURRENT_DATE;

