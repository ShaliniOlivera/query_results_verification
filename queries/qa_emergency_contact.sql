SELECT 
    ch.id AS id, 
    -- Emergency Contact Name (Handles both uppercase and lowercase key variations)
    IF(
        LENGTH(TRIM(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.LastName')), ''))) > 1, 
        TRIM(CONCAT(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.FirstName')), ''), ' ', IFNULL(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.LastName')), ''))), 
        TRIM(CONCAT(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.firstName')), ''), ' ', IFNULL(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.lastName')), '')))
    ) AS emergency_contact_name,

    -- Identification No.
    IF(
        LENGTH(TRIM(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.LastName')), ''))) > 1, 
        IFNULL(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.IdentificationNo')), ''), 
        IFNULL(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.identificationNo')), '')
    ) AS emergency_contact_identification_no,

    -- Postal Code
    IF(
        LENGTH(TRIM(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.LastName')), ''))) > 1, 
        IFNULL(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.PostalCode')), ''), 
        IFNULL(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.postalCode')), '')
    ) AS emergency_contact_address_postal_code,

    -- Address Line 1
    IF(
        LENGTH(TRIM(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.LastName')), ''))) > 1, 
        IFNULL(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.Address')), ''), 
        IFNULL(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.address')), '')
    ) AS emergency_contact_address_line_1,

    -- Floor No.
    IF(
        LENGTH(TRIM(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.LastName')), ''))) > 1, 
        IFNULL(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.FloorNo')), ''), 
        IFNULL(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.floorNo')), '')
    ) AS emergency_contact_address_floor_no,

    -- Unit No.
    IF(
        LENGTH(TRIM(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.LastName')), ''))) > 1, 
        IFNULL(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.UnitNo')), ''), 
        IFNULL(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.unitNo')), '')
    ) AS emergency_contact_address_unit_no,

    -- Block No.
    IF(
        LENGTH(TRIM(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.LastName')), ''))) > 1, 
        IFNULL(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.BlockNo')), ''), 
        IFNULL(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.blockNo')), '')
    ) AS emergency_contact_address_block_no,

    -- Email
    IF(
        LENGTH(TRIM(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.LastName')), ''))) > 1, 
        IFNULL(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.Email')), ''), 
        IFNULL(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.email')), '')
    ) AS emergency_contact_email,

    -- Mobile Phone
    IF(
        LENGTH(TRIM(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.LastName')), ''))) > 1, 
        IFNULL(CONCAT(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.MobilePhoneCC')), JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.MobilePhone'))), ''), 
        IFNULL(CONCAT(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.mobilePhoneCC')), JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.mobilePhone'))), '')
    ) AS emergency_contact_mobile_phone,

    -- Relationship
    IF(
        LENGTH(TRIM(IFNULL(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.LastName')), ''))) > 1, 
        IFNULL(IF(
            IFNULL(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.Relationship')), '') != '', 
            (SELECT description FROM code cde WHERE cde.id = JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.Relationship')) LIMIT 1), 
            ''
        ), ''), 
        IFNULL(IF(
            IFNULL(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.relationship')), '') != '', 
            (SELECT description FROM code cde WHERE cde.id = JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.relationship')) LIMIT 1), 
            ''
        ), '')
    ) AS emergency_contact_relationship

FROM (
    
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
) ch
LEFT JOIN child_attribute ca ON ch.id = ca.fk_child AND ca.active = 1 AND ca.fk_code = "3796";
