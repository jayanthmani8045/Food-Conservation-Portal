-- Insert roles into USER_ROLE table:
INSERT INTO user_role (role_id, role_name)
VALUES (1, 'SUPPLIER');

INSERT INTO user_role (role_id, role_name)
VALUES (2, 'GOVT_OFFICIAL');

INSERT INTO user_role (role_id, role_name)
VALUES (3, 'NGO');

INSERT INTO user_role (role_id, role_name)
VALUES (4, 'LOGISTICS');

COMMIT;

-- Insert sample users into USER_DETAILS table:
INSERT INTO user_details (user_id, user_name, password, first_name, last_name, address, contact_number, user_role_role_id)
VALUES (user_details_seq.NEXTVAL, 'supplier_user', 'Passw0rd$1234', 'Alice', 'Supplier', '123 Supplier St', 1234567890, 1);

INSERT INTO user_details (user_id, user_name, password, first_name, last_name, address, contact_number, user_role_role_id)
VALUES (user_details_seq.NEXTVAL, 'govt_official', 'pass2', 'Bob', 'Official', '456 Govt Ave', 2345678901, 2);

INSERT INTO user_details (user_id, user_name, password, first_name, last_name, address, contact_number, user_role_role_id)
VALUES (user_details_seq.NEXTVAL, 'ngo_user', 'pass3', 'Carol', 'NGO', '789 NGO Rd', 3456789012, 3);

INSERT INTO user_details (user_id, user_name, password, first_name, last_name, address, contact_number, user_role_role_id)
VALUES (user_details_seq.NEXTVAL, 'logistics_user', 'pass4', 'Dave', 'Logistics', '101 Logistics Blvd', 4567890123, 4);

INSERT INTO user_details (user_id, user_name, password, first_name, last_name, address, contact_number, user_role_role_id)
VALUES (user_details_seq.NEXTVAL, 'default_gov_user', 'default_pass', 'Default', 'Gov', 'Govt Address', 1234567890, 
        (SELECT role_id FROM user_role WHERE role_name = 'GOVT_OFFICIAL'));
INSERT INTO user_details (user_id, user_name, password, first_name, last_name, address, contact_number, user_role_role_id)
VALUES (user_details_seq.NEXTVAL, 'supplier_user2', 'Passw0rd$1234', 'Alice', 'Supplier', '123 Supplier St', 1234567890, 1);

INSERT INTO user_details (user_id, user_name, password, first_name, last_name, address, contact_number, user_role_role_id)
VALUES (user_details_seq.NEXTVAL, 'supplier_user3', 'Passw0rd$1234', 'Alice', 'Supplier', '123 Supplier St', 1234567890, 1);
COMMIT;