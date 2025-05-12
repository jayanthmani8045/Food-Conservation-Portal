-- 100 => if the information exist already
-- 200 => success execution
-- 500 => unknown error

SET SERVEROUTPUT ON;

--===========================================================
-- DROP any schema users listed in USER_DETAILS (if the table exists and has rows)
--===========================================================
DECLARE
  tbl_count  NUMBER;
  row_count  NUMBER;
  v_username VARCHAR2(100);

  TYPE rc IS REF CURSOR;
  cur_users  rc;
BEGIN
  -- 1) Does USER_DETAILS exist?
  SELECT COUNT(*) 
    INTO tbl_count
    FROM user_tables
   WHERE table_name = 'USER_DETAILS';

  IF tbl_count = 1 THEN
    -- 2) Count rows
    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM user_details' INTO row_count;

    IF row_count > 0 THEN
      -- 3) Loop over each username
      OPEN cur_users FOR 'SELECT user_name FROM user_details';
      LOOP
        FETCH cur_users INTO v_username;
        EXIT WHEN cur_users%NOTFOUND;
        BEGIN
          -- DROP using uppercase, unquoted identifier
          EXECUTE IMMEDIATE 
            'DROP USER ' || UPPER(v_username) || ' CASCADE';
          DBMS_OUTPUT.PUT_LINE(
            '200: user "' || v_username || '" dropped successfully'
          );
        EXCEPTION
          WHEN OTHERS THEN
            IF SQLCODE = -1940 THEN  -- ORA-01940: user is connected
              DBMS_OUTPUT.PUT_LINE(
                '100: user "'||v_username||'" is currently connected; cannot drop. please drop manually'
              );
            ELSIF SQLCODE = -1031 THEN  -- ORA-01031: insufficient privileges
              DBMS_OUTPUT.PUT_LINE(
                '100: insufficient privileges to drop user "'||v_username||'"'
              );
            ELSIF SQLCODE = -1918 THEN  -- ORA-01918: user does not exist
              DBMS_OUTPUT.PUT_LINE(
                '100: user "'||v_username||'" does not exist'
              );
            ELSE
              DBMS_OUTPUT.PUT_LINE(
                '500: unknown error dropping user "'||v_username||'" (ORA-'||ABS(SQLCODE)||')'
              );
            END IF;
        END;
      END LOOP;
      CLOSE cur_users;
    ELSE
      DBMS_OUTPUT.PUT_LINE('100: no users to drop');
    END IF;

  ELSE
    DBMS_OUTPUT.PUT_LINE('100: user_details table not present');
  END IF;
END;
/
--
--drop user logi_user;
--drop user gov_user;
--drop user sup_user;
--drop user ngo_user;
--select * from user_details;
--select * from all_users order by created desc;
--select * from all_users where username = upper('gov_user');
--select * from all_users where username = upper('logi_user');
--select * from all_users where username = upper('ngo_user');
--select * from all_users where username = upper('sup_user');
--===========================================================
-- DROP TABLES in Reverse Dependency Order
--===========================================================
DECLARE
  e_code          NUMBER;
  t_count         NUMBER;
  invalid_table   EXCEPTION;
BEGIN
  e_code := 200;
  SELECT COUNT(*) INTO t_count 
    FROM user_tables 
   WHERE table_name = 'LOGISTIC';
  IF t_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TABLE logistic CASCADE CONSTRAINTS';
    DBMS_OUTPUT.PUT_LINE(e_code||': logistic dropped successfully');
  ELSE
    RAISE invalid_table;
  END IF;
EXCEPTION
  WHEN invalid_table THEN
    e_code := 100;
    DBMS_OUTPUT.PUT_LINE(e_code||': logistic not available');
  WHEN OTHERS THEN
    e_code := 500;
    DBMS_OUTPUT.PUT_LINE(e_code||': unknown error');
END;
/

DECLARE
  e_code          NUMBER;
  t_count         NUMBER;
  invalid_table   EXCEPTION;
BEGIN
  e_code := 200;
  SELECT COUNT(*) INTO t_count 
    FROM user_tables 
   WHERE table_name = 'NGO_REQUEST';
  IF t_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TABLE ngo_request CASCADE CONSTRAINTS';
    DBMS_OUTPUT.PUT_LINE(e_code||': ngo_request dropped successfully');
  ELSE
    RAISE invalid_table;
  END IF;
