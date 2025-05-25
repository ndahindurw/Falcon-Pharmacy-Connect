CREATE USER admin_user IDENTIFIED BY secure_password;
GRANT pharmacy_admin TO admin_user;
GRANT CONNECT, RESOURCE TO pharmacy_admin;

-- Admin has full access to all tables
GRANT ALL ON patient pharmacy_admin;
GRANT ALL ON Pharmacy TO pharmacy_admin;
GRANT ALL ON Medication TO pharmacy_admin;
GRANT ALL ON Inventory Record TO pharmacy_admin;
GRANT ALL ON Insurance Provide TO pharmacy_admin;
