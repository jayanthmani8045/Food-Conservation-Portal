-- 100 => if the information exist already
-- 200 => success execution
-- 500 => unknown error
SET SERVEROUTPUT ON;

-- 1. Drop USER food_admin (if it exists)
DECLARE
  e_code        NUMBER;
  t_count       NUMBER;
  user_missing  EXCEPTION;
BEGIN
  e_code := 200;

  SELECT COUNT(*) INTO t_count
    FROM dba_users
   WHERE username = 'FOOD_ADMIN';

  IF t_count > 0 THEN
    EXECUTE IMMEDIATE 'DROP USER food_admin CASCADE';
    DBMS_OUTPUT.PUT_LINE(e_code||': food_admin dropped successfully');
  ELSE
    RAISE user_missing;
  END IF;

EXCEPTION
  WHEN user_missing THEN
    e_code := 100;
    DBMS_OUTPUT.PUT_LINE(e_code||': food_admin not available');
  WHEN OTHERS THEN
    e_code := 500;
    DBMS_OUTPUT.PUT_LINE(e_code||': unknown error');
END;
/

-- 2. Create USER food_admin
DECLARE
  e_code       NUMBER;
  t_count      NUMBER;
  user_exists  EXCEPTION;
BEGIN
  e_code := 200;

  SELECT COUNT(*) INTO t_count
    FROM dba_users
   WHERE username = 'FOOD_ADMIN';

  IF t_count = 0 THEN
    EXECUTE IMMEDIATE q'[
      CREATE USER food_admin
      IDENTIFIED BY "SecureAdmin123#"
      DEFAULT TABLESPACE users
      TEMPORARY TABLESPACE temp
      QUOTA UNLIMITED ON users
    ]'; -- GRANT CREATE ROLE, DROP ANY ROLE, GRANT ANY ROLE TO food_admin
    EXECUTE IMMEDIATE 'GRANT CREATE SESSION, ALTER SESSION TO food_admin'; -- GRANT CREATE SESSION, ALTER SESSION TO food_admin
    EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO food_admin WITH ADMIN OPTION'; 
    EXECUTE IMMEDIATE 'GRANT CREATE USER, ALTER USER, DROP USER TO food_admin'; -- GRANT CREATE USER, ALTER USER, DROP USER TO food_admin
    EXECUTE IMMEDIATE 'GRANT CREATE TABLE, CREATE VIEW, CREATE PROCEDURE, CREATE SEQUENCE TO food_admin'; -- GRANT CREATE TABLE, CREATE VIEW, CREATE PROCEDURE, CREATE SEQUENCE TO food_admin
    EXECUTE IMMEDIATE 'GRANT UNLIMITED TABLESPACE TO food_admin'; -- GRANT UNLIMITED TABLESPACE TO food_admin
    EXECUTE IMMEDIATE 'GRANT CREATE TRIGGER TO food_admin'; -- GRANT CREATE TRIGGER TO food_admin
    EXECUTE IMMEDIATE 'GRANT ADMINISTER DATABASE TRIGGER TO food_admin';
    -- EXECUTE IMMEDIATE 'GRANT GRANT ANY PRIVILEGE TO food_admin';
    DBMS_OUTPUT.PUT_LINE(e_code||': food_admin created successfully with required permissions and access');
  ELSE
    RAISE user_exists;
  END IF;

EXCEPTION
  WHEN user_exists THEN
    e_code := 100;
    DBMS_OUTPUT.PUT_LINE(e_code||': food_admin already exists');
  WHEN OTHERS THEN
    e_code := 500;
    DBMS_OUTPUT.PUT_LINE(e_code||': unknown error');
END;
/

