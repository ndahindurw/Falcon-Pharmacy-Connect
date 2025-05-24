
#  Phase7 : Advanced Database Programming and Auditing


## a) Problem Statement Development
### Problem Statement:
The Medication and Pharmacy Management System aims to provide seamless integration of medication inventory, pricing, and patient notification. Advanced database programming techniques are needed to enforce data integrity, automate workflows, and secure sensitive data. These enhancements will streamline operations and ensure accountability within the system.

### Justification:
- Triggers: Ensure data consistency, enforce business rules, and automate updates (e.g., updating stock levels after medication dispensing).
- Cursors: Process multi-row queries for operations like inventory audits and pricing updates.
- Functions and Packages: Encapsulate business logic for reusability and modularity (e.g., calculating coverage).
- Auditing: Track user actions and sensitive data changes to improve security and accountability.





## b) i. simple trigger

                      CREATE OR REPLACE TRIGGER trg_update_last_updated
                      BEFORE UPDATE OF Stock_Level ON Inventory_Record
                      FOR EACH ROW
                      BEGIN
                          :NEW.Last_Updated := SYSDATE;
                      END;
                      /


 ##  ii. compund trigger

                      CREATE OR REPLACE TRIGGER trg_pharmacy_inventory
                      FOR INSERT ON Inventory_Record
                      COMPOUND TRIGGER
                      
                          -- Declare a collection to store new rows
                          TYPE t_med_list IS TABLE OF Inventory_Record%ROWTYPE INDEX BY PLS_INTEGER;
                          med_list t_med_list;
                      
                          -- Variable to track the index for the collection
                          idx INTEGER := 0;
                      
                          -- Before each row, store the row data into the collection
                          BEFORE EACH ROW IS
                          BEGIN
                              idx := idx + 1;
                              med_list(idx).Medication_ID := :NEW.Medication_ID;
                              med_list(idx).Stock_Level := :NEW.Stock_Level;
                              med_list(idx).Last_Updated := :NEW.Last_Updated;
                          END BEFORE EACH ROW;
                      
                          -- After the statement, process the collected data
                          AFTER STATEMENT IS
                          BEGIN
                              FOR i IN 1 .. med_list.COUNT LOOP
                                  DBMS_OUTPUT.PUT_LINE('Inserted Medication ID: ' || med_list(i).Medication_ID || 
                                                       ', Stock Level: ' || med_list(i).Stock_Level);
                              END LOOP;
                          END AFTER STATEMENT;
                      
                      END trg_pharmacy_inventory;
                      /


## c)     cursor usage

                      DECLARE
                          CURSOR low_stock_cursor IS
                              SELECT Medication_ID, Stock_Level
                              FROM Inventory_Record
                              WHERE Stock_Level < 10;
                          v_med_id Inventory_Record.Medication_ID%TYPE;
                          v_stock Inventory_Record.Stock_Level%TYPE;
                      BEGIN
                          OPEN low_stock_cursor;
                          LOOP
                              FETCH low_stock_cursor INTO v_med_id, v_stock;
                              EXIT WHEN low_stock_cursor%NOTFOUND;
                              DBMS_OUTPUT.PUT_LINE('Medication ID: ' || v_med_id || ', Stock Level: ' || v_stock);
                          END LOOP;
                          CLOSE low_stock_cursor;
                      END;
                      /



## d) (i) Attributes 

                    DECLARE
                        v_patient Patient%ROWTYPE;
                    BEGIN
                        SELECT * INTO v_patient FROM Patient WHERE Patient_ID = 101;
                        DBMS_OUTPUT.PUT_LINE('Patient Name: ' || v_patient.First_Name || ' ' || v_patient.Last_Name);
                    END;
                    /



