select 
	-- child_ec.`id` as ec_id, child_ec.`value` AS `ec_val`,
	filtered_data.id, filtered_data.`child_firstname`, filtered_data.`child_lastname`, filtered_data.`child_birth_certificate`, 
    filtered_data.`date_of_birth`, filtered_data.`gender`, filtered_data.`race`, filtered_data.`nationality`, filtered_data.`profile_photo_storage_path`,
    cl.`from` AS `current_level_enrolment_date`, cnt.`code` AS `current_centre_code`, lv.`code` AS `current_level`, prg.`code` AS `current_program`,
    cc.`from` AS `current_class_enrolment_date`, cls.`id` AS `current_class_id`, cls.`label` AS `current_class_name`,
    -- (select ccl.`from` FROM `child_level` ccl WHERE ccl.`fk_child` = filtered_data.id AND ccl.`fk_centre` = cl.`fk_centre` AND ccl.`active` = 1 ORDER BY ccl.`from` ASC LIMIT 1) AS `current_centre_enrolment_date`,
    filtered_data.`first_enrolment_date` AS `current_centre_enrolment_date`,
    filtered_data.`parent_one_id`, filtered_data.`parent_one_relation`, filtered_data.`parent_one_firstname`, filtered_data.`parent_one_lastname`, filtered_data.`parent_one_nric`, filtered_data.`parent_one_email`,  filtered_data.`parent_one_mobile_number`, filtered_data.`parent_one_home_phone`,
    filtered_data.`parent_one_date_of_birth`, filtered_data.`parent_one_nationality`, filtered_data.`parent_one_race`, filtered_data.`parent_one_marital_status`, filtered_data.`parent_one_qualification`,
    -- filtered_data.`parent_one_occupation` AS `parent_one_occupation_org`, 
    IFNULL((select cde.`description` from `code` cde where cde.`fk_school` = 2 and cde.fk_code in (157, 4917) AND cde.`label` = filtered_data.`parent_one_occupation` AND cde.`active` = 1 LIMIT 1), filtered_data.`parent_one_occupation`) AS `parent_one_occupation`,
    filtered_data.`parent_one_working_status`, filtered_data.`parent_one_workplace_association`, filtered_data.`parent_one_pr_commencement_date`, 
    filtered_data.`parent_two_id`, filtered_data.`parent_two_relation`, filtered_data.`parent_two_firstname`, filtered_data.`parent_two_lastname`, filtered_data.`parent_two_nric`, filtered_data.`parent_two_email`,  filtered_data.`parent_two_mobile_number`, filtered_data.`parent_two_home_phone`,
    filtered_data.`parent_two_date_of_birth`, filtered_data.`parent_two_nationality`, filtered_data.`parent_two_race`, filtered_data.`parent_two_marital_status`, filtered_data.`parent_two_qualification`,
    -- filtered_data.`parent_two_occupation` AS `parent_two_occupation_org`, 
    IFNULL((select cde.`description` from `code` cde where cde.`fk_school` = 2 and cde.fk_code in (157, 4917) AND cde.`label` = filtered_data.`parent_two_occupation` AND cde.`active` = 1 LIMIT 1), filtered_data.`parent_two_occupation`) AS `parent_two_occupation`,
    filtered_data.`parent_two_working_status`, filtered_data.`parent_two_pr_commencement_date`, 
    filtered_data.`address_postal_code`, filtered_data.`address_city`, filtered_data.`address_country`, filtered_data.`address_line_1`,filtered_data.`address_block`, filtered_data.`address_floor`, filtered_data.`address_unit_no`,
    IF(wd.`id` is not null, wd.`effective_date`, IF(tnr.`id` is not null AND tnr.destination_centre NOT in (1, 5, 10, 18, 16, 20), tnr.`effective_date`, '')) AS `withdrawal_effective_date`,
    IF(tnr.`id` is not null AND tnr.destination_centre in (1, 5, 10, 18, 16, 20), tnr.`effective_date`, '') AS `transfer_effective_date`,
    IF(tnr.`id` is not null AND tnr.destination_centre in (1, 5, 10, 18, 16, 20) and tnr_destination_centre.`id` is not null, tnr_destination_centre.`code`, '') AS `transfer_destination_centre_code`
    , filtered_data.`created_at`, filtered_data.`updated_at`
    
    -- Emergency contact (START)
    , IF(LENGTH(TRIM(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_ec.`value`, '$.LastName')), ''))) > 1, TRIM(CONCAT(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_ec.`value`, '$.FirstName')), ''), ' ', IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_ec.`value`, '$.LastName')), ''))), TRIM(CONCAT(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_ec.`value`, '$.firstName')), ''), ' ', IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_ec.`value`, '$.lastName')), '')))) AS `emergency_contact_name`
    , IF(LENGTH(TRIM(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_ec.`value`, '$.LastName')), ''))) > 1, IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_ec.`value`, '$.IdentificationNo')), ''), IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_ec.`value`, '$.identificationNo')), '')) AS `emergency_contact_identification_no`
    , IF(LENGTH(TRIM(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_ec.`value`, '$.LastName')), ''))) > 1, IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_ec.`value`, '$.PostalCode')), ''), IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_ec.`value`, '$.postalCode')), '')) AS `emergency_contact_address_postal_code`
    , IF(LENGTH(TRIM(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_ec.`value`, '$.LastName')), ''))) > 1, IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_ec.`value`, '$.Address')), ''), IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_ec.`value`, '$.address')), '')) AS `emergency_contact_address_line_1`
    , IF(LENGTH(TRIM(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_ec.`value`, '$.LastName')), ''))) > 1, IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_ec.`value`, '$.FloorNo')), ''), IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_ec.`value`, '$.floorNo')), '')) AS `emergency_contact_address_floor_no`
    , IF(LENGTH(TRIM(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_ec.`value`, '$.LastName')), ''))) > 1, IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_ec.`value`, '$.UnitNo')), ''), IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_ec.`value`, '$.unitNo')), '')) AS `emergency_contact_address_unit_no`
    , IF(LENGTH(TRIM(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_ec.`value`, '$.LastName')), ''))) > 1, IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_ec.`value`, '$.BlockNo')), ''), IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_ec.`value`, '$.blockNo')), '')) AS `emergency_contact_address_block_no`
    , IF(LENGTH(TRIM(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_ec.`value`, '$.LastName')), ''))) > 1, IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_ec.`value`, '$.Email')), ''), IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_ec.`value`, '$.email')), '')) AS `emergency_contact_email`
    , IF(LENGTH(TRIM(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_ec.`value`, '$.LastName')), ''))) > 1, IFNULL(CONCAT(JSON_UNQUOTE(JSON_EXTRACT(child_ec.`value`, '$.MobilePhoneCC')), JSON_UNQUOTE(JSON_EXTRACT(child_ec.`value`, '$.MobilePhone'))), ''), IFNULL(CONCAT(JSON_UNQUOTE(JSON_EXTRACT(child_ec.`value`, '$.mobilePhoneCC')), JSON_UNQUOTE(JSON_EXTRACT(child_ec.`value`, '$.mobilePhone'))), '')) AS `emergency_contact_mobile_phone`
    , IF(LENGTH(TRIM(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_ec.`value`, '$.LastName')), ''))) > 1, IFNULL(IF(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_ec.`value`, '$.Relationship')), '') != '', (SELECT `description` FROM `code` cde WHERE cde.`id` = JSON_UNQUOTE(JSON_EXTRACT(child_ec.`value`, '$.Relationship')) LIMIT 1), ''), ''), IFNULL(IF(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_ec.`value`, '$.relationship')), '') != '', (SELECT `description` FROM `code` cde WHERE cde.`id` = JSON_UNQUOTE(JSON_EXTRACT(child_ec.`value`, '$.relationship')) LIMIT 1), ''), '')) AS `emergency_contact_relationship`
    -- Emergency contact (END)
    
    -- Medical history Family doctor (START)
    , IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, '$.familyDoctorDetails.clinicName')), '') AS `family_doctor_clinic_name`
    , IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, '$.familyDoctorDetails.name')), '') AS `family_doctor_name`
    , IF(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, '$.familyDoctorDetails.email')), 'null') NOT IN ('', 'null'), JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, '$.familyDoctorDetails.email')), '') AS `family_doctor_email`
    , IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, '$.familyDoctorDetails.contactNumber')), '') AS `family_doctor_contact_no`
    , IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, '$.familyDoctorDetails.clinicUnit')), '') AS `family_doctor_clinic_unit_no`
    , IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, '$.familyDoctorDetails.clinicFloor')), '') AS `family_doctor_clinic_floor_no`
    , IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, '$.familyDoctorDetails.clinicBlockNo')), '') AS `family_doctor_clinic_block_no`
    , IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, '$.familyDoctorDetails.clinicBuilding')), '') AS `family_doctor_clinic_address_1`
    , IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, '$.familyDoctorDetails.clinicPostalCode')), '') AS `family_doctor_clinic_postal_code`
    , IF(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, '$.familyDoctorDetails.remarks')), 'null') NOT IN ('', 'null'), JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, '$.familyDoctorDetails.remarks')), '') AS `family_doctor_remarks`
    -- Medical history Family doctor  (END)
    -- Medical history Immunizations  (START)
    , IF(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, '$.immunizations.isImmunized')), '') = 'true', 'Yes', 'No') AS `is_immunized`
    , IF(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, REPLACE(JSON_UNQUOTE(JSON_SEARCH(child_medical_history.`value`, 'one', 'bcg', NULL, '$.immunizations.immunizationDetails')), 'disease', 'exists'))), '') = 'true', 'Yes', 'No') AS `bcg`
    , IF(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, REPLACE(JSON_UNQUOTE(JSON_SEARCH(child_medical_history.`value`, 'one', 'hep_b', NULL, '$.immunizations.immunizationDetails')), 'disease', 'exists'))), '') = 'true', 'Yes', 'No') AS `hep_b`
    , IF(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, REPLACE(JSON_UNQUOTE(JSON_SEARCH(child_medical_history.`value`, 'one', 'ipv', NULL, '$.immunizations.immunizationDetails')), 'disease', 'exists'))), '') = 'true', 'Yes', 'No') AS `ipv`
    , IF(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, REPLACE(JSON_UNQUOTE(JSON_SEARCH(child_medical_history.`value`, 'one', 'hib', NULL, '$.immunizations.immunizationDetails')), 'disease', 'exists'))), '') = 'true', 'Yes', 'No') AS `hib`
    , IF(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, REPLACE(JSON_UNQUOTE(JSON_SEARCH(child_medical_history.`value`, 'one', 'pcv10', NULL, '$.immunizations.immunizationDetails')), 'disease', 'exists'))), '') = 'true', 'Yes', 'No') AS `pcv10`
    , IF(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, REPLACE(JSON_UNQUOTE(JSON_SEARCH(child_medical_history.`value`, 'one', 'var', NULL, '$.immunizations.immunizationDetails')), 'disease', 'exists'))), '') = 'true', 'Yes', 'No') AS `var`
    , IF(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, REPLACE(JSON_UNQUOTE(JSON_SEARCH(child_medical_history.`value`, 'one', 'inf', NULL, '$.immunizations.immunizationDetails')), 'disease', 'exists'))), '') = 'true', 'Yes', 'No') AS `inf`
    , IF(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, REPLACE(JSON_UNQUOTE(JSON_SEARCH(child_medical_history.`value`, 'one', 'dtap_1d', NULL, '$.immunizations.immunizationDetails')), 'disease', 'exists'))), '') = 'true', 'Yes', 'No') AS `dtap_1d`
    , IF(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, REPLACE(JSON_UNQUOTE(JSON_SEARCH(child_medical_history.`value`, 'one', 'dtap_2d', NULL, '$.immunizations.immunizationDetails')), 'disease', 'exists'))), '') = 'true', 'Yes', 'No') AS `dtap_2d`
    , IF(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, REPLACE(JSON_UNQUOTE(JSON_SEARCH(child_medical_history.`value`, 'one', 'dtap_3d', NULL, '$.immunizations.immunizationDetails')), 'disease', 'exists'))), '') = 'true', 'Yes', 'No') AS `dtap_3d`
    , IF(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, REPLACE(JSON_UNQUOTE(JSON_SEARCH(child_medical_history.`value`, 'one', 'dtap_18m', NULL, '$.immunizations.immunizationDetails')), 'disease', 'exists'))), '') = 'true', 'Yes', 'No') AS `dtap_18m`
    , IF(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, REPLACE(JSON_UNQUOTE(JSON_SEARCH(child_medical_history.`value`, 'one', 'mmr_1d', NULL, '$.immunizations.immunizationDetails')), 'disease', 'exists'))), '') = 'true', 'Yes', 'No') AS `mmr_1d`
    , IF(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, REPLACE(JSON_UNQUOTE(JSON_SEARCH(child_medical_history.`value`, 'one', 'mmr_2d', NULL, '$.immunizations.immunizationDetails')), 'disease', 'exists'))), '') = 'true', 'Yes', 'No') AS `mmr_2d`
    -- Medical history Immunizations  (END)
    -- Medical history physical conditions (START)
    , IF(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, REPLACE(JSON_UNQUOTE(JSON_SEARCH(child_medical_history.`value`, 'one', 'fits', NULL, '$.physicalConditions.medicalConditions')), 'disease', 'exists'))), '') = 'true', 'Yes', 'No') AS `physical_condition_fits`
    , IF(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, REPLACE(JSON_UNQUOTE(JSON_SEARCH(child_medical_history.`value`, 'one', 'asthma', NULL, '$.physicalConditions.medicalConditions')), 'disease', 'exists'))), '') = 'true', 'Yes', 'No') AS `physical_condition_asthma`
    , IF(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, REPLACE(JSON_UNQUOTE(JSON_SEARCH(child_medical_history.`value`, 'one', 'diabetes', NULL, '$.physicalConditions.medicalConditions')), 'disease', 'exists'))), '') = 'true', 'Yes', 'No') AS `physical_condition_diabetes`
    , IF(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, REPLACE(JSON_UNQUOTE(JSON_SEARCH(child_medical_history.`value`, 'one', 'hepatitis_b', NULL, '$.physicalConditions.medicalConditions')), 'disease', 'exists'))), '') = 'true', 'Yes', 'No') AS `physical_condition_hepatitis_b`
    , IF(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, REPLACE(JSON_UNQUOTE(JSON_SEARCH(child_medical_history.`value`, 'one', 'hepatitis_a', NULL, '$.physicalConditions.medicalConditions')), 'disease', 'exists'))), '') = 'true', 'Yes', 'No') AS `physical_condition_hepatitis_a`
    , IF(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, REPLACE(JSON_UNQUOTE(JSON_SEARCH(child_medical_history.`value`, 'one', 'others', NULL, '$.physicalConditions.medicalConditions')), 'disease', 'exists'))), '') = 'true', 'Yes', 'No') AS `physical_condition_others`
    , IF(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, '$.physicalConditions.medicalConditionRemarks')), 'null') NOT IN ('', 'null'), JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, '$.physicalConditions.medicalConditionRemarks')), '') AS `physical_condition_remarks`
    -- Medical history physical conditions (END)
    -- Medical history special needs (START)
    , IF(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, REPLACE(JSON_UNQUOTE(JSON_SEARCH(child_medical_history.`value`, 'one', 'adhd', NULL, '$.specialNeeds.medicalConditions')), 'disease', 'exists'))), '') = 'true', 'Yes', 'No') AS `special_needs_adhd`
    , IF(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, REPLACE(JSON_UNQUOTE(JSON_SEARCH(child_medical_history.`value`, 'one', 'autism', NULL, '$.specialNeeds.medicalConditions')), 'disease', 'exists'))), '') = 'true', 'Yes', 'No') AS `special_needs_autism`
    , IF(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, REPLACE(JSON_UNQUOTE(JSON_SEARCH(child_medical_history.`value`, 'one', 'auditory issues', NULL, '$.specialNeeds.medicalConditions')), 'disease', 'exists'))), '') = 'true', 'Yes', 'No') AS `special_needs_auditory_issues`
    , IF(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, REPLACE(JSON_UNQUOTE(JSON_SEARCH(child_medical_history.`value`, 'one', 'dyslexia', NULL, '$.specialNeeds.medicalConditions')), 'disease', 'exists'))), '') = 'true', 'Yes', 'No') AS `special_needs_dyslexia`
    , IF(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, REPLACE(JSON_UNQUOTE(JSON_SEARCH(child_medical_history.`value`, 'one', 'down_syndrome', NULL, '$.specialNeeds.medicalConditions')), 'disease', 'exists'))), '') = 'true', 'Yes', 'No') AS `special_needs_down_syndrome`
    , IF(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, REPLACE(JSON_UNQUOTE(JSON_SEARCH(child_medical_history.`value`, 'one', 'global_development_delay', NULL, '$.specialNeeds.medicalConditions')), 'disease', 'exists'))), '') = 'true', 'Yes', 'No') AS `special_needs_global_development_delay`
    , IF(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, REPLACE(JSON_UNQUOTE(JSON_SEARCH(child_medical_history.`value`, 'one', 'others', NULL, '$.specialNeeds.medicalConditions')), 'disease', 'exists'))), '') = 'true', 'Yes', 'No') AS `special_needs_others`
    , IF(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, '$.specialNeeds.medicalConditionRemarks')), 'null') NOT IN ('', 'null'), JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, '$.specialNeeds.medicalConditionRemarks')), '') AS `special_needs_remarks`
    -- Medical history special needs (END)
    -- Medical history food allergies (START)
    , IF(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, REPLACE(JSON_UNQUOTE(JSON_SEARCH(child_medical_history.`value`, 'one', 'dairy', NULL, '$.foodAllergies.medicalConditions')), 'disease', 'exists'))), '') = 'true', 'Yes', 'No') AS `food_allergies_dairy`
    , IF(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, REPLACE(JSON_UNQUOTE(JSON_SEARCH(child_medical_history.`value`, 'one', 'nuts', NULL, '$.foodAllergies.medicalConditions')), 'disease', 'exists'))), '') = 'true', 'Yes', 'No') AS `food_allergies_nuts`
    , IF(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, REPLACE(JSON_UNQUOTE(JSON_SEARCH(child_medical_history.`value`, 'one', 'eggs', NULL, '$.foodAllergies.medicalConditions')), 'disease', 'exists'))), '') = 'true', 'Yes', 'No') AS `food_allergies_eggs`
    , IF(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, REPLACE(JSON_UNQUOTE(JSON_SEARCH(child_medical_history.`value`, 'one', 'mushrooms', NULL, '$.foodAllergies.medicalConditions')), 'disease', 'exists'))), '') = 'true', 'Yes', 'No') AS `food_allergies_mushrooms`
    , IF(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, REPLACE(JSON_UNQUOTE(JSON_SEARCH(child_medical_history.`value`, 'one', 'gluten', NULL, '$.foodAllergies.medicalConditions')), 'disease', 'exists'))), '') = 'true', 'Yes', 'No') AS `food_allergies_gluten`
    , IF(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, REPLACE(JSON_UNQUOTE(JSON_SEARCH(child_medical_history.`value`, 'one', 'fish', NULL, '$.foodAllergies.medicalConditions')), 'disease', 'exists'))), '') = 'true', 'Yes', 'No') AS `food_allergies_fish`
    , IF(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, REPLACE(JSON_UNQUOTE(JSON_SEARCH(child_medical_history.`value`, 'one', 'others', NULL, '$.foodAllergies.medicalConditions')), 'disease', 'exists'))), '') = 'true', 'Yes', 'No') AS `food_allergies_others`
    , IF(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, '$.foodAllergies.medicalConditionRemarks')), 'null') NOT IN ('', 'null'), JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, '$.foodAllergies.medicalConditionRemarks')), '') AS `food_allergies_remarks`
    -- Medical history food allergies (END)
    -- Medical history non-food allergies (START)
    , IF(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, REPLACE(JSON_UNQUOTE(JSON_SEARCH(child_medical_history.`value`, 'one', 'pollen', NULL, '$.nonFoodAllergies.medicalConditions')), 'disease', 'exists'))), '') = 'true', 'Yes', 'No') AS `non_food_allergies_pollen`
    , IF(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, REPLACE(JSON_UNQUOTE(JSON_SEARCH(child_medical_history.`value`, 'one', 'others', NULL, '$.nonFoodAllergies.medicalConditions')), 'disease', 'exists'))), '') = 'true', 'Yes', 'No') AS `non_food_allergies_others`
    , IF(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, '$.nonFoodAllergies.medicalConditionRemarks')), 'null') NOT IN ('', 'null'), JSON_UNQUOTE(JSON_EXTRACT(child_medical_history.`value`, '$.nonFoodAllergies.medicalConditionRemarks')), '') AS `non_food_allergies_remarks`
    -- Medical history non-food allergies (END)
