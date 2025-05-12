-- 1) Package specification
CREATE OR REPLACE PACKAGE user_mgmt_pkg IS
  PROCEDURE onboard_user(
    p_role           IN  VARCHAR2,
    p_username       IN  VARCHAR2 default user,
    p_password       IN  VARCHAR2,
    p_first_name     IN  VARCHAR2,
    p_last_name      IN  VARCHAR2,
    p_address        IN  VARCHAR2,
    p_contact_number IN  VARCHAR2,
    p_e_code         OUT NUMBER
  );
END user_mgmt_pkg;
/
  
-- 2) Package body
CREATE OR REPLACE PACKAGE BODY user_mgmt_pkg IS

  PROCEDURE onboard_user(
    p_role           IN  VARCHAR2,
    p_username       IN  VARCHAR2,
    p_password       IN  VARCHAR2,
    p_first_name     IN  VARCHAR2,
    p_last_name      IN  VARCHAR2,
    p_address        IN  VARCHAR2,
    p_contact_number IN  VARCHAR2,
    p_e_code         OUT NUMBER
  ) IS
    e_code           NUMBER := 200;
    v_user_id        NUMBER;
    v_role_id        NUMBER;
    v_exists         NUMBER;
    v_role_count     NUMBER;
    created_user     BOOLEAN := FALSE;

    -- validation exceptions
    invalid_role       EXCEPTION;
    invalid_username   EXCEPTION;
    invalid_password   EXCEPTION;
    invalid_fname      EXCEPTION;
    invalid_lname      EXCEPTION;
    invalid_address    EXCEPTION;
    invalid_contact    EXCEPTION;
  BEGIN
    -----------------------------------------------------------------
    -- A) Seed default roles ONCE
    -----------------------------------------------------------------
    SELECT COUNT(*) INTO v_role_count FROM user_role;
    IF v_role_count = 0 THEN
      INSERT INTO user_role(role_id, role_name)
        VALUES (user_role_seq.NEXTVAL, 'SUPPLIER');
      INSERT INTO user_role(role_id, role_name)
        VALUES (user_role_seq.NEXTVAL, 'LOGISTICS');
      INSERT INTO user_role(role_id, role_name)
        VALUES (user_role_seq.NEXTVAL, 'GOVT');
      INSERT INTO user_role(role_id, role_name)
        VALUES (user_role_seq.NEXTVAL, 'NGO');
      COMMIT;
    END IF;

    -----------------------------------------------------------------
    -- B) Role validation & lookup
    -----------------------------------------------------------------
    IF UPPER(p_role) NOT IN ('SUPPLIER','LOGISTICS','GOVT','NGO') THEN
      RAISE invalid_role;
    END IF;
    SELECT role_id INTO v_role_id
      FROM user_role
     WHERE role_name = UPPER(p_role);

    -----------------------------------------------------------------
    -- C) Username validation
    -----------------------------------------------------------------
    IF p_username IS NULL
       OR LENGTH(p_username) > 30
       OR REGEXP_LIKE(p_username, '[^A-Za-z0-9_$#]')
       OR REGEXP_LIKE(SUBSTR(p_username,1,1), '^[0-9]') THEN
      RAISE invalid_username;
    END IF;

    -----------------------------------------------------------------
    -- D) Password complexity (≥12 chars, upper, lower, digit, special)
    -----------------------------------------------------------------
    IF p_password IS NULL
       OR LENGTH(p_password) < 12
       OR NOT REGEXP_LIKE(p_password,'[A-Z]')
       OR NOT REGEXP_LIKE(p_password,'[a-z]')
       OR NOT REGEXP_LIKE(p_password,'[0-9]')
       OR NOT REGEXP_LIKE(p_password,'[^A-Za-z0-9]') THEN
      RAISE invalid_password;
    END IF;

    -----------------------------------------------------------------
    -- E) First/Last name & address validation
    -----------------------------------------------------------------
    IF p_first_name IS NULL OR LENGTH(p_first_name) > 100 THEN
      RAISE invalid_fname;
    END IF;
    IF p_last_name IS NULL OR LENGTH(p_last_name) > 100 THEN
      RAISE invalid_lname;
    END IF;
    IF p_address IS NULL OR LENGTH(p_address) > 100 THEN
      RAISE invalid_address;
    END IF;

    -----------------------------------------------------------------
    -- F) Contact number validation (digits only, ≤10)
    -----------------------------------------------------------------
    IF p_contact_number IS NULL
       OR NOT REGEXP_LIKE(p_contact_number, '^[0-9]{1,10}$') THEN
      RAISE invalid_contact;
    END IF;

    -----------------------------------------------------------------
    -- G) Existing‐user check
    -----------------------------------------------------------------
    SELECT COUNT(*) INTO v_exists
      FROM all_users
     WHERE username = UPPER(p_username);
    IF v_exists > 0 THEN
      e_code := 100;
      DBMS_OUTPUT.PUT_LINE(e_code||': user "'||p_username||'" already exists');
      p_e_code := e_code;
      RETURN;
    END IF;

    -----------------------------------------------------------------
    -- H) Create the schema user
    -----------------------------------------------------------------
    EXECUTE IMMEDIATE
      'CREATE USER '
      || DBMS_ASSERT.SIMPLE_SQL_NAME(p_username)
      || ' IDENTIFIED BY "'
      || REPLACE(p_password, '"', '""')
      || '"';
    created_user := TRUE;

    -----------------------------------------------------------------
    -- I) Grant CREATE SESSION
    -----------------------------------------------------------------
    EXECUTE IMMEDIATE
      'GRANT CREATE SESSION TO '
      || DBMS_ASSERT.SIMPLE_SQL_NAME(p_username);

    -----------------------------------------------------------------
    -- J) Grant role‑specific object privileges
    -----------------------------------------------------------------
    IF UPPER(p_role) = 'GOVT' THEN
      EXECUTE IMMEDIATE
        'GRANT SELECT, UPDATE ON food_admin.govt_food_view TO '
        || DBMS_ASSERT.SIMPLE_SQL_NAME(p_username);
      EXECUTE IMMEDIATE
        'GRANT EXECUTE ON food_admin.govt_actions_pkg TO '
        || DBMS_ASSERT.SIMPLE_SQL_NAME(p_username);
        
    ELSIF UPPER(p_role) = 'LOGISTICS' THEN
      EXECUTE IMMEDIATE
        'GRANT INSERT, SELECT, UPDATE, DELETE ON food_admin.logistic TO '
        || DBMS_ASSERT.SIMPLE_SQL_NAME(p_username);
      EXECUTE IMMEDIATE
        'GRANT SELECT ON food_admin.logistic_seq TO '
        || DBMS_ASSERT.SIMPLE_SQL_NAME(p_username);
      EXECUTE IMMEDIATE
        'GRANT EXECUTE ON food_admin.logistic_actions_pkg TO '
        || DBMS_ASSERT.SIMPLE_SQL_NAME(p_username);
        
    ELSIF UPPER(p_role) = 'NGO' THEN
      EXECUTE IMMEDIATE
        'GRANT SELECT ON food_admin.main_food_data TO '
        || DBMS_ASSERT.SIMPLE_SQL_NAME(p_username);
      EXECUTE IMMEDIATE
        'GRANT INSERT, SELECT, UPDATE, DELETE ON food_admin.ngo_request TO '
        || DBMS_ASSERT.SIMPLE_SQL_NAME(p_username);
      EXECUTE IMMEDIATE
        'GRANT SELECT ON food_admin.ngo_request_seq TO '
        || DBMS_ASSERT.SIMPLE_SQL_NAME(p_username);
      EXECUTE IMMEDIATE
        'GRANT SELECT ON food_admin.v_ngo_request_status TO '
        || DBMS_ASSERT.SIMPLE_SQL_NAME(p_username);
      EXECUTE IMMEDIATE
        'GRANT EXECUTE ON food_admin.ngo_actions_pkg TO '
        || DBMS_ASSERT.SIMPLE_SQL_NAME(p_username);

    ELSE  -- SUPPLIER
      EXECUTE IMMEDIATE
        'GRANT SELECT, INSERT, UPDATE, DELETE ON food_admin.v_food_supplier TO '
        || DBMS_ASSERT.SIMPLE_SQL_NAME(p_username);
      EXECUTE IMMEDIATE
        'GRANT SELECT, INSERT, UPDATE, DELETE ON food_admin.supplier TO '
        || DBMS_ASSERT.SIMPLE_SQL_NAME(p_username);
      EXECUTE IMMEDIATE
        'GRANT SELECT ON food_admin.food_table TO '
        || DBMS_ASSERT.SIMPLE_SQL_NAME(p_username);
      EXECUTE IMMEDIATE
        'GRANT SELECT ON food_admin.supplier_seq TO '
        || DBMS_ASSERT.SIMPLE_SQL_NAME(p_username);
      EXECUTE IMMEDIATE
        'GRANT SELECT ON food_admin.user_details TO '
        || DBMS_ASSERT.SIMPLE_SQL_NAME(p_username);
      EXECUTE IMMEDIATE
        'GRANT EXECUTE ON food_admin.supplier_actions_pkg TO '
        || DBMS_ASSERT.SIMPLE_SQL_NAME(p_username);
    END IF;

    -----------------------------------------------------------------
    -- K) Insert into USER_DETAILS (disable FK first)
    -----------------------------------------------------------------
    v_user_id := user_details_seq.NEXTVAL;
    EXECUTE IMMEDIATE
      'ALTER TABLE user_details DISABLE CONSTRAINT user_details_user_role_FK';
    INSERT INTO user_details(
      user_id,
      user_name,
      password,
      first_name,
      last_name,
      address,
      contact_number,
      user_role_role_id
    ) VALUES (
      v_user_id,
      p_username,
      p_password,
      p_first_name,
      p_last_name,
      p_address,
      TO_NUMBER(p_contact_number),
      v_role_id
    );
    EXECUTE IMMEDIATE
      'ALTER TABLE user_details ENABLE CONSTRAINT user_details_user_role_FK';

    -----------------------------------------------------------------
    -- L) Success: commit and return
    -----------------------------------------------------------------
    COMMIT;
    p_e_code := v_user_id;
    DBMS_OUTPUT.PUT_LINE(
      e_code||': onboarded "'||p_username||'" (ID='||v_user_id||')'
    );
    RETURN;

  EXCEPTION
    WHEN invalid_role THEN
      ROLLBACK;
      e_code := 100;
      DBMS_OUTPUT.PUT_LINE(e_code||': invalid role "'||p_role||'"');
      p_e_code := e_code;
    WHEN invalid_username THEN
      ROLLBACK;
      e_code := 100;
      DBMS_OUTPUT.PUT_LINE(e_code||': invalid username "'||p_username||'"');
      p_e_code := e_code;
    WHEN invalid_password THEN
      ROLLBACK;
      e_code := 100;
      DBMS_OUTPUT.PUT_LINE(
        e_code||': password does not meet complexity requirements'
      );
      p_e_code := e_code;
    WHEN invalid_fname THEN
      ROLLBACK;
      e_code := 100;
      DBMS_OUTPUT.PUT_LINE(e_code||': invalid first name');
      p_e_code := e_code;
    WHEN invalid_lname THEN
      ROLLBACK;
      e_code := 100;
      DBMS_OUTPUT.PUT_LINE(e_code||': invalid last name');
      p_e_code := e_code;
    WHEN invalid_address THEN
      ROLLBACK;
      e_code := 100;
      DBMS_OUTPUT.PUT_LINE(e_code||': invalid address');
      p_e_code := e_code;
    WHEN invalid_contact THEN
      ROLLBACK;
      e_code := 100;
      DBMS_OUTPUT.PUT_LINE(e_code||': invalid contact number');
      p_e_code := e_code;
    WHEN OTHERS THEN
      -- drop orphaned schema user
      IF created_user THEN
        BEGIN
          EXECUTE IMMEDIATE
            'DROP USER '
            || DBMS_ASSERT.SIMPLE_SQL_NAME(p_username)
            || ' CASCADE';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
      END IF;
      ROLLBACK;
      e_code := 500;
      DBMS_OUTPUT.PUT_LINE(e_code||': unknown error');
      p_e_code := e_code;
  END onboard_user;

END user_mgmt_pkg;
/