###    (ii)Function to Calculate Total Price:

                              CREATE OR REPLACE FUNCTION fn_calculate_price(
                                  p_med_id Medication.Medication_ID%TYPE,
                                  p_ins_id Insurance_Provider.Insurance_ID%TYPE
                              ) RETURN NUMBER IS
                                  v_price Pricing.Price%TYPE;
                                  v_coverage Pricing.Coverage_Percentage%TYPE;
                              BEGIN
                                  SELECT Price, Coverage_Percentage INTO v_price, v_coverage
                                  FROM Pricing
                                  WHERE Medication_ID = p_med_id AND Insurance_ID = p_ins_id;
                                  RETURN v_price * (1 - v_coverage / 100);
                              END;
                              /

### e) Package Development


####    Package for Notifications:

                            CREATE OR REPLACE PACKAGE pkg_notifications AS
                                PROCEDURE send_notification(p_patient_id Patient.Patient_ID%TYPE, p_message VARCHAR2);
                            END pkg_notifications;
                            /
                            
                            CREATE OR REPLACE PACKAGE BODY pkg_notifications AS
                                PROCEDURE send_notification(p_patient_id Patient.Patient_ID%TYPE, p_message VARCHAR2) IS
                                BEGIN
                                    INSERT INTO Notification (Notification_ID, Patient_ID, Notification_Date, Status)
                                    VALUES (SEQ_NOTIFICATION.NEXTVAL, p_patient_id, SYSDATE, p_message);
                                    COMMIT;
                                END send_notification;
                            END pkg_notifications;
                            /




                  CREATE SEQUENCE SEQ_NOTIFICATION
                      START WITH 1
                      INCREMENT BY 1
                      NOCACHE
                      NOCYCLE;





## f)Auditing with Restrictions and Tracking

  ###  Logging Changes to Sensitive Data (i)

                            CREATE OR REPLACE TRIGGER trg_audit_stock_changes
                            AFTER UPDATE OF Stock_Level ON Inventory_Record
                            FOR EACH ROW
                            BEGIN
                                INSERT INTO Inventory_Audit (Change_Date, Table_Name, User_Name, Action, Old_Value, New_Value)
                                VALUES (SYSDATE, 'Inventory_Record', USER, 'UPDATE', :OLD.Stock_Level, :NEW.Stock_Level);
                            END;
                            /



                CREATE TABLE Inventory_Audit (
                    Audit_ID NUMBER PRIMARY KEY,
                    Change_Date DATE,
                    Table_Name VARCHAR2(100),
                    User_Name VARCHAR2(100),
                    Action VARCHAR2(50),
                    Old_Value NUMBER,
                    New_Value NUMBER
                );



####  Tracking User Actions for Accountability (ii)


                      CREATE TABLE User_Action_Log (
                          Log_ID NUMBER PRIMARY KEY,
                          User_Name VARCHAR2(100),
                          Action_Type VARCHAR2(50),
                          Table_Name VARCHAR2(100),
                          Record_ID NUMBER,
                          Action_Date DATE
                      );



                            CREATE OR REPLACE TRIGGER trg_user_actions
                            AFTER INSERT OR UPDATE OR DELETE ON Inventory_Record
                            FOR EACH ROW
                            BEGIN
                                IF INSERTING THEN
                                    INSERT INTO User_Action_Log (Log_ID, User_Name, Action_Type, Table_Name, Record_ID, Action_Date)
                                    VALUES (SEQ_USER_ACTION_LOG.NEXTVAL, USER, 'INSERT', 'Inventory_Record', :NEW.INVENTORY_RECORD_ID, SYSDATE);
                                ELSIF UPDATING THEN
                                    INSERT INTO User_Action_Log (Log_ID, User_Name, Action_Type, Table_Name, Record_ID, Action_Date)
                                    VALUES (SEQ_USER_ACTION_LOG.NEXTVAL, USER, 'UPDATE', 'Inventory_Record', :NEW.INVENTORY_RECORD_ID, SYSDATE);
                                ELSIF DELETING THEN
                                    INSERT INTO User_Action_Log (Log_ID, User_Name, Action_Type, Table_Name, Record_ID, Action_Date)
                                    VALUES (SEQ_USER_ACTION_LOG.NEXTVAL, USER, 'DELETE', 'Inventory_Record', :OLD.INVENTORY_RECORD_ID, SYSDATE);
                                END IF;
                            END;
                            /


                              CREATE SEQUENCE SEQ_USER_ACTION_LOG
                                  START WITH 1
                                  INCREMENT BY 1
                                  NOCACHE
                                  NOCYCLE;



