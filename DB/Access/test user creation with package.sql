--drop user logi_user;
--drop user gov_user;
--drop user sup_user;
--drop user ngo_user;
select * from user_details;
--===============================================
-- TEST SCRIPT FOR USER_MGMT_PKG.ONBOARD_USER
--===============================================
SET SERVEROUTPUT ON;
/

-- 1) Invalid role
DECLARE
  l_code NUMBER;
BEGIN
  user_mgmt_pkg.onboard_user(
    p_role           => 'BADROLE',
    p_username       => 'bob',
    p_password       => 'Bob@1234',
    p_first_name     => 'Bob',
    p_last_name      => 'Builder',
    p_address        => '456 Elm St',
    p_contact_number => '1234567890',
    p_e_code         => l_code
  );
  DBMS_OUTPUT.PUT_LINE('Test 1 (Invalid Role)     => Expected 100, Got '||l_code);
END;
/

-- 2) Invalid username (starts with digit)
DECLARE
  l_code NUMBER;
BEGIN
  user_mgmt_pkg.onboard_user(
    p_role           => 'SUPPLIER',
    p_username       => '1alice',
    p_password       => 'Alice@123',
    p_first_name     => 'Alice',
    p_last_name      => 'Wonder',
    p_address        => '789 Oak St',
    p_contact_number => '2345678901',
    p_e_code         => l_code
  );
  DBMS_OUTPUT.PUT_LINE('Test 2 (Invalid Username)=> Expected 100, Got '||l_code);
END;
/

-- 3) Invalid password (too short / missing complexity)

DECLARE
  l_code NUMBER;
BEGIN
  user_mgmt_pkg.onboard_user(
    p_role           => 'NGO',
    p_username       => 'charlie',
    p_password       => 'weak1',
    p_first_name     => 'Charlie',
    p_last_name      => 'Brown',
    p_address        => '123 Peanuts Rd',
    p_contact_number => '3456789012',
    p_e_code         => l_code
  );
  DBMS_OUTPUT.PUT_LINE('Test 3 (Invalid Password)=> Expected 100, Got '||l_code);
END;
/

-- 4) Successful onboarding: GOVT
DECLARE
  l_code NUMBER;
BEGIN
  user_mgmt_pkg.onboard_user(
    p_role           => 'GOVT',
    p_username       => 'gov_user',
    p_password       => 'G0vt$ecure123',
    p_first_name     => 'Gov',
    p_last_name      => 'Agent',
    p_address        => '1 Government Plaza',
    p_contact_number => '4567890123',
    p_e_code         => l_code
  );
  DBMS_OUTPUT.PUT_LINE('Test 4 (Govt Success)     => Expected user_id, Got '||l_code);
END;
/

-- 5) Duplicate GOVT user
DECLARE
  l_code NUMBER;
BEGIN
  user_mgmt_pkg.onboard_user(
    p_role           => 'GOVT',
    p_username       => 'gov_user',
    p_password       => 'G0vt$ecure123',
    p_first_name     => 'Gov',
    p_last_name      => 'Agent',
    p_address        => '1 Government Plaza',
    p_contact_number => '4567890123',
    p_e_code         => l_code
  );
  DBMS_OUTPUT.PUT_LINE('Test 5 (Duplicate User)   => Expected 100, Got '||l_code);
END;
/

-- 6) Successful onboarding: LOGISTICS
DECLARE
  l_code NUMBER;
BEGIN
  user_mgmt_pkg.onboard_user(
    p_role           => 'LOGISTICS',
    p_username       => 'logi_user',
    p_password       => 'L0gi_user$ecure123',
    p_first_name     => 'Logi',
    p_last_name      => 'Stick',
    p_address        => '99 Truck Blvd',
    p_contact_number => '5678901234',
    p_e_code         => l_code
  );
  DBMS_OUTPUT.PUT_LINE('Test 6 (Logistics Success)=> Expected user_id, Got '||l_code);
END;
/

-- 7) Successful onboarding: NGO
DECLARE
  l_code NUMBER;
BEGIN
  user_mgmt_pkg.onboard_user(
    p_role           => 'NGO',
    p_username       => 'ngo_user',
    p_password       => 'N9O#secure123',
    p_first_name     => 'Ngo',
    p_last_name      => 'Agent',
    p_address        => '77 Charity Ln',
    p_contact_number => '6789012345',
    p_e_code         => l_code
  );
  DBMS_OUTPUT.PUT_LINE('Test 7 (NGO Success)      => Expected user_id, Got '||l_code);
END;
/

-- 8) Successful onboarding: SUPPLIER
DECLARE
  l_code NUMBER;
BEGIN
  user_mgmt_pkg.onboard_user(
    p_role           => 'SUPPLIER',
    p_username       => 'sup_user',
    p_password       => 'SupP1!er123456',
    p_first_name     => 'Sup',
    p_last_name      => 'Plier',
    p_address        => '33 Market St',
    p_contact_number => '7890123456',
    p_e_code         => l_code
  );
  DBMS_OUTPUT.PUT_LINE('Test 8 (Supplier Success) => Expected user_id, Got '||l_code);
END;
/