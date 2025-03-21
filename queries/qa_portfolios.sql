/*manual verification as there are very few records and verifying
this would need to create an entirely new verification script cos i am provided with csv*/

WITH 

pr_child AS (
SELECT ch.id AS child_id, cl.fk_level, cl.fk_program, cl.fk_centre
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
),

created_by AS (
SELECT us.id, us.lastname FROM `user` us
LEFT JOIN `portfolio` pr ON pr.fk_user = us.id 
),

approved_by AS (
SELECT us.id, us.lastname FROM `user` us
LEFT JOIN `portfolio` pr ON pr.approved_by = us.id 
)


SELECT 
pr.id, ce.code AS centre_code, 
pch.child_id, tr.name AS term_name, 
tr.term_code, 
tr.year AS term_year, 
tr.`FROM` AS term_from,
tr.`TO` AS term_to,
le.code AS level_code,
pr.fk_class AS class_id,
pr.title,
pr.portfolio_url AS portfolio_url_path,
ifnull(pr.approved_at,'') AS approved_at,
ifnull(ab.lastname,'') AS approved_by_staff_id,
pr.published_at,
cb.lastname AS created_by_staff_id,
pr.created_at,
pr.updated_at
FROM `skoolnet2_class_ops_db_20250317`.portfolio pr
INNER JOIN pr_child pch ON pch.child_id = pr.fk_child
INNER JOIN centre ce ON ce.id = pch.fk_centre
INNER JOIN `skoolnet2_class_ops_db_20250317`.term tr ON tr.id = pr.fk_term
INNER JOIN `level` le ON le.id = pr.fk_level
LEFT JOIN created_by cb ON cb.id = pr.fk_user
LEFT JOIN approved_by ab ON ab.id = pr.fk_user
WHERE (pr.created_at >= '2025-01-01 00:00:00' OR pr.published_at >= '2025-01-01 00:00:00')
AND pr.status = 'published'
AND pr.active = 1;