EXCEPTION
  WHEN invalid_table THEN
    e_code := 100;
    DBMS_OUTPUT.PUT_LINE(e_code||': ngo_request not available');
  WHEN OTHERS THEN
    e_code := 500;
    DBMS_OUTPUT.PUT_LINE(e_code||': unknown error');
END;
/

DECLARE
  e_code          NUMBER;
  t_count         NUMBER;
  invalid_table   EXCEPTION;
BEGIN
  e_code := 200;
  SELECT COUNT(*) INTO t_count 
    FROM user_tables 
   WHERE table_name = 'MAIN_FOOD_DATA';
  IF t_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TABLE main_food_data CASCADE CONSTRAINTS';
    DBMS_OUTPUT.PUT_LINE(e_code||': main_food_data dropped successfully');
  ELSE
    RAISE invalid_table;
  END IF;
EXCEPTION
  WHEN invalid_table THEN
    e_code := 100;
    DBMS_OUTPUT.PUT_LINE(e_code||': main_food_data not available');
  WHEN OTHERS THEN
    e_code := 500;
    DBMS_OUTPUT.PUT_LINE(e_code||': unknown error');
END;
/

DECLARE
  e_code          NUMBER;
  t_count         NUMBER;
  invalid_table   EXCEPTION;
BEGIN
  e_code := 200;
  SELECT COUNT(*) INTO t_count 
    FROM user_tables 
   WHERE table_name = 'FOOD_TABLE';
  IF t_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TABLE food_table CASCADE CONSTRAINTS';
    DBMS_OUTPUT.PUT_LINE(e_code||': food_table dropped successfully');
  ELSE
    RAISE invalid_table;
  END IF;
EXCEPTION
  WHEN invalid_table THEN
    e_code := 100;
    DBMS_OUTPUT.PUT_LINE(e_code||': food_table not available');
  WHEN OTHERS THEN
    e_code := 500;
    DBMS_OUTPUT.PUT_LINE(e_code||': unknown error');
END;
/

DECLARE
  e_code          NUMBER;
  t_count         NUMBER;
  invalid_table   EXCEPTION;
BEGIN
  e_code := 200;
  SELECT COUNT(*) INTO t_count 
    FROM user_tables 
   WHERE table_name = 'SUPPLIER';
  IF t_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TABLE supplier CASCADE CONSTRAINTS';
    DBMS_OUTPUT.PUT_LINE(e_code||': supplier dropped successfully');
  ELSE
    RAISE invalid_table;
  END IF;
EXCEPTION
  WHEN invalid_table THEN
    e_code := 100;
    DBMS_OUTPUT.PUT_LINE(e_code||': supplier not available');
  WHEN OTHERS THEN
    e_code := 500;
    DBMS_OUTPUT.PUT_LINE(e_code||': unknown error');
END;
/

DECLARE
  e_code          NUMBER;
  t_count         NUMBER;
  invalid_table   EXCEPTION;
BEGIN
  e_code := 200;
  SELECT COUNT(*) INTO t_count 
    FROM user_tables 
   WHERE table_name = 'USER_DETAILS';
  IF t_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TABLE user_details CASCADE CONSTRAINTS';
    DBMS_OUTPUT.PUT_LINE(e_code||': user_details dropped successfully');
  ELSE
    RAISE invalid_table;
  END IF;
EXCEPTION
  WHEN invalid_table THEN
    e_code := 100;
    DBMS_OUTPUT.PUT_LINE(e_code||': user_details not available');
  WHEN OTHERS THEN
    e_code := 500;
    DBMS_OUTPUT.PUT_LINE(e_code||': unknown error');
END;
/

DECLARE
  e_code          NUMBER;
  t_count         NUMBER;
  invalid_table   EXCEPTION;
BEGIN
  e_code := 200;
  SELECT COUNT(*) INTO t_count 
    FROM user_tables 
   WHERE table_name = 'USER_ROLE';
  IF t_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TABLE user_role CASCADE CONSTRAINTS';
    DBMS_OUTPUT.PUT_LINE(e_code||': user_role dropped successfully');
  ELSE
    RAISE invalid_table;
  END IF;
EXCEPTION
  WHEN invalid_table THEN
    e_code := 100;
    DBMS_OUTPUT.PUT_LINE(e_code||': user_role not available');
  WHEN OTHERS THEN
    e_code := 500;
    DBMS_OUTPUT.PUT_LINE(e_code||': unknown error');
