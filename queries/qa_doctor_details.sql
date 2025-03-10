SELECT DISTINCT ch.id,

    -- Family Doctor Information (Handling NULL values, Case Sensitivity, and "null" Text)
    COALESCE(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.familyDoctorDetails.clinicName')), 'null'),
             NULLIF(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.familydoctorDetails.clinicName')), 'null'),
             NULLIF(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.FAMILYDOCTORDETAILS.CLINICNAME')), 'null'),
             '') AS family_doctor_clinic_name,

    COALESCE(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.familyDoctorDetails.name')), 'null'),
             NULLIF(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.familydoctorDetails.name')), 'null'),
             NULLIF(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.FAMILYDOCTORDETAILS.NAME')), 'null'),
             '') AS family_doctor_name,

    COALESCE(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.familyDoctorDetails.email')), 'null'),
             NULLIF(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.familydoctorDetails.email')), 'null'),
             NULLIF(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.FAMILYDOCTORDETAILS.EMAIL')), 'null'),
             '') AS family_doctor_email,

    COALESCE(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.familyDoctorDetails.contactNumber')), 'null'),
             NULLIF(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.familydoctorDetails.contactNumber')), 'null'),
             NULLIF(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.FAMILYDOCTORDETAILS.CONTACTNUMBER')), 'null'),
             '') AS family_doctor_contact_no,

    COALESCE(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.familyDoctorDetails.clinicUnit')), 'null'),
             NULLIF(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.familydoctorDetails.clinicUnit')), 'null'),
             NULLIF(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.FAMILYDOCTORDETAILS.CLINICUNIT')), 'null'),
             '') AS family_doctor_clinic_unit_no,

    COALESCE(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.familyDoctorDetails.clinicFloor')), 'null'),
             NULLIF(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.familydoctorDetails.clinicFloor')), 'null'),
             NULLIF(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.FAMILYDOCTORDETAILS.CLINICFLOOR')), 'null'),
             '') AS family_doctor_clinic_floor_no,

    COALESCE(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.familyDoctorDetails.clinicBlockNo')), 'null'),
             NULLIF(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.familydoctorDetails.clinicBlockNo')), 'null'),
             NULLIF(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.FAMILYDOCTORDETAILS.CLINICBLOCKNO')), 'null'),
             '') AS family_doctor_clinic_block_no,

    COALESCE(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.familyDoctorDetails.clinicBuilding')), 'null'),
             NULLIF(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.familydoctorDetails.clinicBuilding')), 'null'),
             NULLIF(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.FAMILYDOCTORDETAILS.CLINICBUILDING')), 'null'),
             '') AS family_doctor_clinic_address_1,

    COALESCE(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.familyDoctorDetails.clinicPostalCode')), 'null'),
             NULLIF(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.familydoctorDetails.clinicPostalCode')), 'null'),
             NULLIF(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.FAMILYDOCTORDETAILS.CLINICPOSTALCODE')), 'null'),
             '') AS family_doctor_clinic_postal_code,

    COALESCE(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.familyDoctorDetails.remarks')), 'null'),
             NULLIF(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.familydoctorDetails.remarks')), 'null'),
             NULLIF(JSON_UNQUOTE(JSON_EXTRACT(ca.value, '$.FAMILYDOCTORDETAILS.REMARKS')), 'null'),
             '') AS family_doctor_remarks


FROM child ch
LEFT JOIN child_attribute ca ON ca.fk_child = ch.id AND ca.fk_code = "2013"
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
);