### Using Restrictions to Control Access Based on User Roles(iii)


                          SQL> ALTER SESSION SET CONTAINER = wedn_falcon_pharmaconnect;
                          
                          Session altered.

                                SQL> CREATE ROLE AUDITOR_ROLE;
                                
                                Role created.

                                SQL> GRANT AUDITOR_ROLE TO wedn_falcon;
                                
                                Grant succeeded.

                                CREATE ROLE INVENTORY_MANAGER_ROLE;
                                
                                Role created.

                                SQL> GRANT INVENTORY_MANAGER_ROLE TO wedn_falcon;
                                
                                Grant succeeded.


                            CREATE OR REPLACE VIEW Inventory_View AS
                            SELECT INVENTORY_RECORD_ID, Stock_Level -- Replace Inventory_ID with INVENTORY_RECORD_ID
                            FROM Inventory_Record
                            WHERE USER IN (
                                SELECT GRANTEE 
                                FROM DBA_ROLE_PRIVS 
                                WHERE GRANTED_ROLE IN ('INVENTORY_MANAGER_ROLE', 'AUDITOR_ROLE')
                            );







### Using Functions and Packages to Enforce Restrictions(iv)

                              -- Create or replace function to check stock level
                              CREATE OR REPLACE FUNCTION check_stock_level(p_inventory_record_id IN NUMBER) RETURN BOOLEAN IS
                                  v_stock_level NUMBER;
                              BEGIN
                                  -- Get the stock level for the given INVENTORY_RECORD_ID
                                  SELECT STOCK_LEVEL INTO v_stock_level
                                  FROM Inventory_Record
                                  WHERE INVENTORY_RECORD_ID = p_inventory_record_id;
                              
                                  -- Check if stock level is below 10
                                  IF v_stock_level < 10 THEN
                                      RETURN FALSE; -- Prevent update if stock level is below 10
                                  ELSE
                                      RETURN TRUE;
                                  END IF;
                              END;
                              /





 -- Trigger to enforce the rule



                                    CREATE OR REPLACE TRIGGER trg_check_stock_level
                                    BEFORE UPDATE OF Stock_Level ON Inventory_Record
                                    FOR EACH ROW
                                    BEGIN
                                        IF NOT check_stock_level(:NEW.INVENTORY_RECORD_ID ) THEN
                                            RAISE_APPLICATION_ERROR(-20001, 'Stock level cannot be updated below 10.');
                                        END IF;
                                    END;
                                    /



## 5. Documenting How Auditing Improves Security and Aligns with Project Objectives


#### Auditing Mechanisms
Auditing mechanisms are critical for tracking changes and monitoring database activity. By using triggers and audit tables, you can log all changes to sensitive data such as Stock_Level, track user actions (such as INSERT, UPDATE, DELETE), and ensure that all operations are performed by authorized users.

#### Role-Based Restrictions
By implementing role-based restrictions, you can control who has access to sensitive data based on their roles in the organization. For example, inventory managers can access Stock_Level, while auditors can only view audit logs.

#### Enforcing Business Rules
The use of functions and triggers ensures that business rules are enforced automatically. For example, preventing updates to Stock_Level when it’s below a certain threshold helps maintain data integrity and ensures business rules are followed.

