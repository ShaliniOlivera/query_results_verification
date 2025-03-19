select ch.id, ch.fullname, ch.birth_certificate, 
    dtp.id AS dt_id,
    CASE
		WHEN dtp.`label` LIKE '%Birth Certificate%' THEN 'birth_certificate'
        WHEN dtp.`label` LIKE '%Immmunization%' OR dtp.`label` LIKE '%Immunisation%' THEN 'vaccination_immunisation_record'
        WHEN dtp.`label` LIKE '%guardian%' AND dtp.`label` LIKE '%NRIC%' THEN 'ic_of_authorized_pickups'
        WHEN dtp.`label` LIKE '%NRIC%' AND dtp.`fk_registration_family_member` is null AND (dtp.`fk_parent` is not null or dtp.`fk_registration_parent` is not null or dtp.`fk_ecda_registration_parent` is not null) THEN 'parents_id'
        -- WHEN dtp.`label` LIKE '%Enrolment supporting documents%' OR dtp.`label` LIKE '%Enrollment supporting documents%' THEN 'Enrolment supporting documents'
        WHEN dtp.`label` LIKE '%Employment Letter from Employer%' THEN 'mother_letter_of_employment'
        WHEN dtp.`label` LIKE '%Passport photo%' OR dtp.`label` LIKE '%Passport size photo%' OR dtp.`label` LIKE '%Passport-size Photograph%' AND NOT (dtp.`fk_parent` is not null or dtp.`fk_registration_parent` is not null or dtp.`fk_ecda_registration_parent` is not null or dtp.`fk_registration_family_member` is not null) THEN 'passport_sized_photo_of_child'
        -- WHEN dtp.`label` LIKE '%Employment Letter from Employer%' and  THEN 'mother_letter_of_employment'
        ELSE 'others'
    END AS `document_category`,
	dtp.`label` as document_label, dc.filename as document_filename, dc.`url` as document_source_path
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
from 
(
select cl.fk_child, min(cl.`from`) as earliest_from
from child_level cl
where
	cl.fk_centre in (1, 5, 10, 18, 16, 20)
    and
	(cl.`to` is null or cl.`to` >= current_timestamp)
    and
	cl.`active` = 1
group by cl.fk_child
) active_child
	inner join child ch on ch.id = active_child.fk_child
		and ch.`active` = 1
	inner join document_type dtp on dtp.fk_child = ch.id AND dtp.`active` = 1
	inner join document_tag dtg on dtg.fk_document_type = dtp.id AND dtg.`active` = 1
    inner join document dc on dc.id = dtg.fk_document AND dc.`active` = 1
    left outer join `user` usr ON usr.`id` = dc.`uploaded_by`
    left outer join `parent` pr ON pr.`id` = dtp.`fk_parent`
    left outer join `user` doc_user ON doc_user.`id` = dtp.`fk_user`
    left outer join `registration_parent` rp ON rp.`id` = dtp.`fk_registration_parent`
    left outer join `ecda_registration_parent` erp ON erp.`id` = dtp.`fk_ecda_registration_parent`
    left outer join `registration_family_member` rfm ON rfm.`id` = dtp.`fk_registration_family_member`
    left outer join `bank_account` ba ON ba.`id` = dtp.`fk_bank_account` AND ba.`active` = 1
  ;