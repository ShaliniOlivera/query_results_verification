-- Sha's class_info
SELECT DISTINCT cla.id,
cla.label,
cla.description,
ce.code AS centre_code,
le.code AS level_code,
coalesce(cla.`from`,'') AS `from`,
coalesce(cla.`to`,'') AS `to`,
coalesce(cla.cover_photo_key,'') AS banner_url_path,
coalesce(cla.profile_photo_key,'') AS profile_photo_url_path,
IF(cla.is_default = 1, "Yes","No") AS is_default_class,
cla.created_at,
cla.updated_at
FROM class cla
INNER JOIN centre ce ON ce.id = cla.fk_centre AND ce.id IN (1, 5, 10, 18, 16, 20)
INNER JOIN `level` le ON le.id = cla.fk_level
INNER JOIN child_class ccla ON ccla.fk_class = cla.id AND ccla.active = 1 AND (ccla.`to` IS NULL OR ccla.`to` > CURRENT_DATE)
WHERE ccla.fk_child IN (
   SELECT ch.id 
   FROM child_level cl
   INNER JOIN child ch ON ch.id = cl.fk_child
   WHERE cl.active = 1
   AND ch.active = 1
   AND cl.fk_centre IN (1, 5, 10, 18, 16, 20)
   AND (cl.`TO` >= CURRENT_DATE OR cl.`TO` IS NULL)
   AND cl.from = (
       SELECT MAX(cl2.from)
       FROM child_level cl2
       WHERE cl2.fk_child = cl.fk_child
       AND cl2.active = 1
       AND (cl2.`TO` >= CURRENT_DATE OR cl2.`TO` IS NULL)
   )
   ) 
AND cla.active = 1
AND (cla.`TO` > CURRENT_DATE OR cla.`TO` IS NULL)
AND cla.is_hidden = 0;


