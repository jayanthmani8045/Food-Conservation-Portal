SET SERVEROUTPUT ON;
---------------------------
-- 1) Initial view (empty)
---------------------------
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Test 1: initial view_all_data ---');
  food_admin.supplier_actions_pkg.view_all_data;
END;
/

----------------------------------------------------
-- 2) add_food_item with non‑existent user → 100
----------------------------------------------------
DECLARE
  l_code NUMBER;
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Test 2: bad user ---');
  food_admin.supplier_actions_pkg.add_food_item(
    p_username        => 'no_such_user',
    p_supplier_name   => 'Should Not Matter',
    p_food_name       => 'ItemX',
    p_unit_of_measure => 'KG',
    p_total_quantity  => 10,
    p_e_code          => l_code
  );
  DBMS_OUTPUT.PUT_LINE('Returned e_code='||l_code||CHR(10));
END;
/

---------------------------------------------------------------------
-- 3) add_food_item first time for valid sup_user → registers + add
---------------------------------------------------------------------
DECLARE
  l_code NUMBER;
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Test 3: first‐time for supplier_user ---');
  food_admin.supplier_actions_pkg.add_food_item(
    p_username        => 'sup_user',
    p_supplier_name   => 'Acme Supplies Ltd.',
    p_food_name       => 'oranges',
    p_unit_of_measure => 'KG',
    p_total_quantity  => 200,
    p_e_code          => l_code
  );
  DBMS_OUTPUT.PUT_LINE('Returned e_code='||l_code||CHR(10));
END;
/
--select * from user_details;
-------------------------------------------------------
-- 4) View data after one insertion
-------------------------------------------------------
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Test 4: view after one insert ---');
  food_admin.supplier_actions_pkg.view_all_data;
END;
/

--------------------------------------------------------------------
-- 5) add_food_item again for same user → uses existing supplier_id
--------------------------------------------------------------------
DECLARE
  l_code NUMBER;
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Test 5: second insert for same user ---');
  food_admin.supplier_actions_pkg.add_food_item(
    p_username        => 'sup_user',
    p_supplier_name   => 'Ignored Name',
    p_food_name       => 'Bananas',
    p_unit_of_measure => 'KG',
    p_total_quantity  => 20,
    p_e_code          => l_code
  );
  DBMS_OUTPUT.PUT_LINE('Returned e_code='||l_code||CHR(10));
END;
/

-------------------------------------------------------
-- 6) View data after two items
-------------------------------------------------------
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Test 6: view after two inserts ---');
  food_admin.supplier_actions_pkg.view_all_data;
END;
/

--------------------------------------------------------
-- 7) invalid supplier_name too long → 100 (on first‐time)
--------------------------------------------------------
DECLARE
  l_code NUMBER;
  long_name VARCHAR2(200) := RPAD('X',150,'X');
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Test 7: invalid supplier_name length ---');
  -- force new registration for a different supplier_user2
  food_admin.supplier_actions_pkg.add_food_item(
    p_username        => 'sup_user2',
    p_supplier_name   => long_name,
    p_food_name       => 'Carrots',
    p_unit_of_measure => 'KG',
    p_total_quantity  => 5,
    p_e_code          => l_code
  );
  DBMS_OUTPUT.PUT_LINE('Returned e_code='||l_code||CHR(10));
END;
/

------------------------------------------------
-- 8) invalid total_quantity (0) → 100
------------------------------------------------
DECLARE
  l_code NUMBER;
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Test 8: zero quantity ---');
  food_admin.supplier_actions_pkg.add_food_item(
    p_username        => 'sup_user',
    p_supplier_name   => 'Ignored',
    p_food_name       => 'Tomatoes',
    p_unit_of_measure => 'KG',
    p_total_quantity  => 0,
    p_e_code          => l_code
  );
  DBMS_OUTPUT.PUT_LINE('Returned e_code='||l_code||CHR(10));
END;
/

------------------------------------------------
-- 9) invalid food name too long → 100
------------------------------------------------
DECLARE
  l_code NUMBER;
  long_food VARCHAR2(200) := RPAD('F',150,'F');
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Test 9: invalid food_name length ---');
  food_admin.supplier_actions_pkg.add_food_item(
    p_username        => 'sup_user',
    p_supplier_name   => 'Ignored',
    p_food_name       => long_food,
    p_unit_of_measure => 'KG',
    p_total_quantity  => 10,
    p_e_code          => l_code
  );
  DBMS_OUTPUT.PUT_LINE('Returned e_code='||l_code||CHR(10));
END;
/

---------------------------
-- 10) final view 
---------------------------
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Test 1: final view_all_data ---');
  food_admin.supplier_actions_pkg.view_all_data;
END;
/
