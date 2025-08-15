# Commercial Kitchen Recovery Hub

The Food waste Management System has been designed to help reduce food waste in the community. We will be having four roles - supplier, ngo, govt. and logistics. Initially supplier will be logging in. If he has excess food in his restaurant he will be raising food source in supplier table. Once the food source has been raised from supplier directly food will be available in main food table. Once food is available in main food table, NGO will request food from there. Once if they raise food_request from NGO table, it will be directed to logistics table. Logistics will then send the food to NGO. Once NGO receives the food, the food quantity will be changing in the main food table as well has food request will be closed from ngo. Once the food is delivered, Govt will be performing the quality checks based on the food prepared time and they will update quality points and assign back to ngo. Once the quality points are updated, NGO will distributing the food in the community.

# Documents included
1. Business rules - [Business Rules Documentation for Food_waste system.pdf](https://github.com/jayanthmani8045/Food-Conservation-Portal/blob/main/DB/Business%20Rules%20Documentation%20for%20Food_waste%20system.pdf)
2. Data flow diagram - [food_waste_management_system DFD.pdf](https://github.com/jayanthmani8045/Food-Conservation-Portal/blob/main/DB/food_waste_management_system%20DFD.pdf)
4. Entity relationship diagram -
![Relational Diagram](https://github.com/jayanthmani8045/Food-Conservation-Portal/blob/main/DB/ER%20Diagram/Relational_ER.png)


## Tech Stack

### Backend

* **Language & Framework:** Python 3.11+, [FastAPI](https://fastapi.tiangolo.com/)
* **ASGI Server:** Uvicorn with WatchFiles for live reloading
* **Database:** Oracle Database
* **Driver:** [oracledb](https://oracle.github.io/python-oracledb/)


### Frontend

* **Library & Tooling:** React (bootstrapped with Vite)
* **HTTP Client:** Axios
* **Routing:** React Router v6
* **State Management:** React Context + Hooks (no Redux)
* **Styling:** TailwindCSS
* **Dev Server:** Vite (powered by Rollup)


# SQL Setup Instructions

This document provides the necessary steps to set up the project database using Oracle SQL Developer. Please run the provided SQL scripts in the specified order to ensure a correct and complete installation.

-----

## Prerequisites

  * Oracle SQL Developer (or another compatible SQL client).
  * An active connection to an Oracle Database instance.
  * Access to an administrative database account (e.g., `SYSTEM` or `SYS`) for initial user creation.

-----

## Setup Steps

Follow these instructions sequentially.

### 1\. Create the Application User

First, you need to create the dedicated user for this application.

  * Connect to your database using an **admin account**.
  * Open and run the following script:
    ```
    DB/Access/Admin_Project(food_admin user creation).sql
    ```
    This will create the `food_admin` user and grant it the required permissions.

### 2\. Create Database Schema and Objects

For all subsequent steps, you must be connected as the newly created `food_admin` user.

  * **Switch your database connection** to use the **`food_admin`** account.

  * Run the following scripts **in the exact order listed below**:

    a. **Tables (DDL):**

    ```
    DB/DDL & test DML/ER Table DDL.ddl.sql
    ```

    b. **Views:**

    ```
    DB/Views/highlevelviews.sql
    ```

    c. **Triggers:**

    ```
    DB/Triggers/triggers.sql
    ```

    d. **Packages:**

    ```
    DB/package/govt_actions_pkg.sql
    DB/package/logistic_actions_pkg.sql
    DB/package/ngo_actions_pkg.sql
    DB/package/supplier_actions_pkg.sql
    DB/package/user_mgmt_package.sql
    ```

-----

## Testing

Create samples users from **`food_admin`** account. useing 

```
DB/Access/test user creation with package.sql
```

After creating sample users for testing different application roles, run the following scripts in respective accounts.

1.  **Government Users:**

    ```
    DB/testing users/DevDB_gov_user.sql
    ```

2.  **Logistics Users:**

    ```
    DB/testing users/DevDB_logi_user.sql
    ```

3.  **Non-Profit Organization Users:**

    ```
    DB/testing users/DevDB_ngo_user.sql
    ```

4.  **Supplier Users:**

    ```
    DB/testing users/DevDB_sup_user.sql
    ```

-----

After successfully executing all the setup scripts, the database is complete. ✅
