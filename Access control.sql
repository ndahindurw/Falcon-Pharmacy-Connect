CREATE USER admin_user IDENTIFIED BY secure_password;
GRANT pharmacy_admin TO admin_user;
GRANT CONNECT, RESOURCE TO pharmacy_admin;

-- Admin has full access to all tables
GRANT ALL ON medicines TO pharmacy_admin;
GRANT ALL ON prescriptions TO pharmacy_admin;
GRANT ALL ON customers TO pharmacy_admin;
GRANT ALL ON sales TO pharmacy_admin;
GRANT ALL ON inventory TO pharmacy_admin;
GRANT ALL ON suppliers TO pharmacy_admin;
