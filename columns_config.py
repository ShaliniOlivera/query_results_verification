columns_to_verify = {
    #child details
    ('qa_child_details.sql', 'dev_child_profile.sql'): [
        "id", "child_firstname", "child_lastname", "child_birth_certificate",
        "date_of_birth", "gender", "race", "nationality", "profile_photo_storage_path", "current_level_enrolment_date",
        "current_centre_code", "current_level", "current_program", "current_class_enrolment_date", "current_class_id", "current_class_name",
        "withdrawal_effective_date", "transfer_effective_date", "transfer_destination_centre_code", "current_centre_enrolment_date", 
        "created_at","updated_at"                                                                
     ],  
    #parent details
    ('qa_parent_details.sql', 'dev_child_profile.sql'): [
         "parent_one_id", "parent_one_relation", "parent_one_firstname", "parent_one_lastname",
        "parent_one_nric", "parent_one_email", "parent_one_mobile_number", "parent_one_home_phone",
        "parent_one_date_of_birth", "parent_one_nationality", "parent_one_race", "parent_one_marital_status",
        "parent_one_qualification", "parent_one_occupation", "parent_one_working_status", "parent_one_workplace_association",
        "parent_one_pr_commencement_date", "parent_two_id", "parent_two_relation", "parent_two_firstname",
        "parent_two_lastname", "parent_two_nric", "parent_two_email", "parent_two_mobile_number", "parent_two_home_phone",
        "parent_two_date_of_birth", "parent_two_nationality", "parent_two_race", "parent_two_e_marital_status",
        "parent_two_qualification", "parent_two_occupation", "parent_two_working_status", "parent_two_pr_commencement_date",
        "address_postal_code", "address_city", "address_country", "address_line_1", "address_block", "address_floor", "address_unit_no"
    ],
    
    #child emergency details
    ('qa_child_attributes.sql', 'dev_child_profile.sql'): [
        "id", "emergency_contact_name", "emergency_contact_identification_no", "emergency_contact_address_postal_code",
        "emergency_contact_address_line_1", "emergency_contact_address_floor_no", "emergency_contact_address_unit_no",
        "emergency_contact_address_block_no", "emergency_contact_email", "emergency_contact_mobile_phone", "emergency_contact_relationship"                                                   
    ],
    
    #child doctor details
    ('qa_doctor_details.sql', 'dev_child_profile.sql'): [
        "id", "family_doctor_clinic_name", "family_doctor_name", "family_doctor_email", "family_doctor_contact_no", "family_doctor_clinic_unit_no",
        "family_doctor_clinic_floor_no", "family_doctor_clinic_block_no", "family_doctor_clinic_address_1", "family_doctor_clinic_postal_code",
        "family_doctor_remarks"
    ],
    
    #child medical records
    ('qa_medical_records.sql', 'dev_child_profile.sql'): [
        "id", "is_immunized", "bcg", "hep_b", "ipv", "hib", "pcv10", "var", "inf", "dtap_1d", "dtap_2d", "dtap_3d", "dtap_18m", "mmr_1d", "mmr_2d", 
        "physical_condition_fits", "physical_condition_asthma", "physical_condition_diabetes", "physical_condition_hepatitis_b", 
        "physical_condition_hepatitis_a", "physical_condition_others", "physical_condition_remarks", "special_needs_adhd", "special_needs_autism", 
        "special_needs_auditory_issues", "special_needs_dyslexia", "special_needs_down_syndrome", "special_needs_global_development_delay", 
        "special_needs_others", "special_needs_remarks", "food_allergies_dairy", "food_allergies_nuts", "food_allergies_eggs", 
        "food_allergies_mushrooms", "food_allergies_gluten", "food_allergies_fish", "food_allergies_others", "food_allergies_remarks", 
        "non_food_allergies_pollen", "non_food_allergies_others", "non_food_allergies_remarks"
    ],
    
    #child immunization records
    ('qa_immunization.sql', 'dev_child_profile.sql'): [
        "id", "is_immunized", "bcg", "hep_b", "ipv", "hib", "pcv10", "var", "inf", "dtap_1d", "dtap_2d", "dtap_3d", "dtap_18m", "mmr_1d", "mmr_2d"
    ],
    
    #child physical conditions
    ('qa_physicalConditions.sql', 'dev_child_profile.sql'): [
        "id", "physical_condition_fits", "physical_condition_asthma", "physical_condition_diabetes", "physical_condition_hepatitis_b", 
        "physical_condition_hepatitis_a", "physical_condition_others", "physical_condition_remarks"
    ],
    
    #child special needs
    ('qa_specialNeeds.sql', 'dev_child_profile.sql'): [
        "id", "special_needs_adhd", "special_needs_autism", "special_needs_auditory_issues", "special_needs_dyslexia", 
        "special_needs_down_syndrome", "special_needs_global_development_delay", "special_needs_others", "special_needs_remarks"
    ],
    
    #child food allergies
    ('qa_foodAllergies.sql', 'dev_child_profile.sql'): [
        "food_allergies_dairy", "food_allergies_nuts", "food_allergies_eggs", "food_allergies_mushrooms", "food_allergies_gluten", 
        "food_allergies_fish", "food_allergies_others", "food_allergies_remarks"
    ],
    
    #child non food allergies
    ('qa_nonFoodAllergies.sql', 'dev_child_profile.sql'): [
        "non_food_allergies_pollen", "non_food_allergies_others", "non_food_allergies_remarks"
    ],
    
    #guardians
    ('qa_guardian_data.sql', 'dev_guardian_data.sql'):[
        "id", "child_name", "child_birth_certificate", "relationship", "centre_code", "is_centre_verified", 
        "guardian_id", "guardian_firstname", "guardian_lastname", "guardian_identification_no", "guardian_email", 
        "guardian_mobile_phone_country_code", "guardian_mobile_phone", "guardian_gender", "guardian_profile_photo_storage_path", 
        "guardian_ic_front_image_storage_path", "guardian_ic_back_image_storage_path", "created_at", "updated_at", "created_by"
    ],
    #centre
    ('qa_centre_data.sql', 'dev_centre_data.sql'):[
        "id", "label", "code", "cost_centre_code", "ecda_code", "centre_email", "centre_contact_name", "centre_contact_number", 
        "address_line_1", "address_postal_code", "address_block", "address_floor", "address_unit_no", "centre_effective_from", 
        "centre_effective_to", "first_operation_date", "license_renewal_date", "license_renewal_duration", "certification", 
        "spark_expiration_date", "licensed_infant_care_capacity", "licensed_childcare_capacity", "created_at", "updated_at", 
        "service_level_code_offerred", "program_offered", "registration_fee",
    ],
    
    #discount_item
    ('qa_discount_item.sql', 'dev_discount_item.sql'):[
        "id", "label", "centre_code", "discount_item_group", "type", "application_type", "amount", "from", "to", 
        "billable_item_id", "billable_item_label", "billable_item_group_id", "billable_item_group_label", 
        "is_recurrent_discount", "disbursement_mode", "application_level", "created_at", "updated_at"
    ],
    
    #child fee tier
    ('qa_child_fee_tier.sql', 'dev_child_fee_tier.sql'):[
        "id", "child_firstname", "child_lastname", "child_birth_certificate", "nationality", "fee_group", 
        "fee_tier", "fee_tier_id", "effective_from", "effective_to", "centre_code", "level_code", "program_code"
    ]
}