from (
select 
	distinct
	ch.id, ch.firstname as `child_firstname`, ch.lastname as `child_lastname`, ch.`birth_certificate` AS `child_birth_certificate`, 
    ch.date_of_birth, ch.gender, ch.race, ch.nationality, 
    ch.`image_key` AS `profile_photo_storage_path`,
    ch.`first_enrolment_date`,
    ch.created_at, ch.updated_at,
	-- active_child.`earliest_from`, ch.*, 
    -- cr_mother.*, 
    cr_mother_code.`description` AS `parent_one_relation`,
    pr_mother.`id` AS `parent_one_id`, pr_mother.firstname as `parent_one_firstname`, pr_mother.lastname as `parent_one_lastname`, pr_mother.identification_no as `parent_one_nric`, pr_mother.`email` as `parent_one_email`, 
		pr_mother.mobile_phone as `parent_one_mobile_number`, usr_mother.home_phone as `parent_one_home_phone`, pr_mother.`birthdate` as `parent_one_date_of_birth`, pr_mother.`nationality` as `parent_one_nationality`, 
        pr_mother.`race` as `parent_one_race`, pr_mother.`marital_status` as `parent_one_marital_status` , pr_mother.`highest_qualification` as `parent_one_qualification`, 
        pr_mother.`occupational_title` as `parent_one_occupation`,
		pr_mother.`working_status` AS `parent_one_working_status`,
        IFNULL(code_mother_workplace_staff.`description`, '') AS `parent_one_workplace_association`,
        pr_mother.`permanent_residence_start_date` AS `parent_one_pr_commencement_date`,
    cr_father_code.`description` AS `parent_two_relation`,
    pr_father.`id` AS `parent_two_id`, pr_father.firstname as `parent_two_firstname`, pr_father.lastname as `parent_two_lastname`, pr_father.identification_no as `parent_two_nric`, pr_father.`email` as `parent_two_email`, 
		pr_father.mobile_phone as `parent_two_mobile_number`, usr_father.home_phone as `parent_two_home_phone`, pr_father.`birthdate` as `parent_two_date_of_birth`, pr_father.`nationality` as `parent_two_nationality`, 
        pr_father.`race` as `parent_two_race`, pr_father.`marital_status` as `parent_two_marital_status` , pr_father.`highest_qualification` as `parent_two_qualification`, pr_father.`occupational_title` as `parent_two_occupation`,
		pr_father.`working_status` AS `parent_two_working_status`,
        pr_father.`permanent_residence_start_date` AS `parent_two_pr_commencement_date`,
        IF(IFNULL(IF(adr_mother.`id` is not null, adr_mother.`city`, adr_father.`city`), '') = '', 'Singapore', IF(adr_mother.`id` is not null, adr_mother.`city`, adr_father.`city`)) as `address_city`, 
        IF(IFNULL(IF(adr_mother.`id` is not null, adr_mother.`country`, adr_father.`country`), '') = '', 'Singapore', IF(adr_mother.`id` is not null, adr_mother.`country`, adr_father.`country`)) as `address_country`, 
        IF(adr_mother.`id` is not null, adr_mother.`address`, adr_father.`address`) as `address_line_1`, 
        IF(adr_mother.`id` is not null, adr_mother.`postcode`, adr_father.`postcode`) AS `address_postal_code`, 
        IF(adr_mother.`id` is not null, adr_mother.`building`, adr_father.`building`) AS `address_block`, 
        IF(adr_mother.`id` is not null, adr_mother.`floor`, adr_father.`floor`) AS `address_floor`, 
        IF(adr_mother.`id` is not null, adr_mother.`unit`, adr_father.`unit`) AS `address_unit_no`
	,
    (SELECT cl.`id` FROM `child_level` cl WHERE cl.`fk_child` = ch.`id` AND cl.`from` = active_child.`earliest_from` AND (cl.`to` is null or cl.`to` >= current_timestamp) AND cl.`active` = 1 limit 1) AS `current_enrolled_child_level_id`,
    (SELECT cc.`id` FROM `child_class` cc WHERE cc.`fk_child` = ch.`id` AND (cc.`to` is null or cc.`to` >= current_timestamp) AND cc.`active` = 1 limit 1) AS `current_enrolled_child_class_id`,
    (SELECT wd.`id` FROM `withdrawal` wd WHERE wd.`fk_child` = ch.`id` AND wd.`effective_date` >= current_timestamp AND wd.`active` = 1 limit 1) `upcoming_withdrawal_id`,
    (SELECT wd.`id` FROM `transfer` wd WHERE wd.`fk_child` = ch.`id` AND wd.`effective_date` >= current_timestamp AND wd.`active` = 1 limit 1) `upcoming_transfer_id`
from (
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
	left outer join child_relation cr_mother ON cr_mother.fk_child = active_child.fk_child
		and cr_mother.`type` = 'applicant'
		and cr_mother.`active` = 1
	left outer join `code` cr_mother_code ON cr_mother_code.`id` = cr_mother.`fk_relation`
	left outer join parent pr_mother ON pr_mother.id = cr_mother.fk_parent
		AND pr_mother.`active` = 1
	left outer join `user` usr_mother ON usr_mother.id = pr_mother.fk_user
		AND usr_mother.`active` = 1
	left outer join child_relation cr_father ON cr_father.fk_child = active_child.fk_child
		and cr_father.`type` = 'second_applicant'
		and cr_father.`active` = 1
	left outer join `code` cr_father_code ON cr_father_code.`id` = cr_father.`fk_relation`
	left outer join parent pr_father ON pr_father.id = cr_father.fk_parent
		AND pr_father.`active` = 1
	left outer join `user` usr_father ON usr_father.id = pr_father.fk_user
		AND usr_father.`active` = 1
	left outer join `address` adr_mother ON adr_mother.`fk_parent` = pr_mother.`id` and adr_mother.`active` = 1
    left outer join `address` adr_father ON adr_father.`fk_parent` = pr_mother.`id` and adr_father.`active` = 1
    left outer join `code` code_mother_workplace_staff ON code_mother_workplace_staff.`label` = pr_mother.`workplace_staff`
		AND code_mother_workplace_staff.`fk_school` = 2
        AND code_mother_workplace_staff.`fk_code` = '3510'
) filtered_data
	inner join `child_level` cl ON cl.`id` = filtered_data.`current_enrolled_child_level_id` AND cl.`active` = 1
    inner join `level` lv ON lv.`id` = cl.`fk_level`  AND lv.`active` = 1
    inner join `program` prg ON prg.`id` = cl.`fk_program`  AND lv.`active` = 1
    inner join `centre` cnt on cnt.`id` = cl.`fk_centre`
    left outer join `child_class` cc ON cc.`id` = filtered_data.`current_enrolled_child_class_id` AND cc.`active` = 1
    left outer join `class` cls on cls.`id` = cc.`fk_class` AND cls.`fk_centre` = cnt.`id` AND cls.`active` = 1
    left outer join `withdrawal` wd ON wd.`id` = filtered_data.`upcoming_withdrawal_id`
    left outer join `transfer` tnr ON tnr.`id` = filtered_data.`upcoming_transfer_id`
    left outer join `centre` tnr_destination_centre ON tnr_destination_centre.`id` = tnr.`destination_centre` 
    left outer join `child_attribute` child_medical_history ON child_medical_history.`fk_child` = filtered_data.`id` AND child_medical_history.`fk_code` = 2013 AND child_medical_history.`active`= 1
    left outer join `child_attribute` child_ec ON child_ec.`fk_child` = filtered_data.`id` AND child_ec.`fk_code` = 3796 AND child_ec.`active`= 1
;