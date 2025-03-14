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
        "parent_two_date_of_birth", "parent_two_nationality", "parent_two_race", "parent_two_marital_status",
        "parent_two_qualification", "parent_two_occupation", "parent_two_working_status", "parent_two_pr_commencement_date",
        "address_postal_code", "address_city", "address_country", "address_line_1", "address_block", "address_floor", "address_unit_no"
    ],
    
    #child emergency details
    ('qa_emergency_contact.sql', 'dev_child_profile.sql'): [
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
        "id", "child_name", "child_birth_certificate", "relationship", "centre_code",  
        "guardian_id", "guardian_firstname", "guardian_lastname", "guardian_identification_no", "guardian_email", 
        "guardian_mobile_phone_country_code", "guardian_mobile_phone", "guardian_gender", "guardian_profile_photo_storage_path", 
        "guardian_ic_front_image_storage_path", "guardian_ic_back_image_storage_path", "created_at", "updated_at", "created_by" #"is_centre_verified",
    ],
    #centre
    ('qa_centre_data.sql', 'dev_centre_data.sql'):[
        "id", "label", "code", "cost_centre_code", "ecda_code", "centre_email", "centre_contact_name", "centre_contact_number", 
        "address_line_1", "address_postal_code", "address_block", "address_floor", "address_unit_no", "centre_effective_from", 
        "centre_effective_to", "first_operation_date", "license_renewal_date", "license_renewal_duration", "certification", 
        "spark_expiration_date", "licensed_infant_care_capacity", "licensed_childcare_capacity", "created_at", "updated_at", 
        "service_level_code_offerred", "program_offered", "registration_fee"
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
    ],
    
    #billable_item
    ('qa_billable_item.sql', 'dev_billable_item.sql'):[
        "id", "label", "acc_pac_code", "type", "centre_code", "supplier", "is_default_subsidy", "display_order", 
        "is_for_bulk_invoice", "unit_price", "max_unit_price", "subsidy_type", "gst_taxable", "cda_deductible",
        "from", "to", "created_at", "updated_at"
    ],
    
    #child_level
    ('qa_child_level.sql', 'dev_child_level.sql'):[
        "id", "level_code", "program_code", "from", "to", "move_reason", "created_at", "updated_at"
    ],
    
    #class info
    ('qa_class_info.sql', 'dev_class_info.sql'):[
        "id", "label", "description", "centre_code", "level_code", "from", "to", "banner_url_path",
        "profile_photo_url_path", "is_default_class", "created_at", "updated_at",
    ],
    
    #child_class info
    ('qa_child_class.sql', 'dev_child_class.sql'):[
        "id", "centre_code", "class_id", "level_code", "from", "to", "created_at", "updated_at"
    ],
    
    #giro account
    ('qa_giro_account.sql','dev_giro_account.sql'):[
        "id", "child_name", "child_birth_certificate", 
        "centre_code", "id", "is_cda_account", "giro_account_bank_bic_code", "giro_account_reference_number", 
        "giro_account_payer_account_name", "giro_account_payer_account_number", "giro_account_effective_from",
        "giro_account_effective_to", "cda_child_name", "cda_child_birth_certificate", "giro_account_is_sibling_cda",
        "cda_sibling_name", "cda_sibling_birth_certificate", "giro_account_application_date", "giro_account_source",
        "giro_account_status", "giro_account_last_updated_at"
    ],
    
    #discount arrangement
    ('qa_discount_arrangement.sql','dev_discount_arrangement.sql'):[
        "id", "child_firstname", "child_lastname", "child_birth_certificate", "centre_code", "discount_item_id",
        "discount_item_label", "amount", "from", "to", "is_recurrent_discount", "created_at", "updated_at"
    ],
    
    #fee tier
    ('qa_fee_tier.sql','dev_fee_tier.sql'):[
        "id", "centre_code", "fee_label", "fee_tier_id", "fee_tier_label", "fee_group_id", "fee_group_label", 
        "level_code", "program_code", "nationality", "amount", "registration_from", "registration_to", 
        "effective_from", "effective_to", "created_at", "updated_at"
    ],
    
    #invoice
    ('qa_invoice.sql','dev_invoice.sql'):[
        "id", "child_id", "centre_code", "invoice_no", "invoice_date", "invoice_label", "type", "status", 
        "invoice_due_date", "total_payable_amount", "invoice_pdf_storage_path", "created_by_staff_name", 
        "updated_by_staff_name" #, "created_at", "updated_at"
    ],
    
    #receipt
    ('qa_receipt.sql','dev_receipt.sql'):[
        "id", "child_id", "centre_code", "receipt_no", "collected_date", "bank_account_no", 
        "payment_type", "payment_mode", "document_no", "total_receipt_amount", "pdf_storage_path", 
        "collected_by_staff_name", "cancelled_by_staff_name", "cancellation_date", "cancellation_reason", "created_at", "updated_at"
    ],
    
    #refund
    ('qa_refund.sql','dev_refund.sql'):[
        "id", "child_id", "centre_code", "refund_no", "requested_date", "refund_completed_date", "refund_mode", "refund_type", 
        "amount", "created_by_staff_name", "remarks", "created_at", "updated_at"
    ],
    
    #credit_debit_note
    ('qa_credit_debit_note.sql','dev_credit_debit_note.sql'):[
        "id", "child_id", "centre_code", "credit_debit_note_no", "credit_debit_note_date", "type", "amount", "pdf_storage_path", 
        "created_by_staff_name", "updated_by_staff_name", "debt_write_off_requester", "debt_write_off_approver", 
         "debt_writeoff_other_reason", "reason", "remarks", "created_at", "updated_at" # "debt_write_off_reason",
    ],
    
    #SOA
    ('qa_soa.sql','dev_soa.sql'):[
        "id", "child_id", "centre_code", "document_date", "document_storage_path", "total_outstanding_amount", "created_at", "updated_at"
    ]
}
