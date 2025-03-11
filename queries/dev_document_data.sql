SELECT ch.id AS `child_id`, ch.fullname, ch.birth_certificate, 
    dtp.id,
    CASE
		WHEN dtp.`label` LIKE '%Birth Certificate%' THEN 'birth_certificate'
        WHEN dtp.`label` LIKE '%Immmunization%' OR dtp.`label` LIKE '%Immunisation%' THEN 'vaccination_immunisation_record'
        WHEN dtp.`label` LIKE '%guardian%' AND dtp.`label` LIKE '%NRIC%' THEN 'ic_of_authorized_pickups'
        WHEN dtp.`label` LIKE '%NRIC%' AND dtp.`fk_registration_family_member` IS NULL AND (dtp.`fk_parent` IS NOT NULL OR dtp.`fk_registration_parent` IS NOT NULL OR dtp.`fk_ecda_registration_parent` IS NOT NULL) THEN 'parents_id'
        -- WHEN dtp.`label` LIKE '%Enrolment supporting documents%' OR dtp.`label` LIKE '%Enrollment supporting documents%' THEN 'Enrolment supporting documents'
        WHEN dtp.`label` LIKE '%Employment Letter from Employer%' THEN 'mother_letter_of_employment'
        WHEN dtp.`label` LIKE '%Passport photo%' OR dtp.`label` LIKE '%Passport size photo%' OR dtp.`label` LIKE '%Passport-size Photograph%' AND NOT (dtp.`fk_parent` IS NOT NULL OR dtp.`fk_registration_parent` IS NOT NULL OR dtp.`fk_ecda_registration_parent` IS NOT NULL OR dtp.`fk_registration_family_member` IS NOT NULL) THEN 'passport_sized_photo_of_child'
        -- WHEN dtp.`label` LIKE '%Employment Letter from Employer%' and  THEN 'mother_letter_of_employment'
        ELSE 'others'
    END AS `document_category`,
	dtp.`label` AS document_label, dc.filename AS document_filename, dc.`url` AS document_source_path
    , CASE
		WHEN pr.`id` IS NOT NULL THEN TRIM(CONCAT(IFNULL(pr.`firstname`, ''), ' ', IFNULL(pr.`lastname`, '')))
		WHEN rp.`id` IS NOT NULL THEN TRIM(CONCAT(IFNULL(rp.`firstname`, ''), ' ', IFNULL(rp.`lastname`, '')))
        WHEN erp.`id` IS NOT NULL THEN TRIM(erp.`fullname`)
        WHEN rfm.`id` IS NOT NULL THEN TRIM(CONCAT(IFNULL(rfm.`firstname`, ''), ' ', IFNULL(rfm.`lastname`, '')))
        -- WHEN doc_user.`id` IS NOT NULL THEN TRIM(CONCAT(IFNULL(doc_user.`firstname`, ''), ' ', IFNULL(doc_user.`lastname`, '')))
        ELSE TRIM(CONCAT(IFNULL(ch.`firstname`, ''), ' ', IFNULL(ch.`lastname`, '')))
    END AS `document_owner`
    , IFNULL(TRIM(CONCAT(IFNULL(usr.`firstname`, ''), ' ', usr.`lastname`)), '') AS `uploaded_by`
    , dtp.created_at, dtp.updated_at
    , IFNULL(dtp.`fk_bank_account`, '') AS `giro_account_id`, IFNULL(ba.`bill_reference_number`, '') AS `giro_account_reference_number`
FROM 
(
SELECT cl.fk_child, min(cl.`from`) AS earliest_from
FROM child_level cl
WHERE
	cl.fk_centre IN (1, 5, 10, 18, 16, 20)
    AND
	(cl.`to` IS NULL OR cl.`to` >= CURRENT_TIMESTAMP)
    AND
	cl.`active` = 1
GROUP BY cl.fk_child
) active_child
	INNER JOIN child ch ON ch.id = active_child.fk_child
		AND ch.`active` = 1
	INNER JOIN document_type dtp ON dtp.fk_child = ch.id AND dtp.`active` = 1
	INNER JOIN document_tag dtg ON dtg.fk_document_type = dtp.id AND dtg.`active` = 1
    INNER JOIN document dc ON dc.id = dtg.fk_document AND dc.`active` = 1
    LEFT OUTER JOIN `user` usr ON usr.`id` = dc.`uploaded_by`
    LEFT OUTER JOIN `parent` pr ON pr.`id` = dtp.`fk_parent`
    LEFT OUTER JOIN `user` doc_user ON doc_user.`id` = dtp.`fk_user`
    LEFT OUTER JOIN `registration_parent` rp ON rp.`id` = dtp.`fk_registration_parent`
    LEFT OUTER JOIN `ecda_registration_parent` erp ON erp.`id` = dtp.`fk_ecda_registration_parent`
    LEFT OUTER JOIN `registration_family_member` rfm ON rfm.`id` = dtp.`fk_registration_family_member`
    LEFT OUTER JOIN `bank_account` ba ON ba.`id` = dtp.`fk_bank_account` AND ba.`active` = 1
  ;