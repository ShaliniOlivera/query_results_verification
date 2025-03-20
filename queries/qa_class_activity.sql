WITH ValidClasses AS (
    SELECT DISTINCT tccla.fk_class 
    FROM `skoolnet2_uat_20250317`.child_class tccla
    INNER JOIN `skoolnet2_uat_20250317`.class cla 
        ON cla.id = tccla.fk_class
    WHERE tccla.active = 1
      AND cla.active = 1
      AND cla.is_hidden = 0
      AND (cla.`to` >= '2025-01-01 00:00:00' OR cla.`to` IS NULL)
      AND (tccla.`to` IS NULL OR tccla.`to` >= '2025-01-01 00:00:00')
)

SELECT DISTINCT 
    ca.id,
    ca.type,
    ca.title,
    ca.description,
    ca.interpretation,
    IFNULL(ca.link, '') AS link,
    ca.status AS `status`,
    ca.published_at,
    ca.created_at,
    ca.updated_at,
    ca.display_date,
    JSON_OBJECT('id', MIN(caas.fk_centre), 'code', MIN(ce.code)) AS centres,
    CONCAT('[', GROUP_CONCAT(DISTINCT JSON_OBJECT('id', caas.fk_class, 'label', tcl.label) SEPARATOR ','), ']') AS classes,
    IF(
        COUNT(caas.fk_child) = 0, 
        NULL, 
        CONCAT('[', GROUP_CONCAT(DISTINCT JSON_OBJECT(
            'id', caas.fk_child, 
            'fullname', tch.fullname, 
            'birth_certificate', tch.birth_certificate
        ) SEPARATOR ','), ']')
    ) AS children,

    IFNULL(
        (
            SELECT JSON_ARRAYAGG(
                JSON_OBJECT(
                    "type", sub.type, 
                    "source_path", sub.url, 
                    "display_order", sub.index, 
                    "created_at", 
                        CONCAT(DATE_FORMAT(sub.created_at, '%Y-%m-%d'), 'T', DATE_FORMAT(sub.created_at, '%H:%i:%s'), 'Z'), 
                    "updated_at", 
                        CONCAT(DATE_FORMAT(sub.updated_at, '%Y-%m-%d'), 'T', DATE_FORMAT(sub.updated_at, '%H:%i:%s'), 'Z')
                )
            )
            FROM (
                SELECT DISTINCT cai.type, cai.url, cai.index, cai.created_at, cai.updated_at
                FROM `skoolnet2_class_ops_db_20250317`.class_activity_image cai
                WHERE cai.fk_class_activity = ca.id
            ) AS sub
        ),
        JSON_ARRAY()
    ) AS medias,

    IFNULL(
        IF(
            GROUP_CONCAT(DISTINCT cat.name_lowercase) IS NULL, 
            JSON_ARRAY(), 
            CONCAT('[', GROUP_CONCAT(DISTINCT JSON_QUOTE(cat.name_lowercase)), ']')
        ),
        JSON_ARRAY()
    ) AS tags

FROM `skoolnet2_class_ops_db_20250317`.class_activity ca
INNER JOIN `skoolnet2_class_ops_db_20250317`.class_activity_access_scope caas 
    ON caas.fk_class_activity = ca.id
INNER JOIN `skoolnet2_uat_20250317`.centre ce 
    ON ce.id = caas.fk_centre AND ce.id IN (1, 5, 10, 18, 16, 20)
INNER JOIN `skoolnet2_uat_20250317`.class tcl 
    ON tcl.id = caas.fk_class
LEFT JOIN `skoolnet2_uat_20250317`.child tch 
    ON tch.id = caas.fk_child
LEFT JOIN `skoolnet2_class_ops_db_20250317`.class_activity_tag_relation catr 
    ON catr.fk_class_activity = ca.id AND catr.active = 1
LEFT JOIN `skoolnet2_class_ops_db_20250317`.class_activity_tag cat 
    ON cat.id = catr.fk_activity_tag

WHERE 
    ca.type IN ("album", "post")
    AND ca.active = 1 
    AND caas.active = 1
    AND caas.fk_class IN (SELECT fk_class FROM ValidClasses)
    AND (
        (ca.status = "published" 
            AND (ca.published_at >= '2025-01-01 00:00:00' OR ca.created_at >= '2025-01-01 00:00:00'))
        OR 
        (ca.status IN ("approved", "pending") 
            AND ca.created_at >= '2025-01-01 00:00:00')
    )  

GROUP BY 
    ca.id, ca.title, ca.description, ca.interpretation, ca.link, ca.status, 
    ca.published_at, ca.created_at, ca.updated_at, ca.display_date;
