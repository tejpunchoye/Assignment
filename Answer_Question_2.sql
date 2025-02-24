-- Create a table for Suppliers
CREATE TABLE SUPPLIERS (
    SUPPLIER_ID NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    SUPPLIER_NAME VARCHAR2(255),
    SUPP_CONTACT_NAME VARCHAR2(255),
    SUPP_EMAIL VARCHAR2(255),
    SUPP_STREET VARCHAR2(255),
    SUPP_TOWN VARCHAR2(100),
    SUPP_COUNTRY VARCHAR2(100)
);
-- Create a table for Supplier Contacts
CREATE TABLE SUPPLIER_CONTACTS (
    CONTACT_ID NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    SUPPLIER_ID NUMBER,
    CONTACT_NUMBER VARCHAR2(20),
    FOREIGN KEY (SUPPLIER_ID) REFERENCES SUPPLIERS(SUPPLIER_ID)
);
-- Create a table for Order Lines
CREATE TABLE ORDER_LINES (
    ORDER_LINE_ID NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    ORDER_ID NUMBER,
     ORDER_DATE DATE,
    ORDER_LINE_AMOUNT NUMBER,
    ORDER_LINE_DESCRIPTION VARCHAR2(500),
    FOREIGN KEY (ORDER_ID) REFERENCES ORDERS(ORDER_ID)
);
-- Create a table for Orders
CREATE TABLE ORDERS (
    ORDER_ID NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    ORDER_REF VARCHAR2(50),
    ORDER_DATE DATE NOT NULL,
    SUPPLIER_ID NUMBER,
    ORDER_TOTAL_AMOUNT NUMBER(10,2),
    ORDER_DESCRIPTION VARCHAR2(500),
    ORDER_STATUS VARCHAR2(50),
    FOREIGN KEY (SUPPLIER_ID) REFERENCES SUPPLIERS(SUPPLIER_ID)
);
-- Create a table for Invoices
CREATE TABLE INVOICES (
    INVOICE_ID NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    ORDER_ID NUMBER,
    INVOICE_REFERENCE VARCHAR2(50),
    INVOICE_DATE DATE,
    INVOICE_STATUS VARCHAR2(50),
    INVOICE_HOLD_REASON VARCHAR2(255),
    INVOICE_AMOUNT NUMBER(10,2),
    INVOICE_DESCRIPTION VARCHAR2(500),
    FOREIGN KEY (ORDER_ID) REFERENCES ORDERS(ORDER_ID)
);
