SELECT DISTINCT 
    ca.id,
    ca.title,
    ca.description,
    ca.interpretation,
    IFNULL(ca.link, '') AS link,
    ca.final_status AS status,
    ca.published_at,
    ca.created_at,
    ca.updated_at,
    ca.display_date,
    JSON_OBJECT('id', MIN(caas.fk_centre), 'code', MIN(ce.code)) AS centres,
    CONCAT('[', GROUP_CONCAT(DISTINCT JSON_OBJECT('id', caas.fk_class, 'label', tcc.class_name) SEPARATOR ','), ']') AS classes,
    CONCAT('[', GROUP_CONCAT(DISTINCT JSON_OBJECT('id', caas.fk_child, 'fullname', tch.fullname, 'birth_certificate', tch.birth_certificate) SEPARATOR ','), ']') AS children,
    IFNULL((
        SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
                "type", cai.type, 
                "source_path", cai.url, 
                "display_order", cai.index, 
                "created_at", 
                    CONCAT(DATE_FORMAT(cai.created_at, '%Y-%m-%d'), 'T', DATE_FORMAT(cai.created_at, '%H:%i:%s'), 'Z'), 
                "updated_at", 
                    CONCAT(DATE_FORMAT(cai.updated_at, '%Y-%m-%d'), 'T', DATE_FORMAT(cai.updated_at, '%H:%i:%s'), 'Z')
            )
        )
        FROM (
            SELECT cai.*
            FROM class_activity_image cai
            WHERE cai.fk_class_activity = ca.id
            ORDER BY CAST(cai.index AS UNSIGNED) ASC
        ) AS cai
    ), JSON_ARRAY()) AS medias,
    IFNULL((
        SELECT JSON_ARRAYAGG(unique_tags.name_lowercase) 
        FROM (
            SELECT DISTINCT cat.name_lowercase 
            FROM class_activity_tag_relation catr 
            LEFT JOIN class_activity_tag cat ON cat.id = catr.fk_activity_tag 
            WHERE catr.fk_class_activity = ca.id
        ) AS unique_tags
    ), JSON_ARRAY()) AS tags,
    IFNULL(GROUP_CONCAT(DISTINCT lp.label), '') AS lesson_plans,
    IFNULL((
        SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
                'id', CAST(lg.id AS SIGNED),  
                'code', COALESCE(lg.code, ''),
                'title', COALESCE(lg.title, ''),
                'description', COALESCE(lg.description, '')
            )
        )
        FROM class_activity_learning_goal calg
        LEFT JOIN learning_goal lg ON lg.id = calg.fk_learning_goal
        WHERE ca.id = calg.fk_class_activity
        AND calg.active = 1
        AND lg.active = 1
    ), JSON_ARRAY()) AS learning_goals,
    IFNULL((
        SELECT JSON_OBJECT(
            'domains', 
            IFNULL(
                JSON_ARRAYAGG(
                    JSON_OBJECT(
                        'id', CAST(dom.id AS SIGNED),  
                        'title', COALESCE(dom.title, '')
                    )
                ), 
                JSON_ARRAY()
            ),
            'sub_domains', JSON_ARRAY() 
        )
        FROM class_activity_developmental_and_learning_area cadl
        LEFT JOIN domain dom ON dom.id = cadl.fk_domain
        WHERE ca.id = cadl.fk_class_activity
        AND cadl.active = 1
        AND dom.active = 1
    ), '') AS development_and_learning_area
FROM 
    class_activity ca
INNER JOIN class_activity_access_scope caas ON caas.fk_class_activity = ca.id
INNER JOIN `sn2_centre_service_db`.centre ce ON ce.id = caas.fk_centre
INNER JOIN (SELECT * FROM temp_child) tch ON tch.id = caas.fk_child
LEFT JOIN class_activity_image cai ON cai.fk_class_activity = ca.id
LEFT JOIN class_activity_tag_relation catr ON catr.fk_class_activity = ca.id
LEFT JOIN class_activity_tag cat ON cat.id = catr.fk_activity_tag
LEFT JOIN class_activity_lesson_plan calp ON calp.fk_class_activity = ca.id
LEFT JOIN lesson_plan lp ON lp.id = calp.fk_lesson_plan
LEFT JOIN `temp_child_class` tcc ON tcc.child_id = caas.fk_child AND tcc.class_id = caas.fk_class
LEFT JOIN `class_activity_learning_goal` calg ON calg.fk_class_activity = ca.id
LEFT JOIN `learning_goal` lg ON lg.id = calg.fk_learning_goal
LEFT JOIN `class_activity_developmental_and_learning_area` cadl ON cadl.fk_class_activity = ca.id
LEFT JOIN `domain` dom ON dom.id = cadl.fk_domain
WHERE 
    ca.type = "foliette"
    AND ca.active = 1
    AND (
        (ca.final_status = "published" AND (ca.published_at >= '2025-01-01 00:00:00' OR ca.created_at >= '2025-01-01 00:00:00'))
        OR 
        (ca.final_status IN ("approved", "pending") AND ca.created_at >= '2025-01-01 00:00:00')
    )
GROUP BY 
    ca.id, ca.title, ca.description, ca.interpretation, ca.link, ca.status, 
    ca.published_at, ca.created_at, ca.updated_at, ca.display_date;
