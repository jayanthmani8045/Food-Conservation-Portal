SET SERVEROUTPUT ON;
  
--------------------------------------------------------------------------------
-- Test 1: Initial view_all_data (expect no rows or existing state)
--------------------------------------------------------------------------------
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Test 1: Initial view_all_data ---');
  food_admin.ngo_actions_pkg.view_all_data;
END;
/
  
--------------------------------------------------------------------------------
-- Test 2: request_food with non‑existent user → e_code=100
--------------------------------------------------------------------------------
DECLARE
  l_code NUMBER;
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Test 2: invalid user ---');
  food_admin.ngo_actions_pkg.request_food(
    p_username     => 'no_such_user',
    p_main_id      => 2,
    p_req_quantity => 5,
    p_e_code       => l_code
  );
  DBMS_OUTPUT.PUT_LINE('Returned e_code='||l_code);
END;
/
  
--------------------------------------------------------------------------------
-- Test 3: request_food with bad main_id → e_code=100
--------------------------------------------------------------------------------
DECLARE
  l_code NUMBER;
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Test 3: non‑existent main_id ---');
  food_admin.ngo_actions_pkg.request_food(
    p_username     => 'ngo_user',
    p_main_id      => 9999,
    p_req_quantity => 5,
    p_e_code       => l_code
  );
  DBMS_OUTPUT.PUT_LINE('Returned e_code='||l_code);
END;
/
  
--------------------------------------------------------------------------------
-- Test 4: request_food with invalid quantity (≤0) → e_code=100
--------------------------------------------------------------------------------
DECLARE
  l_code NUMBER;
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Test 4: zero quantity ---');
  food_admin.ngo_actions_pkg.request_food(
    p_username     => 'ngo_user',
    p_main_id      => 1,
    p_req_quantity => 40,
    p_e_code       => l_code
  );
  DBMS_OUTPUT.PUT_LINE('Returned e_code='||l_code);
END;
/
  
--------------------------------------------------------------------------------
-- Pre‑setup: ensure there is at least one main_food_data row with known stock
--------------------------------------------------------------------------------
-- Assume main_id=1 exists with total_quantity=10 from prior tests
-- If not, insert or adjust accordingly.

--------------------------------------------------------------------------------
-- Test 5: valid request within stock → e_code=200
--------------------------------------------------------------------------------
DECLARE
  l_code NUMBER;
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Test 5: valid request (within stock) ---');
  food_admin.ngo_actions_pkg.request_food(
    p_username     => 'ngo_user',
    p_main_id      => 1,
    p_req_quantity => 2,
    p_e_code       => l_code
  );
  DBMS_OUTPUT.PUT_LINE('Returned e_code='||l_code);
END;
/

--------------------------------------------------------------------------------
-- Test 5: valid request within stock → e_code=200
--------------------------------------------------------------------------------
DECLARE
  l_code NUMBER;
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Test 5: valid request (within stock) ---');
  food_admin.ngo_actions_pkg.request_food(
    p_username     => 'ngo_user',
    p_main_id      => 2,
    p_req_quantity => 1,
    p_e_code       => l_code
  );
  DBMS_OUTPUT.PUT_LINE('Returned e_code='||l_code);
END;
/
  
--------------------------------------------------------------------------------
-- Test 6: request exceeding available stock → e_code=500 (trigger raises)
--------------------------------------------------------------------------------
DECLARE
  l_code NUMBER;
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Test 6: exceeding stock ---');
  food_admin.ngo_actions_pkg.request_food(
    p_username     => 'ngo_user',
    p_main_id      => 1,
    p_req_quantity => 1000,  -- larger than available
    p_e_code       => l_code
  );
  DBMS_OUTPUT.PUT_LINE('Returned e_code='||l_code);
END;
/
  
--------------------------------------------------------------------------------
-- Test 7: view_all_data after requests
--------------------------------------------------------------------------------
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Test 7: view_all_data after requests ---');
  food_admin.ngo_actions_pkg.view_all_data;     
END;
/
