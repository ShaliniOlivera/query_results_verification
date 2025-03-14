-- Sha's discount arrangement
SELECT DISTINCT ch.id,
ch.firstname AS child_firstname,
ch.lastname AS child_lastname,
ch.birth_certificate AS child_birth_certificate,
ce.code AS centre_code,
di.id AS discount_item_id,
di.name AS discount_item_label,
di.amount, 
da.from,
ifnull(da.`to`,'') AS `to`,
IF(di.is_recurrent = 1, "Yes", "No") AS is_recurrent_discount,
da.created_at,
ifnull(da.updated_at,'') AS updated_at

FROM `discount_arrangement` da
INNER JOIN `child` ch ON ch.id = da.fk_child
LEFT JOIN `centre` ce ON ce.id = da.fk_centre AND ce.id IN (1, 5, 10, 18, 16, 20)
LEFT JOIN `discount_item` di ON di.id = da.fk_discount_item AND di.active = 1
WHERE da.fk_child IN (
   SELECT ch.id
   FROM child_level cl
   INNER JOIN child ch ON ch.id = cl.fk_child
   WHERE cl.active = 1
   AND ch.active = 1
   AND cl.fk_centre IN (1, 5, 10, 18, 16, 20)
   AND (cl.`to` >= CURRENT_DATE OR cl.`to` IS NULL)
   AND cl.from = (
       SELECT MAX(cl2.from)
       FROM child_level cl2
       WHERE cl2.fk_child = cl.fk_child
       AND cl2.active = 1
       AND (cl2.`to` >= CURRENT_DATE OR cl2.`to` IS NULL)
   )
AND da.active = 1
AND (da.`to` > CURRENT_DATE OR da.`to` IS NULL)
);
