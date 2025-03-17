WITH active_child AS (
   SELECT 
        cl.fk_child, 
        MIN(cl.`from`) AS earliest_from
    FROM child_level cl
    WHERE cl.fk_centre IN (1, 5, 10, 18, 16, 20)
      AND (cl.`to` IS NULL OR cl.`to` >= CURRENT_TIMESTAMP)
      AND cl.`active` = 1
    GROUP BY cl.fk_child
), 
unique_deposit_invoice_per_child AS (
    SELECT 
        ac.fk_child AS child_id,
        MAX(ii.id) AS invoice_item_id
    FROM active_child ac
    INNER JOIN `invoice` iv ON iv.fk_child = ac.fk_child
    INNER JOIN `invoice_item` ii 
        ON ii.fk_invoice = iv.id 
        AND ii.active = 1 
        AND ii.label LIKE 'deposit%'
    WHERE iv.fk_centre IN (1, 5, 10, 18, 16, 20)
      AND iv.status = 'completed'
      AND iv.active = 1
      AND (iv.invoice_type = 'deposit' OR iv.label LIKE 'deposit%' OR ii.id IS NOT NULL)
    GROUP BY ac.fk_child
)
SELECT 
    udp.child_id AS id,
    ce.code AS centre_code,
    iv.invoice_no,
    ii.total_amount AS total_deposit_amount,
    rr.receipt_no,
    rr.document_no AS receipt_document_no,
    IF(ri.total_amount IS NULL AND rr.amount = ii.total_amount, rr.amount, ri.total_amount) AS receipt_paid_amount,
    IF(rr.payment_type LIKE '%CDA%', 'CDA', 'Non-CDA') AS receipt_payment_mode,
    rr.payment_type AS receipt_payment_type,
    IFNULL(ba.bill_reference_number, '') AS bank_account_no,
    CASE 
        WHEN ba.id IS NULL OR rr.payment_type NOT LIKE '%CDA%' THEN ''
        ELSE IF(ba.is_sibling_cda = 1, 'Yes', 'NO')
    END AS is_sibling_cda
FROM unique_deposit_invoice_per_child udp
INNER JOIN `invoice_item` ii ON ii.id = udp.invoice_item_id AND ii.active = 1
INNER JOIN `billable_item` bi ON bi.id = ii.fk_billable_item AND bi.active = 1
INNER JOIN `invoice` iv ON iv.id = ii.fk_invoice AND iv.active = 1
INNER JOIN `centre` ce ON ce.id = iv.fk_centre AND ce.active = 1
LEFT JOIN `receipt_item` ri ON ri.fk_invoice_item = udp.invoice_item_id AND ri.active = 1
LEFT JOIN `receipt` rr ON rr.id = ri.fk_receipt AND rr.active = 1
LEFT JOIN `bank_account` ba ON ba.id = rr.fk_bank_account
WHERE rr.cancelled_date IS NULL 
ORDER BY udp.child_id;
