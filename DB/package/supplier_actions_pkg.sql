--------------------------------------------------------------------------------
-- Package spec: supplier_actions_pkg
--------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE supplier_actions_pkg IS

  -- 1) Print all rows from v_food_supplier, supplier, and food_table
  PROCEDURE view_all_data;

  -- 2) Add a food item for a supplier‐role user.
  --    If the user has no supplier record yet, register them using p_supplier_name.
  --    Returns in p_e_code:
  --      200 → success (new food_id)
  --      100 → validation/missing‐user error
  --      500 → unknown error
  PROCEDURE add_food_item(
    p_username        IN VARCHAR2 DEFAULT USER,
    p_supplier_name   IN VARCHAR2,
    p_food_name       IN VARCHAR2,
    p_unit_of_measure IN VARCHAR2,
    p_total_quantity  IN NUMBER,
    p_e_code          OUT NUMBER
  );

END supplier_actions_pkg;
/
  
--------------------------------------------------------------------------------
-- Package body: supplier_actions_pkg
--------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY supplier_actions_pkg IS

  ----------------------------------------------------------------------------
  PROCEDURE view_all_data IS
    v_cnt NUMBER;
  BEGIN
    -- v_food_supplier
    SELECT COUNT(*) INTO v_cnt FROM v_food_supplier;
    IF v_cnt = 0 THEN
      DBMS_OUTPUT.PUT_LINE('v_food_supplier: (no rows)');
    ELSE
      DBMS_OUTPUT.PUT_LINE('v_food_supplier:');
      FOR r IN (SELECT * FROM v_food_supplier) LOOP
        DBMS_OUTPUT.PUT_LINE(
          '  ['||r.food_id||'] '
          || r.food_name || ', '
          || r.unit_of_measure || ', qty=' 
          || r.total_quantity || ', sup='
          || r.supplier_id
        );
      END LOOP;
    END IF;

    -- supplier
    SELECT COUNT(*) INTO v_cnt FROM supplier;
    IF v_cnt = 0 THEN
      DBMS_OUTPUT.PUT_LINE('supplier: (no rows)');
    ELSE
      DBMS_OUTPUT.PUT_LINE('supplier:');
      FOR r IN (SELECT * FROM supplier) LOOP
        DBMS_OUTPUT.PUT_LINE(
          '  ['||r.supplier_id||'] '
          || r.supplier_name || ', user_id='
          || r.user_id_supplier
        );
      END LOOP;
    END IF;

    -- food_table
    SELECT COUNT(*) INTO v_cnt FROM food_table;
    IF v_cnt = 0 THEN
      DBMS_OUTPUT.PUT_LINE('food_table: (no rows)');
    ELSE
      DBMS_OUTPUT.PUT_LINE('food_table:');
      FOR r IN (SELECT * FROM food_table) LOOP
        DBMS_OUTPUT.PUT_LINE(
          '  ['||r.food_id||'] '
          || r.food_name || ', uom='
          || r.unit_of_measure || ', qty='
          || r.total_quantity || ', sup='
          || r.supplier_id || ', quality='
          || r.quality || ', gov='
          || r.user_id_gov
        );
      END LOOP;
    END IF;
  END view_all_data;

  ----------------------------------------------------------------------------
  PROCEDURE add_food_item(
    p_username        IN VARCHAR2 DEFAULT USER,
    p_supplier_name   IN VARCHAR2,
    p_food_name       IN VARCHAR2,
    p_unit_of_measure IN VARCHAR2,
    p_total_quantity  IN NUMBER,
    p_e_code          OUT NUMBER
  ) IS
    e_code           NUMBER := 200;
    v_user_id        NUMBER;
    v_supplier_id    NUMBER;
    created_supplier BOOLEAN := FALSE;
  BEGIN
    -- A) Validate supplier‐role user
    BEGIN
      SELECT ud.user_id
        INTO v_user_id
        FROM user_details ud
        JOIN user_role ur ON ud.user_role_role_id = ur.role_id
       WHERE ud.user_name = p_username
         AND UPPER(ur.role_name) = 'SUPPLIER';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        e_code := 100;
        DBMS_OUTPUT.PUT_LINE(e_code||': user "'||p_username||'" not found or not a supplier');
        p_e_code := e_code;
        RETURN;
    END;

    -- B) Find or register supplier record
    BEGIN
      SELECT supplier_id
        INTO v_supplier_id
        FROM supplier
       WHERE user_id_supplier = v_user_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- first‐time registration
        IF p_supplier_name IS NULL OR LENGTH(p_supplier_name) > 100 THEN
          e_code := 100;
          DBMS_OUTPUT.PUT_LINE(e_code||': invalid supplier name');
          p_e_code := e_code;
          RETURN;
        END IF;
        INSERT INTO supplier(supplier_id, supplier_name, user_id_supplier)
        VALUES (supplier_seq.NEXTVAL, p_supplier_name, v_user_id)
        RETURNING supplier_id INTO v_supplier_id;
        created_supplier := TRUE;
    END;

    -- C) Validate food inputs
    IF p_food_name IS NULL OR LENGTH(p_food_name) > 100 THEN
      e_code := 100;
      DBMS_OUTPUT.PUT_LINE(e_code||': invalid food name');
      p_e_code := e_code;
      RETURN;
    END IF;
    IF p_unit_of_measure IS NULL OR LENGTH(p_unit_of_measure) > 10 THEN
      e_code := 100;
      DBMS_OUTPUT.PUT_LINE(e_code||': invalid unit_of_measure');
      p_e_code := e_code;
      RETURN;
    END IF;
    IF p_total_quantity IS NULL OR p_total_quantity <= 0 THEN
      e_code := 100;
      DBMS_OUTPUT.PUT_LINE(e_code||': invalid total_quantity');
      p_e_code := e_code;
      RETURN;
    END IF;

    -- D) Insert via the view trigger
    INSERT INTO v_food_supplier(
      food_name, unit_of_measure, total_quantity, supplier_id
    ) VALUES (
      p_food_name,
      p_unit_of_measure,
      p_total_quantity,
      v_supplier_id
    );

    -- E) Fetch new food_id
    SELECT food_seq.CURRVAL
      INTO p_e_code
      FROM dual;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('200: food added (food_id='||p_e_code||')');
    RETURN;

  EXCEPTION
    WHEN OTHERS THEN
      -- Clean up new supplier if inserted
      IF created_supplier THEN
        DELETE FROM supplier WHERE supplier_id = v_supplier_id;
      END IF;
      ROLLBACK;
      e_code := 500;
      DBMS_OUTPUT.PUT_LINE('500: unknown error');
      p_e_code := e_code;
  END add_food_item;

END supplier_actions_pkg;
/
