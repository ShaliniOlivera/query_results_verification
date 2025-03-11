select 
	cnt.`id`,
    cnt.`label` AS `label`,
    cnt.`code` AS `code`,
    cnt.`cost_centre_code` AS `cost_centre_code`,
    cnt.`ecda_code` AS `ecda_code`,
	cnt.`email` AS `centre_email`,
    TRIM(CONCAT(IFNULL(usr_centre_contact.`firstname`, ''), ' ', IFNULL(usr_centre_contact.`lastname`, ''))) AS `centre_contact_name`,
    CONCAT(cnt.`country_code`, cnt.`contact_number`) AS `centre_contact_number`,
    adr.`address` as `address_line_1`, 
    adr.`postcode` AS `address_postal_code`, 
    adr.`building` AS `address_block`, 
    adr.`floor` AS `address_floor`, 
    adr.`unit` AS `address_unit_no`,
    cnt.`from` AS `centre_effective_from`, IFNULL(cnt.`to`, '') AS `centre_effective_to`,
    cnt.`first_operation_date`,
    IFNULL(cnt.`license_renewal_date`, '') AS `license_renewal_date`, IFNULL(cnt.`license_renewal_duration`, '') AS `license_renewal_duration`,
    IFNULL(cd_certification.`label`, '') AS `certification`, 
    IFNULL(cnt.`spark_expiration_date`, '') AS `spark_expiration_date`,
    cnt.`licensed_infant_care_capacity`,
    cnt.`licensed_childcare_capacity`,
    cnt.`created_at`, cnt.`updated_at`
    ,(select GROUP_CONCAT(distinct lv.`code` ORDER BY lv.`from_month`) AS program_offered
		from centre_level_program clp 
			inner join `level` lv ON lv.`id` = clp.`fk_level` AND lv.`active` = 1
			inner join `program` prg ON prg.`id` = clp.`fk_program` AND prg.`active` = 1
		where 
			clp.fk_centre = cnt.`id`
			AND clp.`active` = 1
		GROUP BY clp.`fk_centre`) AS `service_level_code_offerred`
	, (select GROUP_CONCAT(distinct prg.`label`) AS program_offered
		from centre_level_program clp 
			inner join `level` lv ON lv.`id` = clp.`fk_level` AND lv.`active` = 1
			inner join `program` prg ON prg.`id` = clp.`fk_program` AND prg.`active` = 1
		where 
			clp.fk_centre = cnt.`id`
			AND clp.`active` = 1
		GROUP BY clp.`fk_centre`) AS `program_offered`
	
	, (select bi.`unit_price` 
		from `billable_item` bi 
        where 
			bi.`fk_centre` = cnt.`id` 
			AND bi.`type` = 'registration_fee' 
            AND (bi.`to` is null or bi.`to` > current_timestamp())
            AND bi.`active` = 1 
		limit 1
        ) AS `registration_fee`
from centre cnt
	inner join `address` adr ON adr.`fk_centre` = cnt.`id` AND adr.`active` = 1
    left outer join `code` cd_gov_scheme ON cd_gov_scheme.`id` = cnt.`fk_govt_scheme`
    left outer join `code` cd_certification ON cd_certification.`id` = cnt.`fk_certification`
    left outer join `user` usr_centre_contact ON usr_centre_contact.`id` = cnt.`fk_primary_email_contact`
where
	cnt.`id` in (1, 5, 10, 18, 16, 20)
;