END;
/

--===========================================================
-- DROP SEQUENCES (if they exist)
--===========================================================
DECLARE
  e_code           NUMBER;
  t_count          NUMBER;
  invalid_sequence EXCEPTION;
BEGIN
  e_code := 200;
  SELECT COUNT(*) INTO t_count 
    FROM user_sequences 
   WHERE sequence_name = 'FOOD_SEQ';
  IF t_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP SEQUENCE food_seq';
    DBMS_OUTPUT.PUT_LINE(e_code||': food_seq dropped successfully');
  ELSE
    RAISE invalid_sequence;
  END IF;
EXCEPTION
  WHEN invalid_sequence THEN
    e_code := 100;
    DBMS_OUTPUT.PUT_LINE(e_code||': food_seq not available');
  WHEN OTHERS THEN
    e_code := 500;
    DBMS_OUTPUT.PUT_LINE(e_code||': unknown error');
END;
/

DECLARE
  e_code           NUMBER;
  t_count          NUMBER;
  invalid_sequence EXCEPTION;
BEGIN
  e_code := 200;
  SELECT COUNT(*) INTO t_count 
    FROM user_sequences 
   WHERE sequence_name = 'LOGISTIC_SEQ';
  IF t_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP SEQUENCE logistic_seq';
    DBMS_OUTPUT.PUT_LINE(e_code||': logistic_seq dropped successfully');
  ELSE
    RAISE invalid_sequence;
  END IF;
EXCEPTION
  WHEN invalid_sequence THEN
    e_code := 100;
    DBMS_OUTPUT.PUT_LINE(e_code||': logistic_seq not available');
  WHEN OTHERS THEN
    e_code := 500;
    DBMS_OUTPUT.PUT_LINE(e_code||': unknown error');
END;
/

DECLARE
  e_code           NUMBER;
  t_count          NUMBER;
  invalid_sequence EXCEPTION;
BEGIN
  e_code := 200;
  SELECT COUNT(*) INTO t_count 
    FROM user_sequences 
   WHERE sequence_name = 'MAIN_FOOD_SEQ';
  IF t_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP SEQUENCE main_food_seq';
    DBMS_OUTPUT.PUT_LINE(e_code||': main_food_seq dropped successfully');
  ELSE
    RAISE invalid_sequence;
  END IF;
EXCEPTION
  WHEN invalid_sequence THEN
    e_code := 100;
    DBMS_OUTPUT.PUT_LINE(e_code||': main_food_seq not available');
  WHEN OTHERS THEN
    e_code := 500;
    DBMS_OUTPUT.PUT_LINE(e_code||': unknown error');
END;
/

DECLARE
  e_code           NUMBER;
  t_count          NUMBER;
  invalid_sequence EXCEPTION;
BEGIN
  e_code := 200;
  SELECT COUNT(*) INTO t_count 
    FROM user_sequences 
   WHERE sequence_name = 'NGO_REQUEST_SEQ';
  IF t_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP SEQUENCE ngo_request_seq';
    DBMS_OUTPUT.PUT_LINE(e_code||': ngo_request_seq dropped successfully');
  ELSE
    RAISE invalid_sequence;
  END IF;
EXCEPTION
  WHEN invalid_sequence THEN
    e_code := 100;
    DBMS_OUTPUT.PUT_LINE(e_code||': ngo_request_seq not available');
  WHEN OTHERS THEN
    e_code := 500;
    DBMS_OUTPUT.PUT_LINE(e_code||': unknown error');
END;
/

DECLARE
  e_code           NUMBER;
  t_count          NUMBER;
  invalid_sequence EXCEPTION;
BEGIN
  e_code := 200;
  SELECT COUNT(*) INTO t_count 
    FROM user_sequences 
   WHERE sequence_name = 'SUPPLIER_SEQ';
  IF t_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP SEQUENCE supplier_seq';
    DBMS_OUTPUT.PUT_LINE(e_code||': supplier_seq dropped successfully');
  ELSE
    RAISE invalid_sequence;
  END IF;
EXCEPTION
  WHEN invalid_sequence THEN
    e_code := 100;
    DBMS_OUTPUT.PUT_LINE(e_code||': supplier_seq not available');
  WHEN OTHERS THEN
    e_code := 500;
    DBMS_OUTPUT.PUT_LINE(e_code||': unknown error');
