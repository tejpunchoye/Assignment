CREATE OR REPLACE PROCEDURE GET_MEDIAN_ORDER_REPORT
IS
    -- Declare variables to store results
    v_order_reference   NUMBER;
    v_order_date        VARCHAR2(20);
    v_supplier_name     VARCHAR2(100);
    v_order_total_amount VARCHAR2(20);
    v_order_status      VARCHAR2(50);
    v_invoice_references VARCHAR2(4000); -- To store concatenated invoice references
    v_no_data_found     EXCEPTION; -- Custom exception for no data

    -- Declare cursor to get the median Order Total Amount
    CURSOR median_order_cur IS
        SELECT 
            TO_NUMBER(REGEXP_SUBSTR(O.ORDER_REF, '\d+')) AS ORDER_REFERENCE,
            TO_CHAR(O.ORDER_DATE, 'DD-MON-YYYY') AS ORDER_DATE,
            UPPER(S.SUPPLIER_NAME) AS SUPPLIER_NAME,
            TO_CHAR(O.ORDER_TOTAL_AMOUNT, '99,999,990.00') AS ORDER_TOTAL_AMOUNT,
            O.ORDER_STATUS,
            COALESCE(
                LISTAGG(I.INVOICE_REFERENCE, '|') WITHIN GROUP (ORDER BY I.INVOICE_REFERENCE), 
                'No Invoices'
            ) AS INVOICE_REFERENCES
        FROM ORDERS O
        JOIN SUPPLIERS S ON O.SUPPLIER_ID = S.SUPPLIER_ID
        LEFT JOIN INVOICES I ON O.ORDER_ID = I.ORDER_ID
        WHERE O.ORDER_TOTAL_AMOUNT = (SELECT MEDIAN(ORDER_TOTAL_AMOUNT) FROM ORDERS)
        GROUP BY O.ORDER_REF, O.ORDER_DATE, S.SUPPLIER_NAME, O.ORDER_TOTAL_AMOUNT, O.ORDER_STATUS
        FETCH FIRST 1 ROW ONLY; -- Ensuring only one record is fetched

BEGIN
    -- Open the cursor and fetch the record
    OPEN median_order_cur;
    FETCH median_order_cur INTO 
        v_order_reference, v_order_date, v_supplier_name, 
        v_order_total_amount, v_order_status, v_invoice_references;

    -- Check if no data was retrieved
    IF median_order_cur%NOTFOUND THEN
        RAISE v_no_data_found; -- Raise custom exception
    END IF;

    -- Display the details for the median order
    DBMS_OUTPUT.PUT_LINE(
        'Order Ref: ' || v_order_reference || ' | ' ||
        'Order Date: ' || v_order_date || ' | ' ||
        'Supplier: ' || v_supplier_name || ' | ' ||
        'Order Amount: ' || v_order_total_amount || ' | ' ||
        'Order Status: ' || v_order_status || ' | ' ||
        'Invoice References: ' || v_invoice_references
    );
    -- Close the cursor
    CLOSE median_order_cur;

EXCEPTION
    -- Handle case where no median order exists
    WHEN v_no_data_found THEN
        DBMS_OUTPUT.PUT_LINE('No orders found for the median Order Total Amount.');

    -- Ensure cursor is closed in case of other errors
    WHEN OTHERS THEN
        IF median_order_cur%ISOPEN THEN
            CLOSE median_order_cur;
        END IF;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END GET_MEDIAN_ORDER_REPORT;

BEGIN
    GET_MEDIAN_ORDER_REPORT;
END;