#### Security Alignment
Auditing improves security by providing accountability for user actions. It helps track changes and monitor who made specific changes to sensitive data. Restricting access based on user roles ensures that only authorized personnel can access or modify sensitive data, preventing unauthorized access and ensuring compliance with data protection policies.

####  Project Objectives
The auditing and access control mechanisms directly align with project objectives by ensuring that:

- Sensitive data is protected through monitoring and role-based restrictions.
- User actions are logged for accountability.
- Business rules are enforced automatically, ensuring data integrity and security.
- By implementing these mechanisms, you are ensuring that your database is secure, accountable, and compliant with best practices for data management.




### g) Scope and Limitations

## Scope:

### Triggers:

Triggers are automatic actions that occur in response to specific database events such as INSERT, UPDATE, or DELETE. They enforce business rules at the database level, ensuring data integrity and consistency. For example, a trigger can prevent the stock level of an inventory record from being updated if it falls below a certain threshold.
### Cursors:

Cursors allow for efficient processing of multi-row queries. In PL/SQL, cursors are used to retrieve and process multiple rows from a query one at a time. This is useful when dealing with large datasets where row-by-row processing is needed. A cursor can be implicit (automatically handled by PL/SQL) or explicit (defined and controlled by the user).
### Packages:

A package is a collection of related procedures, functions, and other PL/SQL constructs bundled together for modularity and reusability. Packages allow for better organization of code and enable code reuse across different parts of the application. For instance, a package could manage all functions related to user authentication.
### Auditing:

Auditing refers to tracking and logging database activities for security, compliance, and accountability. By auditing operations, you can log who accessed or modified data, which is crucial for tracking unauthorized actions. Auditing helps identify potential security breaches and ensures compliance with regulatory standards.
### Limitations:
#### Performance:

Triggers and cursors, if not used judiciously, can degrade performance. Triggers add overhead to DML operations (inserts, updates, deletes) as they automatically execute additional SQL or PL/SQL code. Cursors, especially when dealing with large datasets, can slow down processing if not optimized properly.
Complexity in Debugging:

PL/SQL logic, especially when dealing with triggers, cursors, and packages, can be complex and difficult to debug. Identifying the source of errors in triggers or understanding why a cursor is not behaving as expected requires careful debugging techniques and an understanding of PL/SQL intricacies.
Storage Overhead (Auditing):

Auditing features can increase storage requirements, as logs and records of every action (such as database access or changes to sensitive data) need to be stored. Depending on the volume of transactions and the level of detail in the audit logs, this can consume significant storage space.


### h) Documentation and Demonstration

## Documentation:

### The documentation should include:

#### Problem Statement and Justification:

Provide a brief description of the issue being addressed (e.g., the need to enforce business rules in a database, or to track unauthorized access). Justify the use of triggers, cursors, packages, and auditing to solve the problem effectively.
##### SQL Scripts for Triggers, Cursors, Functions, and Packages:

Include the PL/SQL scripts for each feature. For example, the trigger to prevent stock levels from being updated below a threshold, or the package managing user authentication.
##### Testing Results for Each Feature:

Document how each feature (trigger, cursor, function, or package) was tested. Include examples of test cases, expected outcomes, and actual results. For example, testing if the trigger prevents updating stock below a certain level, or verifying that the cursor efficiently handles large datasets.
##### Demonstration:
Showcase Automated Workflows Using Triggers:

Demonstrate how triggers automatically enforce business rules. For example, show how an attempt to update the stock level of an inventory record below the minimum threshold triggers an error message or blocks the operation.
##### Display Real-Time Data Updates via Cursors:

Show how cursors are used to handle and display real-time data updates. For instance, use an explicit cursor to fetch inventory records one by one and display their stock levels.
##### Present Audit Logs and Restricted Access Control:

Demonstrate the auditing system by showing how every change or access to sensitive data is logged. Show the audit logs capturing who made a change, when, and what was modified. Additionally, demonstrate how restricted access control ensures that only authorized users can modify or access sensitive data.






















                            