END;
/

DECLARE
  e_code           NUMBER;
  t_count          NUMBER;
  invalid_sequence EXCEPTION;
BEGIN
  e_code := 200;
  SELECT COUNT(*) INTO t_count 
    FROM user_sequences 
   WHERE sequence_name = 'USER_DETAILS_SEQ';
  IF t_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP SEQUENCE user_details_seq';
    DBMS_OUTPUT.PUT_LINE(e_code||': user_details_seq dropped successfully');
  ELSE
    RAISE invalid_sequence;
  END IF;
EXCEPTION
  WHEN invalid_sequence THEN
    e_code := 100;
    DBMS_OUTPUT.PUT_LINE(e_code||': user_details_seq not available');
  WHEN OTHERS THEN
    e_code := 500;
    DBMS_OUTPUT.PUT_LINE(e_code||': unknown error');
END;
/

DECLARE
  e_code           NUMBER;
  t_count          NUMBER;
  invalid_sequence EXCEPTION;
BEGIN
  e_code := 200;
  SELECT COUNT(*) INTO t_count 
    FROM user_sequences 
   WHERE sequence_name = 'USER_ROLE_SEQ';
  IF t_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP SEQUENCE user_role_seq';
    DBMS_OUTPUT.PUT_LINE(e_code||': user_role_seq dropped successfully');
  ELSE
    RAISE invalid_sequence;
  END IF;
EXCEPTION
  WHEN invalid_sequence THEN
    e_code := 100;
    DBMS_OUTPUT.PUT_LINE(e_code||': user_role_seq not available');
  WHEN OTHERS THEN
    e_code := 500;
    DBMS_OUTPUT.PUT_LINE(e_code||': unknown error');
END;
/
  
--===========================================================
-- CREATE TABLES (if not exist) & CONSTRAINTS
--===========================================================
DECLARE
  e_code          NUMBER;
  t_count         NUMBER;
  already_exists  EXCEPTION;
BEGIN
  e_code := 200;
  SELECT COUNT(*) INTO t_count 
    FROM user_tables 
   WHERE table_name = 'USER_ROLE';
  IF t_count = 0 THEN
    EXECUTE IMMEDIATE q'[
      CREATE TABLE user_role 
      (
        role_id   NUMBER(10)  NOT NULL,
        role_name VARCHAR2(100 CHAR)  NOT NULL,
        CONSTRAINT user_role_PK PRIMARY KEY (role_id)
      )
    ]';
    DBMS_OUTPUT.PUT_LINE(e_code||': user_role created successfully');
  ELSE
    RAISE already_exists;
  END IF;
EXCEPTION
  WHEN already_exists THEN
    e_code := 100;
    DBMS_OUTPUT.PUT_LINE(e_code||': user_role already exists');
  WHEN OTHERS THEN
    e_code := 500;
    DBMS_OUTPUT.PUT_LINE(e_code||': unknown error');
END;
/


DECLARE
  e_code          NUMBER;
  t_count         NUMBER;
  already_exists  EXCEPTION;
BEGIN
  e_code := 200;
  SELECT COUNT(*) INTO t_count 
    FROM user_tables 
   WHERE table_name = 'USER_DETAILS';
  IF t_count = 0 THEN
    EXECUTE IMMEDIATE q'[
      CREATE TABLE user_details 
      (
        user_id           NUMBER(10)  NOT NULL,
        user_name         VARCHAR2(100 CHAR)  NOT NULL,
        password          VARCHAR2(100 CHAR)  NOT NULL,
        first_name        VARCHAR2(100 CHAR)  NOT NULL,
        last_name         VARCHAR2(100 CHAR)  NOT NULL,
        address           VARCHAR2(100 CHAR)  NOT NULL,
        contact_number    NUMBER(10)  NOT NULL,
        user_role_role_id NUMBER(10)  NOT NULL,
        CONSTRAINT user_details_PK PRIMARY KEY (user_id),
        CONSTRAINT user_details_user_name_UN UNIQUE (user_name),
        CONSTRAINT user_details_user_role_FK FOREIGN KEY (user_role_role_id)
           REFERENCES user_role (role_id)
      )
    ]';
    DBMS_OUTPUT.PUT_LINE(e_code||': user_details created successfully');
  ELSE
    RAISE already_exists;
  END IF;
