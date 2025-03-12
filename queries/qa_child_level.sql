-- Sha's child_level
SELECT ch.id,
le.code AS level_code,
pr.code AS program_code,
cl.`from`,
cl.`to`,
coalesce(cl.move_reason,'') AS move_reason,
cl.created_at,
cl.updated_at
-- -------------------
FROM child_level cl
INNER JOIN child ch ON ch.id = cl.fk_child
INNER JOIN `level` le ON le.id = cl.fk_level
INNER JOIN `program` pr ON pr.id = cl.fk_program
WHERE cl.active = 1
AND ch.active = 1
AND cl.fk_centre IN (1, 5, 10, 18, 16, 20)
AND (cl.`TO` >= CURRENT_DATE OR cl.`TO` IS NULL)
AND (cl.from = (
    SELECT MAX(cl2.from)
    FROM child_level cl2
    WHERE cl2.fk_child = cl.fk_child
    AND cl2.active = 1
    AND (cl2.`TO` >= CURRENT_DATE OR cl2.`TO` IS NULL)
   )
OR YEAR(cl.to) = YEAR(CURDATE()))
AND cl.active = 1;

