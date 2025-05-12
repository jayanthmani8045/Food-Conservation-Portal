--------------------------------------------------------------------------------
-- Package: ngo_actions_pkg
--------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE ngo_actions_pkg IS

  PROCEDURE view_all_data;

  PROCEDURE request_food(
    p_username     IN  VARCHAR2 default user,
    p_main_id      IN  NUMBER,
    p_req_quantity IN  NUMBER,
    p_e_code       OUT NUMBER
  );

END ngo_actions_pkg;
/
  
--------------------------------------------------------------------------------
-- Body of ngo_actions_pkg
--------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY ngo_actions_pkg IS

  --------------------------------------------------------------------------
  PROCEDURE view_all_data IS
    v_cnt NUMBER;
  BEGIN
    -- MAIN_FOOD_DATA (only quality ≥5 via join, and in‑stock)
    SELECT COUNT(*) INTO v_cnt
      FROM main_food_data m
      JOIN food_table     f ON f.food_id = m.food_id
     WHERE f.quality >= 5
       AND m.total_quantity > 0;
    IF v_cnt = 0 THEN
      DBMS_OUTPUT.PUT_LINE('main_food_data: (no available rows)');
    ELSE
      DBMS_OUTPUT.PUT_LINE('main_food_data:');
      FOR r IN (
        SELECT 
          m.main_id,
          m.total_quantity,
          m.unit_of_measure,
          m.food_status,
          m.food_id
        FROM main_food_data m
        JOIN food_table     f ON f.food_id = m.food_id
        WHERE f.quality >= 5
          AND m.total_quantity > 0
      ) LOOP
        DBMS_OUTPUT.PUT_LINE(
          '['||r.main_id||'] qty='||r.total_quantity
          ||', uom='||r.unit_of_measure
          ||', status='||r.food_status
          ||', food_id='||r.food_id
        );
      END LOOP;
    END IF;

    -- NGO_REQUEST
    SELECT COUNT(*) INTO v_cnt FROM ngo_request;
    IF v_cnt = 0 THEN
      DBMS_OUTPUT.PUT_LINE('ngo_request: (no rows)');
    ELSE
      DBMS_OUTPUT.PUT_LINE('ngo_request:');
      FOR r IN (
        SELECT ngo_request_id, req_quantity, user_id_ngo, main_id
          FROM ngo_request
      ) LOOP
        DBMS_OUTPUT.PUT_LINE(
          '['||r.ngo_request_id||'] qty='||r.req_quantity
          ||', user_id_ngo='||r.user_id_ngo
          ||', main_id='||r.main_id
        );
      END LOOP;
    END IF;

    -- V_NGO_REQUEST_STATUS
    SELECT COUNT(*) INTO v_cnt FROM v_ngo_request_status;
    IF v_cnt = 0 THEN
      DBMS_OUTPUT.PUT_LINE('v_ngo_request_status: (no rows)');
    ELSE
      DBMS_OUTPUT.PUT_LINE('v_ngo_request_status:');
      FOR r IN (
        SELECT ngo_request_id, req_quantity, user_id_ngo, main_id, delivery_status
          FROM v_ngo_request_status
      ) LOOP
        DBMS_OUTPUT.PUT_LINE(
          '['||r.ngo_request_id||'] qty='||r.req_quantity
          ||', user_id_ngo='||r.user_id_ngo
          ||', main_id='||r.main_id
          ||', status='||r.delivery_status
        );
      END LOOP;
    END IF;
  END view_all_data;

  --------------------------------------------------------------------------
  PROCEDURE request_food(
    p_username     IN  VARCHAR2 default user,
    p_main_id      IN  NUMBER,
    p_req_quantity IN  NUMBER,
    p_e_code       OUT NUMBER
  ) IS
    e_code      NUMBER := 200;
    v_user_id   NUMBER;
    v_quality   NUMBER;
    v_available NUMBER;
  BEGIN
    -- 1) Validate NGO user
    BEGIN
      SELECT ud.user_id
        INTO v_user_id
        FROM user_details ud
        JOIN user_role    ur ON ud.user_role_role_id = ur.role_id
       WHERE ud.user_name = p_username
         AND UPPER(ur.role_name) = 'NGO';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        e_code := 100;
        DBMS_OUTPUT.PUT_LINE(e_code||': user "'||p_username||'" not found or not NGO');
        p_e_code := e_code;
        RETURN;
    END;

    -- 2) Fetch quality & available quantity (and check existence)
    BEGIN
      SELECT f.quality, m.total_quantity
        INTO v_quality, v_available
        FROM main_food_data m
        JOIN food_table     f ON f.food_id = m.food_id
       WHERE m.main_id = p_main_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        e_code := 100;
        DBMS_OUTPUT.PUT_LINE(e_code||': main_id '||p_main_id||' not found');
        p_e_code := e_code;
        RETURN;
    END;

    -- 2a) Reject if quality too low
    IF v_quality < 5 THEN
      e_code := 100;
      DBMS_OUTPUT.PUT_LINE(e_code||': food_id '||p_main_id||' quality below 5');
      p_e_code := e_code;
      RETURN;
    END IF;

    -- 3) Validate requested quantity > 0
    IF p_req_quantity IS NULL OR p_req_quantity <= 0 THEN
      e_code := 100;
      DBMS_OUTPUT.PUT_LINE(e_code||': invalid req_quantity');
      p_e_code := e_code;
      RETURN;
    END IF;

    -- 4) Validate against available stock
    IF p_req_quantity > v_available THEN
      e_code := 100;
      DBMS_OUTPUT.PUT_LINE(e_code||': requested quantity exceeds available stock');
      p_e_code := e_code;
      RETURN;
    END IF;

    -- 5) Insert the request
    INSERT INTO ngo_request(
      ngo_request_id,
      req_quantity,
      user_id_ngo,
      main_id
    ) VALUES (
      ngo_request_seq.NEXTVAL,
      p_req_quantity,
      v_user_id,
      p_main_id
    )
    RETURNING ngo_request_id INTO p_e_code;

    -- 6) Decrement stock immediately
    UPDATE main_food_data
       SET total_quantity = total_quantity - p_req_quantity
     WHERE main_id = p_main_id;

    -- 7) Finalize
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('200: ngo_request created (ID='||p_e_code||')');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      e_code := 500;
      DBMS_OUTPUT.PUT_LINE(e_code||': unknown error'||sqlerrm);
      p_e_code := e_code;
  END request_food;

END ngo_actions_pkg;
/