EXCEPTION
  WHEN already_exists THEN
    e_code := 100;
    DBMS_OUTPUT.PUT_LINE(e_code||': user_details already exists');
  WHEN OTHERS THEN
    e_code := 500;
    DBMS_OUTPUT.PUT_LINE(e_code||': unknown error');
END;
/

DECLARE
  e_code          NUMBER;
  t_count         NUMBER;
  already_exists  EXCEPTION;
BEGIN
  e_code := 200;
  SELECT COUNT(*) INTO t_count 
    FROM user_tables 
   WHERE table_name = 'SUPPLIER';
  IF t_count = 0 THEN
    EXECUTE IMMEDIATE q'[
      CREATE TABLE supplier 
      (
        supplier_id      NUMBER(10)  NOT NULL,
        supplier_name    VARCHAR2(100)  NOT NULL,
        user_id_supplier NUMBER(10)  NOT NULL,
        CONSTRAINT supplier_PK PRIMARY KEY (supplier_id),
        CONSTRAINT supplier_user_details_FK FOREIGN KEY (user_id_supplier)
           REFERENCES user_details (user_id)
      )
    ]';
    DBMS_OUTPUT.PUT_LINE(e_code||': supplier created successfully');
  ELSE
    RAISE already_exists;
  END IF;
EXCEPTION
  WHEN already_exists THEN
    e_code := 100;
    DBMS_OUTPUT.PUT_LINE(e_code||': supplier already exists');
  WHEN OTHERS THEN
    e_code := 500;
    DBMS_OUTPUT.PUT_LINE(e_code||': unknown error');
END;
/

DECLARE
  e_code          NUMBER;
  t_count         NUMBER;
  already_exists  EXCEPTION;
BEGIN
  e_code := 200;
  SELECT COUNT(*) INTO t_count 
    FROM user_tables 
   WHERE table_name = 'FOOD_TABLE';
  IF t_count = 0 THEN
    EXECUTE IMMEDIATE q'[
      CREATE TABLE food_table 
      (
        food_id         NUMBER         NOT NULL,
        food_name       VARCHAR2(100)  NOT NULL,
        unit_of_measure VARCHAR2(10)   NOT NULL,
        supplier_id     NUMBER(10)     NOT NULL,
        quality         NUMBER         NOT NULL,
        total_quantity  NUMBER(10)     NOT NULL,
        user_id_gov     NUMBER(10)     NOT NULL,
        CONSTRAINT food_table_PK PRIMARY KEY (food_id),
        CONSTRAINT food_table_supplier_FK FOREIGN KEY (supplier_id)
           REFERENCES supplier (supplier_id),
        CONSTRAINT food_table_user_details_FK FOREIGN KEY (user_id_gov)
           REFERENCES user_details (user_id),
        CONSTRAINT chk_food_quantity CHECK (total_quantity > 0)
      )
    ]';
    DBMS_OUTPUT.PUT_LINE(e_code||': food_table created successfully');
  ELSE
    RAISE already_exists;
  END IF;
EXCEPTION
  WHEN already_exists THEN
    e_code := 100;
    DBMS_OUTPUT.PUT_LINE(e_code||': food_table already exists');
  WHEN OTHERS THEN
    e_code := 500;
    DBMS_OUTPUT.PUT_LINE(e_code||': unknown error');
END;
/

DECLARE
  e_code          NUMBER;
  t_count         NUMBER;
  already_exists  EXCEPTION;
BEGIN
  e_code := 200;
  SELECT COUNT(*) INTO t_count 
    FROM user_tables 
   WHERE table_name = 'MAIN_FOOD_DATA';
  IF t_count = 0 THEN
    EXECUTE IMMEDIATE q'[
      CREATE TABLE main_food_data 
      (
        main_id         NUMBER(10)  NOT NULL,
        total_quantity  NUMBER(10)  NOT NULL,
        unit_of_measure VARCHAR2(10)  NOT NULL,
        food_status     VARCHAR2(10 CHAR)  NOT NULL,
        food_id         NUMBER  NOT NULL,
        CONSTRAINT main_food_data_PK PRIMARY KEY (main_id),
        CONSTRAINT main_food_data_food_table_FK FOREIGN KEY (food_id)
           REFERENCES food_table (food_id),
        CONSTRAINT chk_main_food_quantity CHECK (total_quantity >= 0)
      )
    ]';
    DBMS_OUTPUT.PUT_LINE(e_code||': main_food_data created successfully');
  ELSE
    RAISE already_exists;
  END IF;
