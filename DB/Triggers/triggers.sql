-- 100 => if the information exist already
-- 200 => success execution
-- 500 => unknown error


SET SERVEROUTPUT ON;

--------------------------------------------------------------------------------
-- 1) (Re)create trg_instead_of_food_supplier
--------------------------------------------------------------------------------
DECLARE
  e_code NUMBER := 200;
BEGIN
  EXECUTE IMMEDIATE q'[
    CREATE OR REPLACE TRIGGER trg_instead_of_food_supplier
    INSTEAD OF INSERT ON v_food_supplier
    FOR EACH ROW
    DECLARE
      v_gov_id NUMBER;
    BEGIN
      BEGIN
        SELECT user_id INTO v_gov_id
          FROM user_details
         WHERE UPPER(user_name) = 'GOV_USER';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          DBMS_OUTPUT.PUT_LINE('100: GOV_USER not found; cannot set USER_ID_GOV');
          RETURN;
      END;

      INSERT INTO food_table (
        food_id, food_name, unit_of_measure,
        total_quantity, supplier_id, quality, user_id_gov
      ) VALUES (
        NVL(:NEW.food_id, food_seq.NEXTVAL),
        :NEW.food_name,
        :NEW.unit_of_measure,
        :NEW.total_quantity,
        :NEW.supplier_id,
        0,
        v_gov_id
      );
    END;
  ]';
  DBMS_OUTPUT.PUT_LINE(e_code||': trg_instead_of_food_supplier created successfully');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('500: unknown error creating trg_instead_of_food_supplier');
END;
/

--------------------------------------------------------------------------------
-- 2) (Re)create food_table_after_update
--------------------------------------------------------------------------------
DECLARE
  e_code NUMBER := 200;
BEGIN
  EXECUTE IMMEDIATE q'[
    CREATE OR REPLACE TRIGGER food_table_after_update
    AFTER UPDATE OF quality, user_id_gov ON food_table
    FOR EACH ROW
    BEGIN
      IF :NEW.quality > 5 THEN
        MERGE INTO main_food_data m
        USING (
          SELECT 
            :NEW.food_id        AS food_id,
            :NEW.total_quantity AS total_quantity,
            :NEW.unit_of_measure AS unit_of_measure
          FROM dual
        ) src
        ON (m.food_id = src.food_id)
        WHEN MATCHED THEN
          UPDATE SET
            m.total_quantity  = src.total_quantity,
            m.unit_of_measure = src.unit_of_measure,
            m.food_status     = 'Available'
        WHEN NOT MATCHED THEN
          INSERT (main_id, total_quantity, unit_of_measure, food_status, food_id)
          VALUES (
            main_food_seq.NEXTVAL,
            src.total_quantity,
            src.unit_of_measure,
            'Available',
            src.food_id
          );
      END IF;
    END;
  ]';
  DBMS_OUTPUT.PUT_LINE(e_code||': food_table_after_update created successfully');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('500: unknown error creating food_table_after_update');
END;
/

--------------------------------------------------------------------------------
-- 3) (Re)create check_quantity_before_request
--------------------------------------------------------------------------------
DECLARE
  e_code NUMBER := 200;
BEGIN
  EXECUTE IMMEDIATE q'[
    CREATE OR REPLACE TRIGGER check_quantity_before_request
    BEFORE INSERT ON ngo_request
    FOR EACH ROW
    DECLARE
      v_available NUMBER;
    BEGIN
      SELECT total_quantity
        INTO v_available
        FROM main_food_data
       WHERE main_id = :NEW.main_id;

      IF :NEW.req_quantity > v_available THEN
        RAISE_APPLICATION_ERROR(-20000, 'Requested quantity exceeds available stock.');
      END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Invalid MAIN_ID: No matching stock available.');
    END;
  ]';
  DBMS_OUTPUT.PUT_LINE(e_code||': check_quantity_before_request created successfully');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('500: unknown error creating check_quantity_before_request');
END;
/

--------------------------------------------------------------------------------
-- 4) (Re)create trg_logistic_status_audit
--------------------------------------------------------------------------------
SET SERVEROUTPUT ON;

DECLARE
  e_code NUMBER := 200;
BEGIN
  EXECUTE IMMEDIATE q'[
    CREATE OR REPLACE TRIGGER trg_logistic_status_audit
    AFTER UPDATE OF delivery_status ON logistic
    FOR EACH ROW
    BEGIN
      INSERT INTO logistic_status_audit (
        logistics_id,
        old_status,
        new_status,
        changed_by
      ) VALUES (
        :OLD.logistics_id,
        :OLD.delivery_status,
        :NEW.delivery_status,
        SYS_CONTEXT('USERENV','SESSION_USER')
      );
    END trg_logistic_status_audit;
  ]';
  DBMS_OUTPUT.PUT_LINE(e_code||': trg_logistic_status_audit created successfully');
EXCEPTION
  WHEN OTHERS THEN
    e_code := 500;
    DBMS_OUTPUT.PUT_LINE(
      e_code||': unknown error creating trg_logistic_status_audit ');
   
END;
/


