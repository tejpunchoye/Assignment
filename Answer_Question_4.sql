
CREATE OR REPLACE PROCEDURE GET_ORDER_SUMMARY_REPORT
IS
    CURSOR order_summary_cur IS
        SELECT 
            -- Extract Region 
            S.SUPP_TOWN AS REGION,
            
            -- removing prefix PO
            TO_NUMBER(REGEXP_SUBSTR(O.ORDER_REF, '\d+')) AS ORDER_REFERENCE,
            
            -- Format Order Period as YYYY-MM
            TO_CHAR(O.ORDER_DATE, 'YYYY-MM') AS ORDER_PERIOD,
            
            -- Supplier Name
            S.SUPPLIER_NAME AS SUPPLIER_NAME,

            -- Format Order Total Amount
            TO_CHAR(O.ORDER_TOTAL_AMOUNT, '99,999,990.00') AS ORDER_TOTAL_AMOUNT,

            -- Order Status
            O.ORDER_STATUS,

            -- Invoice Reference
            I.INVOICE_REFERENCE,

            -- Invoice Total Amount
            TO_CHAR(I.INVOICE_AMOUNT, '99,999,990.00') AS INVOICE_TOTAL_AMOUNT,

            -- Actions based on Invoice Status
            CASE 
                WHEN COUNT(CASE WHEN I.INVOICE_STATUS = 'Paid' THEN 1 END) = COUNT(*)
                THEN 'No Action'
                WHEN COUNT(CASE WHEN I.INVOICE_STATUS = 'Pending' THEN 1 END) > 0
                THEN 'To Follow Up'
                WHEN COUNT(CASE WHEN I.INVOICE_STATUS IS NULL OR I.INVOICE_STATUS = '' THEN 1 END) > 0
                THEN 'To Verify'
                ELSE 'Unknown'
            END AS ACTION
        FROM ORDERS O
        JOIN SUPPLIERS S ON O.SUPPLIER_ID = S.SUPPLIER_ID
        JOIN INVOICES I ON O.ORDER_ID = I.ORDER_ID
        GROUP BY 
            S.SUPP_TOWN, 
            O.ORDER_REF, 
            O.ORDER_DATE, 
            S.SUPPLIER_NAME, 
            O.ORDER_TOTAL_AMOUNT, 
            O.ORDER_STATUS, 
            I.INVOICE_REFERENCE, 
            I.INVOICE_AMOUNT
        ORDER BY 
            S.SUPP_TOWN ASC, -- Group by region
            O.ORDER_TOTAL_AMOUNT DESC; -- Sort by Order Total Amount (Descending)
BEGIN
    -- Displaying the data
    FOR order_row IN order_summary_cur LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Region: ' || order_row.REGION || ' | ' ||
            'Order Ref: ' || order_row.ORDER_REFERENCE || ' | ' ||
            'Period: ' || order_row.ORDER_PERIOD || ' | ' ||
            'Supplier: ' || order_row.SUPPLIER_NAME || ' | ' ||
            'Order Amount: ' || order_row.ORDER_TOTAL_AMOUNT || ' | ' ||
            'Order Status: ' || order_row.ORDER_STATUS || ' | ' ||
            'Invoice Ref: ' || order_row.INVOICE_REFERENCE || ' | ' ||
            'Invoice Amount: ' || order_row.INVOICE_TOTAL_AMOUNT || ' | ' ||
            'Action: ' || order_row.ACTION
        );
    END LOOP;
END GET_ORDER_SUMMARY_REPORT;

SET SERVEROUTPUT ON SIZE UNLIMITED;

BEGIN
    GET_ORDER_SUMMARY_REPORT;
END;