EXCEPTION
  WHEN already_exists THEN
    e_code := 100;
    DBMS_OUTPUT.PUT_LINE(e_code||': main_food_data already exists');
  WHEN OTHERS THEN
    e_code := 500;
    DBMS_OUTPUT.PUT_LINE(e_code||': unknown error');
END;
/

DECLARE
  e_code          NUMBER;
  t_count         NUMBER;
  already_exists  EXCEPTION;
BEGIN
  e_code := 200;
  SELECT COUNT(*) INTO t_count 
    FROM user_tables 
   WHERE table_name = 'NGO_REQUEST';
  IF t_count = 0 THEN
    EXECUTE IMMEDIATE q'[
      CREATE TABLE ngo_request 
      (
        ngo_request_id NUMBER(10)  NOT NULL,
        req_quantity   NUMBER(10)  NOT NULL,
        user_id_ngo    NUMBER(10)  NOT NULL,
        main_id        NUMBER(10)  NOT NULL,
        CONSTRAINT ngo_request_PK PRIMARY KEY (ngo_request_id),
        CONSTRAINT ngo_request_main_food_data_FK FOREIGN KEY (main_id)
           REFERENCES main_food_data (main_id),
        CONSTRAINT ngo_request_user_details_FK FOREIGN KEY (user_id_ngo)
           REFERENCES user_details (user_id),
        CONSTRAINT chk_ngo_request_quantity CHECK (req_quantity > 0)
      )
    ]';
    DBMS_OUTPUT.PUT_LINE(e_code||': ngo_request created successfully');
  ELSE
    RAISE already_exists;
  END IF;
EXCEPTION
  WHEN already_exists THEN
    e_code := 100;
    DBMS_OUTPUT.PUT_LINE(e_code||': ngo_request already exists');
  WHEN OTHERS THEN
    e_code := 500;
    DBMS_OUTPUT.PUT_LINE(e_code||': unknown error');
END;
/

SET SERVEROUTPUT ON;

--------------------------------------------------------------------------------
-- Drop LOGISTIC_STATUS_AUDIT table if it exists
--------------------------------------------------------------------------------
DECLARE
  e_code    NUMBER;
  t_count   NUMBER;
  no_exist  EXCEPTION;
BEGIN
  e_code := 200;
  SELECT COUNT(*) INTO t_count
    FROM user_tables
   WHERE table_name = 'LOGISTIC_STATUS_AUDIT';
  IF t_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP TABLE logistic_status_audit CASCADE CONSTRAINTS';
    DBMS_OUTPUT.PUT_LINE(e_code||': logistic_status_audit dropped successfully');
  ELSE
    RAISE no_exist;
  END IF;
EXCEPTION
  WHEN no_exist THEN
    e_code := 100;
    DBMS_OUTPUT.PUT_LINE(e_code||': logistic_status_audit not available');
  WHEN OTHERS THEN
    e_code := 500;
    DBMS_OUTPUT.PUT_LINE(e_code||': unknown error');
END;
/

--------------------------------------------------------------------------------
-- Create LOGISTIC_STATUS_AUDIT table if it does not exist
--------------------------------------------------------------------------------
DECLARE
  e_code         NUMBER;
  t_count        NUMBER;
  already_exists EXCEPTION;
BEGIN
  e_code := 200;
  SELECT COUNT(*) INTO t_count
    FROM user_tables
   WHERE table_name = 'LOGISTIC_STATUS_AUDIT';
  IF t_count = 0 THEN
    EXECUTE IMMEDIATE q'[
      CREATE TABLE logistic_status_audit (
        audit_id      NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
        logistics_id  NUMBER       NOT NULL,
        old_status    VARCHAR2(20) NOT NULL,
        new_status    VARCHAR2(20) NOT NULL,
        changed_by    VARCHAR2(100) NOT NULL,
        changed_at    TIMESTAMP    DEFAULT SYSTIMESTAMP NOT NULL
      )
    ]';
    DBMS_OUTPUT.PUT_LINE(e_code||': logistic_status_audit created successfully');
  ELSE
    RAISE already_exists;
  END IF;
