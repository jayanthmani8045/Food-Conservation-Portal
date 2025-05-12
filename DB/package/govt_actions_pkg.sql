--------------------------------------------------------------------------------
-- Package: govt_actions_pkg
-- 
--  • view_all_data       => dump GOVT_FOOD_VIEW
--  • update_quality      => set quality and user_id_gov for a food_id
--    Returns in p_e_code:
--      200 → success
--      100 → validation error (bad user, food_id, quality)
--      500 → unknown error
--------------------------------------------------------------------------------

CREATE OR REPLACE PACKAGE govt_actions_pkg IS

  PROCEDURE view_all_data;

  PROCEDURE update_quality(
    p_username  IN VARCHAR2 default user,
    p_food_id   IN NUMBER,
    p_quality   IN NUMBER,
    p_e_code    OUT NUMBER
  );

END govt_actions_pkg;
/
  
--------------------------------------------------------------------------------
-- Body of govt_actions_pkg
--------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY govt_actions_pkg IS

  --------------------------------------------------------------------------
  PROCEDURE view_all_data IS
  BEGIN
    FOR r IN (SELECT * FROM govt_food_view) LOOP
      DBMS_OUTPUT.PUT_LINE(
        '['||r.food_id||'] '
        ||r.food_name||', quality='||r.quality
        ||', gov_user_id='||r.user_id_gov
      );
    END LOOP;
  END view_all_data;

  --------------------------------------------------------------------------
  PROCEDURE update_quality(
    p_username  IN VARCHAR2 default user,
    p_food_id   IN NUMBER,
    p_quality   IN NUMBER,
    p_e_code    OUT NUMBER
  ) IS
    e_code        NUMBER := 200;
    v_user_id     NUMBER;
    v_count       NUMBER;
  BEGIN
    -- 1) Validate that p_username exists and has GOVT role
    BEGIN
      SELECT ud.user_id
        INTO v_user_id
        FROM user_details ud
        JOIN user_role ur ON ud.user_role_role_id = ur.role_id
       WHERE ud.user_name = p_username
         AND UPPER(ur.role_name) = 'GOVT';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        e_code := 100;
        DBMS_OUTPUT.PUT_LINE(e_code||': user "'||p_username||'" not found or not GOVT');
        p_e_code := e_code;
        RETURN;
    END;

    -- 2) Validate food_id exists
    SELECT COUNT(*) INTO v_count
      FROM food_table
     WHERE food_id = p_food_id;
    IF v_count = 0 THEN
      e_code := 100;
      DBMS_OUTPUT.PUT_LINE(e_code||': food_id='||p_food_id||' not found');
      p_e_code := e_code;
      RETURN;
    END IF;

    -- 3) Validate quality (non‐negative)
    IF p_quality IS NULL OR p_quality < 0 THEN
      e_code := 100;
      DBMS_OUTPUT.PUT_LINE(e_code||': invalid quality value (Allowed values: 1 - 10');
      p_e_code := e_code;
      RETURN;
    END IF;

    -- 4) Perform the update via the view (updates FOOD_TABLE)
    UPDATE food_table
       SET quality     = p_quality,
           user_id_gov = v_user_id
     WHERE food_id = p_food_id;

    IF SQL%ROWCOUNT = 0 THEN
      e_code := 100;
      DBMS_OUTPUT.PUT_LINE(e_code||': update failed for food_id='||p_food_id);
      p_e_code := e_code;
      RETURN;
    END IF;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('200: food_id='||p_food_id||' updated to quality='||p_quality);
    p_e_code := 200;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      e_code := 500;
      DBMS_OUTPUT.PUT_LINE(e_code||': unknown error');
      p_e_code := e_code;
  END update_quality;

END govt_actions_pkg;
/
