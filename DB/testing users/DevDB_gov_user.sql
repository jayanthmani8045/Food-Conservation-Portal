SET SERVEROUTPUT ON;
  
-------------------------------------------------------------------
-- 1) Initial view: no rows (or existing data)
-------------------------------------------------------------------
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Test 1: Initial view_all_data ---');
  food_admin.govt_actions_pkg.view_all_data;
END;
/
  
-------------------------------------------------------------------
-- 2) update_quality with non‐existent user → 100
-------------------------------------------------------------------
DECLARE
  l_code NUMBER;
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Test 2: invalid user ---');
  food_admin.govt_actions_pkg.update_quality(
    p_username => 'no_such_user',
    p_food_id  => 1,
    p_quality  => 10,
    p_e_code   => l_code
  );
  DBMS_OUTPUT.PUT_LINE('Returned e_code='||l_code||CHR(10));
END;
/
  
-------------------------------------------------------------------
-- 3) update_quality with valid gov_user but bad food_id → 100
-------------------------------------------------------------------
DECLARE
  l_code NUMBER;
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Test 3: non‐existent food_id ---');
  food_admin.govt_actions_pkg.update_quality(
    p_username => 'gov_user',
    p_food_id  => 1,
    p_quality  => 7,
    p_e_code   => l_code
  );
  DBMS_OUTPUT.PUT_LINE('Returned e_code='||l_code||CHR(10));
END;
/
  
-------------------------------------------------------------------
-- 4) update_quality with valid user & food_id but invalid quality → 100
-------------------------------------------------------------------
DECLARE
  l_code NUMBER;
  -- assume that food_id=1 exists from prior supplier tests
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Test 4: invalid (negative) quality ---');
  food_admin.govt_actions_pkg.update_quality(
    p_username => 'gov_user',
    p_food_id  => 2,
    p_quality  => 4,
    p_e_code   => l_code
  );
  DBMS_OUTPUT.PUT_LINE('Returned e_code='||l_code||CHR(10));
END;
/
  
-------------------------------------------------------------------
-- 5) update_quality success → 200
-------------------------------------------------------------------
DECLARE
  l_code NUMBER;
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Test 5: valid update_quality ---');
  food_admin.govt_actions_pkg.update_quality(
    p_username => 'gov_user',
    p_food_id  => 1,
    p_quality  => 10,
    p_e_code   => l_code
  );
  DBMS_OUTPUT.PUT_LINE('Returned e_code='||l_code||CHR(10));
END;
/
  
-------------------------------------------------------------------
-- 6) view_all_data after update
-------------------------------------------------------------------
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Test 6: view_all_data after quality update ---');
  food_admin.govt_actions_pkg.view_all_data;
END;
/
  
-------------------------------------------------------------------
-- 7) update_quality repeated on the same food → 200
-------------------------------------------------------------------
DECLARE
  l_code NUMBER;
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Test 7: repeated update_quality ---');
  food_admin.govt_actions_pkg.update_quality(
    p_username => 'gov_user',
    p_food_id  => 2,
    p_quality  => 10,
    p_e_code   => l_code
  );
  DBMS_OUTPUT.PUT_LINE('Returned e_code='||l_code||CHR(10));
END;
/
  
-------------------------------------------------------------------
-- 8) update_quality with NULL quality → 100
-------------------------------------------------------------------
DECLARE
  l_code NUMBER;
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Test 8: NULL quality ---');
  food_admin.govt_actions_pkg.update_quality(
    p_username => 'gov_user',
    p_food_id  => 10,
    p_quality  => NULL,
    p_e_code   => l_code
  );
  DBMS_OUTPUT.PUT_LINE('Returned e_code='||l_code||CHR(10));
END;
/

-------------------------------------------------------------------
-- 9) final view: no rows (or existing data)
-------------------------------------------------------------------
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Test 9: final view_all_data ---');
  food_admin.govt_actions_pkg.view_all_data;
END;
/
