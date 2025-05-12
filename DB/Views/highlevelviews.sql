-- 100 => if the information exist already
-- 200 => success execution
-- 500 => unknown error

SET SERVEROUTPUT ON;
  
-- 1. v_food_supplier
DECLARE
  e_code          NUMBER;
  t_count         NUMBER;
  already_exists  EXCEPTION;
BEGIN
  e_code := 200;
  SELECT COUNT(*) INTO t_count
    FROM user_views
   WHERE view_name = 'V_FOOD_SUPPLIER';
  IF t_count = 0 THEN
    EXECUTE IMMEDIATE q'[
      CREATE OR REPLACE VIEW v_food_supplier AS
      SELECT
        food_id,
        food_name,
        unit_of_measure,
        total_quantity,
        supplier_id
      FROM food_table
    ]';
    DBMS_OUTPUT.PUT_LINE(e_code||': v_food_supplier created successfully');
  ELSE
    RAISE already_exists;
  END IF;
EXCEPTION
  WHEN already_exists THEN
    e_code := 100;
    DBMS_OUTPUT.PUT_LINE(e_code||': v_food_supplier already exists');
  WHEN OTHERS THEN
    e_code := 500;
    DBMS_OUTPUT.PUT_LINE(e_code||': unknown error');
END;
/

-- 2. govt_food_view
DECLARE
  e_code          NUMBER;
  t_count         NUMBER;
  already_exists  EXCEPTION;
BEGIN
  e_code := 200;
  SELECT COUNT(*) INTO t_count
    FROM user_views
   WHERE view_name = 'GOVT_FOOD_VIEW';
  IF t_count = 0 THEN
    EXECUTE IMMEDIATE q'[
      CREATE OR REPLACE VIEW govt_food_view AS
      SELECT
        food_id,
        food_name,
        quality,
        user_id_gov
      FROM food_table
    ]';
    DBMS_OUTPUT.PUT_LINE(e_code||': govt_food_view created successfully');
  ELSE
    RAISE already_exists;
  END IF;
EXCEPTION
  WHEN already_exists THEN
    e_code := 100;
    DBMS_OUTPUT.PUT_LINE(e_code||': govt_food_view already exists');
  WHEN OTHERS THEN
    e_code := 500;
    DBMS_OUTPUT.PUT_LINE(e_code||': unknown error');
END;
/

-- 3. v_ngo_request_status
DECLARE
  e_code          NUMBER;
  t_count         NUMBER;
  already_exists  EXCEPTION;
BEGIN
  e_code := 200;
  SELECT COUNT(*) INTO t_count
    FROM user_views
   WHERE view_name = 'V_NGO_REQUEST_STATUS';
  IF t_count = 0 THEN
    EXECUTE IMMEDIATE q'[
      CREATE OR REPLACE VIEW v_ngo_request_status AS
            SELECT
              nr.ngo_request_id,
              nr.req_quantity,
              nr.user_id_ngo,
              nr.main_id,
              NVL(l.delivery_status, 'Unknown') AS delivery_status
            FROM
              ngo_request nr
              LEFT JOIN logistic l
                ON nr.ngo_request_id = l.ngo_request_id;
    ]';
    DBMS_OUTPUT.PUT_LINE(e_code||': v_ngo_request_status created successfully');
  ELSE
    RAISE already_exists;
  END IF;
EXCEPTION
  WHEN already_exists THEN
    e_code := 100;
    DBMS_OUTPUT.PUT_LINE(e_code||': v_ngo_request_status already exists');
  WHEN OTHERS THEN
    e_code := 500;
    DBMS_OUTPUT.PUT_LINE(e_code||': unknown error');
END;
/
