-- reverify if the missing child records are elligible for export
SELECT ch.id, ch.firstname as child_firstname, ch.lastname as child_lastname, ch.birth_certificate AS child_birth_certificate, ch.date_of_birth, ch.gender, ch.race,ch.nationality, ch.image_key AS profile_photo_storage_path
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
);