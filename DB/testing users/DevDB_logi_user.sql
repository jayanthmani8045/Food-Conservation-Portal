SET SERVEROUTPUT ON;

---------------------------------------------------
-- Test 1: view_all_data initially (should be empty)
---------------------------------------------------
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Test 1: view_all_data initially ---');
  food_admin.logistic_actions_pkg.view_all_data;
END;
/
  
-------------------------------------------------------------
-- Test 2: view_pending_requests initially (no NGO requests)
-------------------------------------------------------------
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Test 2: view_pending_requests initially ---');
  food_admin.logistic_actions_pkg.view_pending_requests;
END;
/
  
-------------------------------------------------------------
-- (Assumes that an NGO request with ID=1 exists and is unassigned)
-------------------------------------------------------------

---------------------------------------------------
-- Test 3: assign_request with invalid user → 100
---------------------------------------------------
DECLARE
  l_code NUMBER;
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Test 3: invalid user ---');
  food_admin.logistic_actions_pkg.assign_request(
    p_username       => 'no_such_user',
    p_ngo_request_id => 1,
    p_e_code         => l_code
  );
  DBMS_OUTPUT.PUT_LINE('Returned e_code='||l_code||CHR(10));
END;
/
  
--------------------------------------------------------------
-- Test 4: assign_request with non‑existent request → 100
--------------------------------------------------------------
DECLARE
  l_code NUMBER;
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Test 4: bad request_id ---');
  food_admin.logistic_actions_pkg.assign_request(
    p_username       => 'logistics_user',
    p_ngo_request_id => 9999,
    p_e_code         => l_code
  );
  DBMS_OUTPUT.PUT_LINE('Returned e_code='||l_code||CHR(10));
END;
/
  
-------------------------------------------------------------------
-- Test 5: assign_request valid → 200 (captures logistics_id)
-------------------------------------------------------------------
DECLARE
  l_log_id NUMBER;
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Test 5: valid assign_request ---');
  food_admin.logistic_actions_pkg.assign_request(
    p_username       => 'logi_user',
    p_ngo_request_id => 1,
    p_e_code         => l_log_id
  );
  DBMS_OUTPUT.PUT_LINE('Returned logistics_id='||l_log_id||CHR(10));
  -- Use this l_log_id in subsequent tests
END;
/
  
--------------------------------------------------------
-- Test 6: re‑assign same request → 100
--------------------------------------------------------
DECLARE
  l_code NUMBER;
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Test 6: re‑assign same id ---');
  food_admin.logistic_actions_pkg.assign_request(
    p_username       => 'logi_user',
    p_ngo_request_id => 1,
    p_e_code         => l_code
  );
  DBMS_OUTPUT.PUT_LINE('Returned e_code='||l_code||CHR(10));
END;
/
  
--------------------------------------------------------
-- Test 7: view_all_data after assignment
--------------------------------------------------------
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Test 7: view_all_data after assign ---');
  food_admin.logistic_actions_pkg.view_all_data;
END;
/
  
---------------------------------------------------------------
-- Test 8: update_delivery_status with invalid user → 100
---------------------------------------------------------------
DECLARE
  l_code NUMBER;
  l_log_id NUMBER := &l_log_id;  -- substitute the ID from Test 5
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Test 8: invalid user update ---');
  food_admin.logistic_actions_pkg.update_delivery_status(
    p_logistics_id => l_log_id,
    p_username     => 'no_such_user',
    p_e_code       => l_code
  );
  DBMS_OUTPUT.PUT_LINE('Returned e_code='||l_code||CHR(10));
END;
/
  
---------------------------------------------------------------
-- Test 9: update_delivery_status wrong user → 100
---------------------------------------------------------------
DECLARE
  l_code NUMBER;
  l_log_id NUMBER := &l_log_id;
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Test 9: wrong user update ---');
  food_admin.logistic_actions_pkg.update_delivery_status(
    p_logistics_id => l_log_id,
    p_username     => 'supplier_user',
    p_e_code       => l_code
  );
  DBMS_OUTPUT.PUT_LINE('Returned e_code='||l_code||CHR(10));
END;
/
  
---------------------------------------------------------------
-- Test 10: update_delivery_status valid → 200
---------------------------------------------------------------
DECLARE
  l_code NUMBER;
  l_log_id NUMBER := &l_log_id;
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Test 10: valid update_delivery_status ---');
  food_admin.logistic_actions_pkg.update_delivery_status(
    p_logistics_id => l_log_id,
    p_username     => 'logi_user',
    p_e_code       => l_code
  );
  DBMS_OUTPUT.PUT_LINE('Returned e_code='||l_code||CHR(10));
END;
/
  
---------------------------------------------------------------
-- Test 11: view_all_data after delivery
---------------------------------------------------------------
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Test 11: view_all_data after completed ---');
  food_admin.logistic_actions_pkg.view_all_data;
END;
/
