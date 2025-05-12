--------------------------------------------------------------------------------
-- Complete Package: logistic_actions_pkg
--------------------------------------------------------------------------------

-- 1) Package spec
CREATE OR REPLACE PACKAGE logistic_actions_pkg IS

  -- Show all logistics assignments
  PROCEDURE view_all_data;

  -- Show all unassigned NGO requests (delivery_status = 'Unknown' in v_ngo_request_status)
  PROCEDURE view_pending_requests;

  -- Logistics user “claims” an NGO request; returns new logistics_id in p_e_code
  PROCEDURE assign_request(
    p_username       IN VARCHAR2 default user,
    p_ngo_request_id IN NUMBER,
    p_e_code         OUT NUMBER
  );

  -- Mark a claimed delivery as delivered; returns same logistics_id in p_e_code
  PROCEDURE update_delivery_status(
    p_logistics_id IN NUMBER,
    p_username     IN VARCHAR2,
    p_e_code       OUT NUMBER
  );

END logistic_actions_pkg;
/
  
-- 2) Package body
CREATE OR REPLACE PACKAGE BODY logistic_actions_pkg IS

  --------------------------------------------------------------------------
  PROCEDURE view_all_data IS
    v_cnt NUMBER;
  BEGIN
    SELECT COUNT(*) INTO v_cnt FROM logistic;
    IF v_cnt = 0 THEN
      DBMS_OUTPUT.PUT_LINE('logistic: (no rows)');
    ELSE
      DBMS_OUTPUT.PUT_LINE('logistic:');
      FOR r IN (SELECT *
                  FROM logistic
                  ORDER BY logistics_id) LOOP
        DBMS_OUTPUT.PUT_LINE(
          '['||r.logistics_id||'] '
          ||'driver="'||r.driver||'", '
          ||'status='||r.delivery_status||', '
          ||'ngo_req='||r.ngo_request_id||', '
          ||'user_id='||r.user_id
        );
      END LOOP;
    END IF;
  END view_all_data;

  --------------------------------------------------------------------------
  PROCEDURE view_pending_requests IS
    v_cnt NUMBER;
  BEGIN
    SELECT COUNT(*) INTO v_cnt
      FROM v_ngo_request_status
     WHERE delivery_status = 'Unknown';

    IF v_cnt = 0 THEN
      DBMS_OUTPUT.PUT_LINE('No pending requests');
    ELSE
      DBMS_OUTPUT.PUT_LINE('Pending NGO requests:');
      FOR r IN (
        SELECT ngo_request_id, req_quantity, user_id_ngo, main_id
          FROM v_ngo_request_status
         WHERE delivery_status = 'Unknown'
         ORDER BY ngo_request_id
      ) LOOP
        DBMS_OUTPUT.PUT_LINE(
          '['||r.ngo_request_id||'] '
          ||'qty='||r.req_quantity||', '
          ||'ngo_id='||r.user_id_ngo||', '
          ||'main_id='||r.main_id
        );
      END LOOP;
    END IF;
  END view_pending_requests;

  --------------------------------------------------------------------------
  PROCEDURE assign_request(
    p_username       IN VARCHAR2,
    p_ngo_request_id IN NUMBER,
    p_e_code         OUT NUMBER
  ) IS
    e_code    NUMBER := 200;
    v_user_id NUMBER;
    v_exists  NUMBER;
  BEGIN
    -- 1) Validate logistics user
    BEGIN
      SELECT ud.user_id
        INTO v_user_id
        FROM user_details ud
        JOIN user_role   ur
          ON ud.user_role_role_id = ur.role_id
       WHERE ud.user_name = p_username
         AND UPPER(ur.role_name) = 'LOGISTICS';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        e_code := 100;
        DBMS_OUTPUT.PUT_LINE(e_code||': user "'||p_username||'" not found or not LOGISTICS');
        p_e_code := e_code;
        RETURN;
    END;

    -- 2) Validate request exists and is unassigned
    SELECT COUNT(*) INTO v_exists
      FROM ngo_request nr
      LEFT JOIN logistic lg
        ON nr.ngo_request_id = lg.ngo_request_id
     WHERE nr.ngo_request_id = p_ngo_request_id
       AND lg.logistics_id IS NULL;
    IF v_exists = 0 THEN
      e_code := 100;
      DBMS_OUTPUT.PUT_LINE(e_code
        ||': request_id='||p_ngo_request_id||' not found or already assigned'
      );
      p_e_code := e_code;
      RETURN;
    END IF;

    -- 3) Claim it
    INSERT INTO logistic(
      logistics_id,
      driver,
      delivery_status,
      ngo_request_id,
      user_id
    ) VALUES (
      logistic_seq.NEXTVAL,
      p_username,
      'pending',
      p_ngo_request_id,
      v_user_id
    )
    RETURNING logistics_id INTO p_e_code;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('200: request assigned (ID='||p_e_code||')');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      e_code := 500;
      DBMS_OUTPUT.PUT_LINE(e_code||': unknown error');
      p_e_code := e_code;
  END assign_request;

  --------------------------------------------------------------------------
  PROCEDURE update_delivery_status(
    p_logistics_id IN NUMBER,
    p_username     IN VARCHAR2,
    p_e_code       OUT NUMBER
  ) IS
    e_code    NUMBER := 200;
    v_user_id NUMBER;
    v_count   NUMBER;
  BEGIN
    -- 1) Validate logistics user
    BEGIN
      SELECT ud.user_id
        INTO v_user_id
        FROM user_details ud
        JOIN user_role   ur
          ON ud.user_role_role_id = ur.role_id
       WHERE ud.user_name = p_username
         AND UPPER(ur.role_name) = 'LOGISTICS';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        e_code := 100;
        DBMS_OUTPUT.PUT_LINE(e_code||': user "'||p_username||'" not found or not LOGISTICS');
        p_e_code := e_code;
        RETURN;
    END;

    -- 2) Validate assignment belongs to this user & is pending
    SELECT COUNT(*) INTO v_count
      FROM logistic
     WHERE logistics_id   = p_logistics_id
       AND delivery_status = 'pending'
       AND driver          = p_username;
    IF v_count = 0 THEN
      e_code := 100;
      DBMS_OUTPUT.PUT_LINE(e_code
        ||': invalid or non‑pending logistics_id='||p_logistics_id
      );
      p_e_code := e_code;
      RETURN;
    END IF;

    -- 3) Mark delivered
    UPDATE logistic
       SET delivery_status = 'delivered'
     WHERE logistics_id = p_logistics_id;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('200: delivery completed (ID='||p_logistics_id||')');
    p_e_code := p_logistics_id;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      e_code := 500;
      DBMS_OUTPUT.PUT_LINE(e_code||': unknown error');
      p_e_code := e_code;
  END update_delivery_status;

END logistic_actions_pkg;
/
