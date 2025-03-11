SELECT 
    ce.id, 
    ce.label, 
    ce.code, 
    ce.cost_centre_code, 
    ce.ecda_code, 
    ce.email AS centre_email, 
    us.lastname AS centre_contact_name, 
    CONCAT(ce.country_code, ce.contact_number) AS centre_contact_number, 
    ad.postcode AS address_postal_code, 
    -- ad.city AS address_city, 
    -- ad.country AS address_country, 
    ad.address AS address_line_1,
    ad.building AS address_block, 
    ad.floor AS address_floor, 
    ad.unit AS address_unit_no, 
    ce.`from` AS centre_effective_from, 
    COALESCE(ce.`to`, '') AS centre_effective_to, 
    ce.`first_operation_date` AS first_operation_date, 
    coalesce(ce.license_renewal_date,'') AS license_renewal_date, 
    coalesce(ce.license_renewal_duration,'') AS license_renewal_duration,   
    coalesce(co.label,'') AS certification,         
    coalesce(ce.spark_expiration_date,'') AS spark_expiration_date,   
    ce.licensed_infant_care_capacity, 
    ce.licensed_childcare_capacity, 
    ce.created_at, 
    ce.updated_at,
    trim(GROUP_CONCAT(DISTINCT le.code ORDER BY le.id SEPARATOR ',')) AS service_level_code_offerred,
    GROUP_CONCAT(DISTINCT pr.label  SEPARATOR ',') AS program_offered,
    bi.unit_price AS registration_fee
FROM centre ce
INNER JOIN `user` us ON us.id = ce.fk_primary_email_contact
INNER JOIN `address` ad ON ad.fk_centre = ce.id
INNER JOIN `centre_level` cle ON cle.fk_centre = ce.id
INNER JOIN `level` le ON le.id = cle.fk_level
INNER JOIN `centre_level_program` clp ON clp.fk_level = le.id AND clp.fk_centre = ce.id
INNER JOIN `program` pr ON pr.id = clp.fk_program
INNER JOIN `billable_item` bi ON ce.id = bi.fk_centre
LEFT JOIN `code` co ON co.id = ce.fk_certification
WHERE ce.id IN (1, 5, 10, 18, 16, 20)
AND bi.type = "registration_fee"
AND bi.active = 1
AND (bi.`to` IS NULL OR bi.`to` > CURRENT_TIMESTAMP())
GROUP BY ce.id, ce.label, ce.code, ce.cost_centre_code, ce.ecda_code, ce.email, us.lastname, ce.country_code, ce.contact_number, ad.postcode, ad.city, ad.country, ad.address, ad.building, ad.floor, ad.unit, ce.`from`, ce.`to`, ce.`first_operation_date`, ce.license_renewal_date, ce.license_renewal_duration, ce.spark_expiration_date, ce.licensed_infant_care_capacity, ce.licensed_childcare_capacity, ce.created_at, ce.updated_at,bi.unit_price;