EXCEPTION
  WHEN already_exists THEN
    e_code := 100;
    DBMS_OUTPUT.PUT_LINE(e_code||': logistic_status_audit already exists');
  WHEN OTHERS THEN
    e_code := 500;
    DBMS_OUTPUT.PUT_LINE(e_code||': unknown error');
END;
/


DECLARE
  e_code          NUMBER;
  t_count         NUMBER;
  already_exists  EXCEPTION;
BEGIN
  e_code := 200;
  SELECT COUNT(*) INTO t_count 
    FROM user_tables 
   WHERE table_name = 'LOGISTIC';
  IF t_count = 0 THEN
    EXECUTE IMMEDIATE q'[
      CREATE TABLE logistic 
      (
        logistics_id    NUMBER(10)  NOT NULL,
        driver          VARCHAR2(100 CHAR)  NOT NULL,
        delivery_status VARCHAR2(20)  NOT NULL,
        ngo_request_id  NUMBER(10)  NOT NULL,
        user_id         NUMBER(10)  NOT NULL,
        CONSTRAINT logistic_PK PRIMARY KEY (logistics_id),
        CONSTRAINT logistic_ngo_request_FK FOREIGN KEY (ngo_request_id)
           REFERENCES ngo_request (ngo_request_id),
        CONSTRAINT logistic_user_details_FK FOREIGN KEY (user_id)
           REFERENCES user_details (user_id)
      )
    ]';
    DBMS_OUTPUT.PUT_LINE(e_code||': logistic created successfully');
    EXECUTE IMMEDIATE q'[
      COMMENT ON COLUMN logistic.delivery_status 
        IS 'T = delivered, F = not delivered'
    ]';
  ELSE
    RAISE already_exists;
  END IF;
EXCEPTION
  WHEN already_exists THEN
    e_code := 100;
    DBMS_OUTPUT.PUT_LINE(e_code||': logistic already exists');
  WHEN OTHERS THEN
    e_code := 500;
    DBMS_OUTPUT.PUT_LINE(e_code||': unknown error');
END;
/

--===========================================================
-- CREATE SEQUENCES (if not exist)
--===========================================================
DECLARE
  e_code          NUMBER;
  t_count         NUMBER;
  already_exists  EXCEPTION;
BEGIN
  e_code := 200;
  SELECT COUNT(*) INTO t_count 
    FROM user_sequences 
   WHERE sequence_name = 'FOOD_SEQ';
  IF t_count = 0 THEN
    EXECUTE IMMEDIATE 'CREATE SEQUENCE food_seq START WITH 1 INCREMENT BY 1';
    DBMS_OUTPUT.PUT_LINE(e_code||': food_seq created successfully');
  ELSE
    RAISE already_exists;
  END IF;
EXCEPTION
  WHEN already_exists THEN
    e_code := 100;
    DBMS_OUTPUT.PUT_LINE(e_code||': food_seq already exists');
  WHEN OTHERS THEN
    e_code := 500;
    DBMS_OUTPUT.PUT_LINE(e_code||': unknown error');
END;
/

DECLARE
  e_code          NUMBER;
  t_count         NUMBER;
  already_exists  EXCEPTION;
BEGIN
  e_code := 200;
  SELECT COUNT(*) INTO t_count 
    FROM user_sequences 
   WHERE sequence_name = 'LOGISTIC_SEQ';
  IF t_count = 0 THEN
    EXECUTE IMMEDIATE 'CREATE SEQUENCE logistic_seq START WITH 1 INCREMENT BY 1';
    DBMS_OUTPUT.PUT_LINE(e_code||': logistic_seq created successfully');
  ELSE
    RAISE already_exists;
  END IF;
EXCEPTION
  WHEN already_exists THEN
    e_code := 100;
    DBMS_OUTPUT.PUT_LINE(e_code||': logistic_seq already exists');
  WHEN OTHERS THEN
    e_code := 500;
    DBMS_OUTPUT.PUT_LINE(e_code||': unknown error');
END;
/

DECLARE
  e_code          NUMBER;
  t_count         NUMBER;
  already_exists  EXCEPTION;
BEGIN
  e_code := 200;
  SELECT COUNT(*) INTO t_count 
    FROM user_sequences 
   WHERE sequence_name = 'MAIN_FOOD_SEQ';
  IF t_count = 0 THEN
    EXECUTE IMMEDIATE 'CREATE SEQUENCE main_food_seq START WITH 1 INCREMENT BY 1';
    DBMS_OUTPUT.PUT_LINE(e_code||': main_food_seq created successfully');
  ELSE
    RAISE already_exists;
  END IF;
