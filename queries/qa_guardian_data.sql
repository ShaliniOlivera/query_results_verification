SELECT DISTINCT 
    ch.id, 
    CONCAT(ch.firstname, ' ', ch.lastname) AS child_name,
    ch.birth_certificate AS child_birth_certificate,
    co.description AS relationship, 
    cl_centre.code AS centre_code,
    COALESCE(IF(gcv.id IS NOT NULL, 'Yes', 'No'), 'No') AS is_centre_verified,
    gu.id AS guardian_id,
    gu.firstname AS guardian_firstname, 
    gu.lastname AS guardian_lastname, 
    gu.identification_no AS guardian_identification_no, 
    gu.email AS guardian_email,
    IF(gu.mobile_phone_country_code IS NULL OR gu.mobile_phone_country_code = '', '', gu.mobile_phone_country_code) AS guardian_mobile_phone_country_code,
    IF(gu.mobile_phone IS NULL OR gu.mobile_phone = '', '', gu.mobile_phone) AS guardian_mobile_phone,
    IF(gu.gender IS NULL OR gu.gender = '', '', gu.gender) AS guardian_gender,
    IF(gu.profile_photo_key IS NULL OR gu.profile_photo_key = '', '', gu.profile_photo_key) AS guardian_profile_photo_storage_path,
    IF(gu.ic_front_image_key IS NULL OR gu.ic_front_image_key = '', '', gu.ic_front_image_key) AS guardian_ic_front_image_storage_path,
    IF(gu.ic_back_image_key IS NULL OR gu.ic_back_image_key = '', '', gu.ic_back_image_key) AS guardian_ic_back_image_storage_path,
    gu.created_at AS created_at, 
    gu.updated_at AS updated_at,
    CONCAT(us.firstname, ' ', us.lastname) AS created_by,
    gu.active
FROM `guardian_child_relation` gcr
LEFT JOIN `guardian` gu ON gu.id = gcr.fk_guardian 
    AND gu.active = 1
LEFT JOIN `child` ch ON ch.id = gcr.fk_child
LEFT JOIN `user` us ON us.id = gu.created_by
LEFT JOIN `code` co ON co.id = gcr.fk_relation AND co.active = 1
LEFT JOIN (
    SELECT cl.fk_child, cl.fk_centre, c.code
    FROM child_level cl
    INNER JOIN centre c ON c.id = cl.fk_centre
    WHERE cl.active = 1
    AND cl.fk_centre IN (1, 5, 10, 18, 16, 20)
    AND (cl.to IS NULL OR cl.to > CURRENT_DATE)
    AND cl.from = (
        SELECT MAX(cl2.from)
        FROM child_level cl2
        WHERE cl2.fk_child = cl.fk_child
        AND cl2.active = 1
        AND cl2.fk_centre IN (1, 5, 10, 18, 16, 20)
        AND (cl2.to IS NULL OR cl2.to > CURRENT_DATE)
    )
) cl_centre ON cl_centre.fk_child = ch.id
LEFT JOIN `guardian_centre_verification` gcv 
    ON gcv.fk_guardian = gu.id 
    AND gcv.active = 1 
    AND gcv.status != "rejected"
    AND gcv.fk_centre = cl_centre.fk_centre
WHERE ch.id IN (
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
)
AND gu.active = 1
AND gcr.active = 1;
