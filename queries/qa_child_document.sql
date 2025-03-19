WITH active_child AS (
    SELECT 
        cl.fk_child, 
        MIN(cl.`from`) AS earliest_from
    FROM child_level cl
    WHERE cl.fk_centre IN (1, 5, 10, 18, 16, 20)
    AND (cl.`to` IS NULL OR cl.`to` >= CURRENT_TIMESTAMP)
    AND cl.`active` = 1
    GROUP BY cl.fk_child
)

SELECT 
    ch.id, 
    ch.fullname, 
    ch.birth_certificate, 
    dt.id AS dt_id,
    CASE
        WHEN dt.`label` LIKE '%Birth Certificate%' THEN 'birth_certificate'
        WHEN dt.`label` LIKE '%Immuni%' THEN 'vaccination_immunisation_record'
        WHEN dt.`label` LIKE '%guardian%' AND dt.`label` LIKE '%NRIC%' THEN 'ic_of_authorized_pickups'
        WHEN dt.`label` LIKE '%NRIC%' AND dt.`fk_registration_family_member` IS NULL AND 
             (dt.`fk_parent` IS NOT NULL OR dt.`fk_registration_parent` IS NOT NULL OR dt.`fk_ecda_registration_parent` IS NOT NULL) THEN 'parents_id'
        WHEN dt.`label` LIKE '%Employment Letter from Employer%' THEN 'mother_letter_of_employment'
        WHEN dt.`label` LIKE '%Passport photo%' OR dt.`label` LIKE '%Passport size photo%' OR 
             dt.`label` LIKE '%Passport-size Photograph%' AND NOT 
             (dt.`fk_parent` IS NOT NULL OR dt.`fk_registration_parent` IS NOT NULL OR 
              dt.`fk_ecda_registration_parent` IS NOT NULL OR dt.`fk_registration_family_member` IS NOT NULL) THEN 'passport_sized_photo_of_child'
        ELSE 'others'
    END AS `document_category`,
    dt.`label` AS document_label, 
    doc.filename AS document_filename, 
    doc.`url` AS document_source_path,
    CASE
        WHEN pr.`id` IS NOT NULL THEN TRIM(CONCAT(IFNULL(pr.`firstname`, ''), ' ', IFNULL(pr.`lastname`, '')))
        WHEN rp.`id` IS NOT NULL THEN TRIM(CONCAT(IFNULL(rp.`firstname`, ''), ' ', IFNULL(rp.`lastname`, '')))
        WHEN erp.`id` IS NOT NULL THEN TRIM(erp.`fullname`)
        WHEN rfm.`id` IS NOT NULL THEN TRIM(CONCAT(IFNULL(rfm.`firstname`, ''), ' ', IFNULL(rfm.`lastname`, '')))
        ELSE TRIM(CONCAT(IFNULL(ch.`firstname`, ''), ' ', IFNULL(ch.`lastname`, '')))
    END AS `document_owner`,
    IFNULL(TRIM(CONCAT(IFNULL(usr.`firstname`, ''), ' ', usr.`lastname`)), '') AS `uploaded_by`,
    dt.created_at, 
    dt.updated_at,
    IFNULL(dt.`fk_bank_account`, '') AS `giro_account_id`, 
    IFNULL(ba.`bill_reference_number`, '') AS `giro_account_reference_number`
FROM active_child
INNER JOIN child ch ON ch.id = active_child.fk_child
    AND ch.`active` = 1
INNER JOIN document_type dt ON dt.fk_child = ch.id AND dt.`active` = 1
INNER JOIN document_tag dtag ON dtag.fk_document_type = dt.id AND dtag.`active` = 1
INNER JOIN document doc ON doc.id = dtag.fk_document AND doc.`active` = 1
LEFT OUTER JOIN `user` usr ON usr.`id` = doc.`uploaded_by`
LEFT OUTER JOIN `parent` pr ON pr.`id` = dt.`fk_parent`
LEFT OUTER JOIN `user` doc_user ON doc_user.`id` = dt.`fk_user`
LEFT OUTER JOIN `registration_parent` rp ON rp.`id` = dt.`fk_registration_parent`
LEFT OUTER JOIN `ecda_registration_parent` erp ON erp.`id` = dt.`fk_ecda_registration_parent`
LEFT OUTER JOIN `registration_family_member` rfm ON rfm.`id` = dt.`fk_registration_family_member`
LEFT OUTER JOIN `bank_account` ba ON ba.`id` = dt.`fk_bank_account` AND ba.`active` = 1;
