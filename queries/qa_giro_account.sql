WITH 
LatestBankAccounts AS (
    SELECT ba.*
    FROM bank_account ba
    INNER JOIN (
        SELECT bill_reference_number, MAX(created_at) AS max_created_at
        FROM bank_account
        WHERE active = 1 AND status = 'approved'
        GROUP BY bill_reference_number
    ) latest_ba 
    ON ba.bill_reference_number = latest_ba.bill_reference_number 
    AND ba.created_at = latest_ba.max_created_at
    WHERE ba.active = 1 AND ba.status = 'approved'
),

LatestBankAccountAttributes AS (
    SELECT baa.*
    FROM bank_account_attribute baa
    INNER JOIN (
        SELECT fk_bank_account, MAX(created_at) AS max_created_at
        FROM bank_account_attribute
        WHERE active = 1
        GROUP BY fk_bank_account
    ) latest_baa 
    ON baa.fk_bank_account = latest_baa.fk_bank_account
    AND baa.created_at = latest_baa.max_created_at
    WHERE baa.active = 1
),

LatestChildLevel AS (
    SELECT cl.*
    FROM child_level cl
    INNER JOIN (
        SELECT fk_child, MAX(`from`) AS max_from
        FROM child_level
        WHERE active = 1
        AND (`TO` >= CURRENT_DATE OR `TO` IS NULL)
        GROUP BY fk_child
    ) latest_cl 
    ON cl.fk_child = latest_cl.fk_child
    AND cl.`from` = latest_cl.max_from
    WHERE cl.active = 1
)
SELECT DISTINCT
    ch.id,
    /* ch.firstname AS child_firstname,
    ch.lastname AS child_lastname, */
    ch.fullname AS child_name,
    ch.birth_certificate AS child_birth_certificate,
    ce.code AS centre_code,
    ba.id AS cda_id,
    IF(ba.is_cda = 1, "Yes", "No") AS is_cda_account,
    bbc.bic_code AS giro_account_bank_bic_code,
    ba.bill_reference_number AS giro_account_reference_number,
    ba.payer_account_name AS giro_account_payer_account_name,
    ba.payer_account_number AS giro_account_payer_account_number,
    ifnull(ba.effective_from,'') AS giro_account_effective_from,
    ifnull(ba.effective_to,'') AS giro_account_effective_to,
    IFnull(ba.child_name,'') AS cda_child_name,
    ifnull(ba.child_birth_certificate,'') AS cda_child_birth_certificate,
    IF(ba.is_sibling_cda = 1, "Yes", "No") AS giro_account_is_sibling_cda,
    ifnull(ba.sibling_name,'') as cda_sibling_name,
    ifnull(ba.sibling_birth_certificate,'') AS cda_sibling_birth_certificate,
    IFNULL(
       DATE_FORMAT(
           CONVERT_TZ(
               STR_TO_DATE(
                   LEFT(JSON_UNQUOTE(JSON_EXTRACT(baa.value, '$.ApplicationDate')), 19),
                   '%Y-%m-%dT%H:%i:%s'
               ), 
               '+08:00', 
               '+00:00'
           ), 
           '%Y-%m-%d %H:%i:%s'
       ), 
       ''
    ) AS giro_account_application_date,
    ba.source AS giro_account_source,
    ba.status AS giro_account_status,
    ba.updated_at AS giro_account_last_updated_at
    
FROM child ch
INNER JOIN LatestChildLevel cl ON cl.fk_child = ch.id
LEFT JOIN centre ce ON ce.id = cl.fk_centre AND ce.id IN (1, 5, 10, 18, 16, 20)
LEFT JOIN LatestBankAccounts ba ON ba.fk_child = ch.id 
LEFT JOIN bank_bic_code bbc ON bbc.id = ba.fk_bank_bic_code AND bbc.active = 1
LEFT JOIN LatestBankAccountAttributes baa ON baa.fk_bank_account = ba.id
WHERE ba.status = "approved"
AND ch.id IN (
    SELECT cl.fk_child
    FROM LatestChildLevel cl
    WHERE cl.fk_centre IN (1, 5, 10, 18, 16, 20)
);