EXCEPTION
  WHEN already_exists THEN
    e_code := 100;
    DBMS_OUTPUT.PUT_LINE(e_code||': main_food_seq already exists');
  WHEN OTHERS THEN
    e_code := 500;
    DBMS_OUTPUT.PUT_LINE(e_code||': unknown error');
END;
/

DECLARE
  e_code          NUMBER;
  t_count         NUMBER;
  already_exists  EXCEPTION;
BEGIN
  e_code := 200;
  SELECT COUNT(*) INTO t_count 
    FROM user_sequences 
   WHERE sequence_name = 'NGO_REQUEST_SEQ';
  IF t_count = 0 THEN
    EXECUTE IMMEDIATE 'CREATE SEQUENCE ngo_request_seq START WITH 1 INCREMENT BY 1';
    DBMS_OUTPUT.PUT_LINE(e_code||': ngo_request_seq created successfully');
  ELSE
    RAISE already_exists;
  END IF;
EXCEPTION
  WHEN already_exists THEN
    e_code := 100;
    DBMS_OUTPUT.PUT_LINE(e_code||': ngo_request_seq already exists');
  WHEN OTHERS THEN
    e_code := 500;
    DBMS_OUTPUT.PUT_LINE(e_code||': unknown error');
END;
/

DECLARE
  e_code          NUMBER;
  t_count         NUMBER;
  already_exists  EXCEPTION;
BEGIN
  e_code := 200;
  SELECT COUNT(*) INTO t_count 
    FROM user_sequences 
   WHERE sequence_name = 'SUPPLIER_SEQ';
  IF t_count = 0 THEN
    EXECUTE IMMEDIATE 'CREATE SEQUENCE supplier_seq START WITH 1 INCREMENT BY 1';
    DBMS_OUTPUT.PUT_LINE(e_code||': supplier_seq created successfully');
  ELSE
    RAISE already_exists;
  END IF;
EXCEPTION
  WHEN already_exists THEN
    e_code := 100;
    DBMS_OUTPUT.PUT_LINE(e_code||': supplier_seq already exists');
  WHEN OTHERS THEN
    e_code := 500;
    DBMS_OUTPUT.PUT_LINE(e_code||': unknown error');
END;
/

DECLARE
  e_code          NUMBER;
  t_count         NUMBER;
  already_exists  EXCEPTION;
BEGIN
  e_code := 200;
  SELECT COUNT(*) INTO t_count 
    FROM user_sequences 
   WHERE sequence_name = 'USER_DETAILS_SEQ';
  IF t_count = 0 THEN
    EXECUTE IMMEDIATE 'CREATE SEQUENCE user_details_seq START WITH 1 INCREMENT BY 1';
    DBMS_OUTPUT.PUT_LINE(e_code||': user_details_seq created successfully');
  ELSE
    RAISE already_exists;
  END IF;
EXCEPTION
  WHEN already_exists THEN
    e_code := 100;
    DBMS_OUTPUT.PUT_LINE(e_code||': user_details_seq already exists');
  WHEN OTHERS THEN
    e_code := 500;
    DBMS_OUTPUT.PUT_LINE(e_code||': unknown error');
END;
/

DECLARE
  e_code          NUMBER;
  t_count         NUMBER;
  already_exists  EXCEPTION;
BEGIN
  e_code := 200;
  SELECT COUNT(*) INTO t_count 
    FROM user_sequences 
   WHERE sequence_name = 'USER_ROLE_SEQ';
  IF t_count = 0 THEN
    EXECUTE IMMEDIATE 'CREATE SEQUENCE user_role_seq START WITH 1 INCREMENT BY 1';
    DBMS_OUTPUT.PUT_LINE(e_code||': user_role_seq created successfully');
  ELSE
    RAISE already_exists;
  END IF;
EXCEPTION
  WHEN already_exists THEN
    e_code := 100;
    DBMS_OUTPUT.PUT_LINE(e_code||': user_role_seq already exists');
  WHEN OTHERS THEN
    e_code := 500;
    DBMS_OUTPUT.PUT_LINE(e_code||': unknown error');
END;
/