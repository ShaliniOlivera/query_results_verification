SELECT DISTINCT 
    ca.id,
    ca.title,
    ca.description,
    ca.interpretation,
    IFNULL(ca.link, '') AS link,
    ca.status,
    ca.published_at,
    ca.created_at,
    ca.updated_at,
    ca.display_date,
    JSON_OBJECT('id', MIN(caas.fk_centre), 'code', MIN(ce.code)) AS centres,
    GROUP_CONCAT(DISTINCT JSON_OBJECT('id', caas.fk_class, 'label', tcc.class_name)) AS classes,
    GROUP_CONCAT(DISTINCT JSON_OBJECT('id', caas.fk_child, 'fullname', tch.fullname, 'birth_certificate', tch.birth_certificate)) AS children,
    GROUP_CONCAT(DISTINCT  JSON_OBJECT(
    "type", cai.type, 
    "source_path", cai.url, 
    "display_order", cai.index, 
    "created_at", DATE_FORMAT(cai.created_at, '%Y-%m-%d %H:%i:%s'), 
    "updated_at", DATE_FORMAT(cai.updated_at, '%Y-%m-%d %H:%i:%s'))) AS medias,
IFNULL((
        SELECT JSON_ARRAYAGG(unique_tags.name) 
        FROM (
            SELECT DISTINCT cat.name 
            FROM class_activity_tag_relation catr 
            LEFT JOIN class_activity_tag cat ON cat.id = catr.fk_activity_tag 
            WHERE catr.fk_class_activity = ca.id
        ) AS unique_tags
    ),
    JSON_ARRAY()
) AS tags,
    IFNULL(GROUP_CONCAT(DISTINCT lp.label), '') AS lesson_plans
FROM 
    class_activity ca
INNER JOIN class_activity_access_scope caas ON caas.fk_class_activity = ca.id
INNER JOIN `sn2_centre_service_db`.centre ce ON ce.id = caas.fk_centre
INNER JOIN `temp_child` tch ON tch.id = caas.fk_child
LEFT JOIN class_activity_image cai ON cai.fk_class_activity = ca.id
LEFT JOIN class_activity_tag_relation catr ON catr.fk_class_activity = ca.id
LEFT JOIN class_activity_tag cat ON cat.id = catr.fk_activity_tag
LEFT JOIN class_activity_lesson_plan calp ON calp.fk_class_activity = ca.id
LEFT JOIN lesson_plan lp ON lp.id = calp.fk_lesson_plan
LEFT JOIN `temp_child_class` tcc ON tcc.child_id = caas.fk_child AND tcc.class_id = caas.fk_class
WHERE 
    ca.type = "foliette"
    AND ca.active = 1
    AND (ca.published_at >= '2025-01-01 00:00:00' OR ca.published_at IS NULL OR ca.created_at >= '2025-01-01 00:00:00')
    AND ca.id = 289088
GROUP BY 
    ca.id, ca.title, ca.description, ca.interpretation, ca.link, ca.status, 
    ca.published_at, ca.created_at, ca.updated_at, ca.display_date;