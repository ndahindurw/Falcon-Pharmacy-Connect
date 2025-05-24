 # Project : PharmaConnect Management System (Phase 4, Phase 5 and Phase 6)

This repository documents the development process for a Pharmacy Management System, focusing on Phases 4, 5, and 6. Each phase includes detailed SQL operations that range from creating databases to implementing various relational tables, insertion of data, and performing joins to manage relationships between different entities.

## -------------------Phase 4: Database Initialization and Setup -----------------
In this phase, we set up the initial environment, including checking existing pluggable databases (PDBs), creating a new pluggable database, and switching between sessions to work within the specific PDB. The database is configured to manage pharmacy-related data efficiently.

- checking PBDS 

          SHOW PDBS;

- check where everything on pdbseed are located

        select con_id, tablespace_name, file_name from cdb_data_files
          2  where con_id = 3;

- creating pluggable database

         CREATE PLUGGABLE DATABASE wedn_falcon_pharmaconnect admin user wedn_falcon IDENTIFIED BY falcon
          2  FILE_NAME_CONVERT = ('C:\app\PC\product\21c\oradata\XE\pdbseed\','C:\app\PC\product\21c\oradata\XE\ wedn_falcon_pharmaconnect\');

- switch session from CDB to PDB mean we're working under PDB

         ALTER SESSION SET CONTAINER = wedn_falcon_pharmaconnect;

- unmount or open database to able to work on it
  
         ALTER DATABASE OPEN;

## ------------------Phase 5: Schema Design and Data Insertion---------------
- Table Creation: Several key tables are created, including Patient, Pharmacy, Medication, Inventory_Record, Insurance_Provider, Pricing, and other related tables to manage the relationships between these entities.

- Data Insertion: Insert operations are performed to populate these tables with sample data, establishing the foundation for operations involving patients, pharmacies, insurance providers, and medication inventory.

- Data Integrity Verification: Queries are used to verify data integrity, ensuring that all patients are linked correctly to insurance providers and all medications are available in pharmacies.

### Table Creation Section

            CREATE TABLE Patient (
                Patient_ID NUMBER PRIMARY KEY,
                First_Name VARCHAR2(100),
                Last_Name VARCHAR2(100),
                Email VARCHAR2(100),
                Phone VARCHAR2(20),
                Address VARCHAR2(200),
                Insurance_ID NUMBER,                         
                CONSTRAINT fk_patient_insurance FOREIGN KEY (Insurance_ID) REFERENCES Insurance_Provider(Insurance_ID)
            );
            
            
            
            CREATE TABLE Pharmacy (
                Pharmacy_ID NUMBER PRIMARY KEY,
                Pharmacy_Name VARCHAR2(100),
                Pharmacy_Address VARCHAR2(200),
                Phone VARCHAR2(20),
                Email VARCHAR2(100)
            );
            
            
            CREATE TABLE Medication (
                Medication_ID NUMBER PRIMARY KEY,
                Name VARCHAR2(100),
                Description VARCHAR2(500),
                Manufacturer VARCHAR2(100),
                Dosage_Form VARCHAR2(50),
                Strength VARCHAR2(50),
                Category VARCHAR2(100)
            );
            
            
            CREATE TABLE Inventory_Record (
                Inventory_Record_ID NUMBER PRIMARY KEY,
                Pharmacy_ID NUMBER,                         
                Medication_ID NUMBER,                        
                Stock_Level NUMBER,
                Last_Updated TIMESTAMP,
                CONSTRAINT fk_inventory_pharmacy FOREIGN KEY (Pharmacy_ID) REFERENCES Pharmacy (Pharmacy_ID),
                CONSTRAINT fk_inventory_medication FOREIGN KEY (Medication_ID) REFERENCES Medication (Medication_ID)
            );
            
            
            CREATE TABLE Insurance_Provider (
                Insurance_ID NUMBER PRIMARY KEY,
                Insurance_Company_Name VARCHAR2(100),
                Coverage_Plan VARCHAR2(200),
                Phone VARCHAR2(20),
                Email VARCHAR2(100)
            );
            
            
            
            CREATE TABLE Pricing (
                Pricing_ID NUMBER PRIMARY KEY,
                Insurance_ID NUMBER,                         
                Medication_ID NUMBER,                       
                Price NUMBER,
                Coverage_Percentage NUMBER,
                CONSTRAINT fk_pricing_insurance FOREIGN KEY (Insurance_ID) REFERENCES Insurance_Provider(Insurance_ID),
                CONSTRAINT fk_pricing_medication FOREIGN KEY (Medication_ID) REFERENCES Medication(Medication_ID)
            );
            
            
            CREATE TABLE Notification (
                Notification_ID NUMBER PRIMARY KEY,
                Patient_ID NUMBER,                          
                Medication_ID NUMBER,                        
                Notification_Date TIMESTAMP,
                Status VARCHAR2(50),                         
                CONSTRAINT fk_notification_patient FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID),
                CONSTRAINT fk_notification_medication FOREIGN KEY (Medication_ID) REFERENCES Medication(Medication_ID)
            );
            
            
            CREATE TABLE Patient_Medication (
                Patient_ID NUMBER,                           
                Medication_ID NUMBER,                        
                PRIMARY KEY (Patient_ID, Medication_ID), 
                CONSTRAINT fk_patient_medication_patient FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID),
                CONSTRAINT fk_patient_medication_medication FOREIGN KEY (Medication_ID) REFERENCES Medication(Medication_ID)
            );
            
            
            
            CREATE TABLE Pharmacy_Medication (
                Pharmacy_ID NUMBER,                         
                Medication_ID NUMBER,                       
                PRIMARY KEY (Pharmacy_ID, Medication_ID), 
                CONSTRAINT fk_pharmacy_medication_pharmacy FOREIGN KEY (Pharmacy_ID) REFERENCES Pharmacy(Pharmacy_ID),
                CONSTRAINT fk_pharmacy_medication_medication FOREIGN KEY (Medication_ID) REFERENCES Medication(Medication_ID)
            );
            
            
            CREATE TABLE Medication_Insurance (
                Medication_ID NUMBER,                       
                Insurance_ID NUMBER,                        
                PRIMARY KEY (Medication_ID, Insurance_ID),
                CONSTRAINT fk_medication_insurance FOREIGN KEY (Medication_ID) REFERENCES Medication(Medication_ID),
                CONSTRAINT fk_insurance_medication FOREIGN KEY (Insurance_ID) REFERENCES Insurance_Provider(Insurance_ID)
            );




### Insertion Phase
- insurance-provider

        INSERT INTO Insurance_Provider (Insurance_ID, Insurance_Company_Name, Coverage_Plan, Phone, Email)
        VALUES (1, 'MediCare Plus', 'Full Coverage', '123-456-7890', 'support@medicareplus.com');
        
        INSERT INTO Insurance_Provider (Insurance_ID, Insurance_Company_Name, Coverage_Plan, Phone, Email)
        VALUES (2, 'HealthFirst', 'Partial Coverage', '098-765-4321', 'info@healthfirst.com');
        
        INSERT INTO Insurance_Provider (Insurance_ID, Insurance_Company_Name, Coverage_Plan, Phone, Email)
        VALUES (3, 'WellCare', 'Emergency Only', '555-678-1234', 'help@wellcare.com');


- patient

        INSERT INTO Patient (Patient_ID, First_Name, Last_Name, Email, Phone, Address, Insurance_ID)
        VALUES (101, 'John', 'Doe', 'john.doe@example.com', '111-222-3333', '123 Elm St, Cityville', 1);
        
        INSERT INTO Patient (Patient_ID, First_Name, Last_Name, Email, Phone, Address, Insurance_ID)
        VALUES (102, 'Jane', 'Smith', 'jane.smith@example.com', '222-333-4444', '456 Oak St, Townsville', 2);
        
        INSERT INTO Patient (Patient_ID, First_Name, Last_Name, Email, Phone, Address, Insurance_ID)
        VALUES (103, 'Alice', 'Johnson', 'alice.j@example.com', '333-444-5555', '789 Pine St, Hamlet', 3);


- pharmacy

        INSERT INTO Pharmacy (Pharmacy_ID, Pharmacy_Name, Pharmacy_Address, Phone, Email)
        VALUES (201, 'City Pharmacy', '101 Main St, Cityville', '444-555-6666', 'contact@citypharmacy.com');
        
        INSERT INTO Pharmacy (Pharmacy_ID, Pharmacy_Name, Pharmacy_Address, Phone, Email)
        VALUES (202, 'Town Drugstore', '202 Center Ave, Townsville', '555-666-7777', 'info@towndrugstore.com');
        
        INSERT INTO Pharmacy (Pharmacy_ID, Pharmacy_Name, Pharmacy_Address, Phone, Email)
        VALUES (203, 'Village Chemist', '303 Market Rd, Hamlet', '666-777-8888', 'service@villagechemist.com');


- medication

         INSERT INTO Medication (Medication_ID, Name, Description, Manufacturer, Dosage_Form, Strength, Category)
         VALUES (301, 'Paracetamol', 'Pain reliever and fever reducer', 'PharmaCo', 'Tablet', '500mg', 'Analgesic');
         
         INSERT INTO Medication (Medication_ID, Name, Description, Manufacturer, Dosage_Form, Strength, Category)
         VALUES (302, 'Amoxicillin', 'Antibiotic for bacterial infections', 'HealthCorp', 'Capsule', '250mg', 'Antibiotic');
         
         INSERT INTO Medication (Medication_ID, Name, Description, Manufacturer, Dosage_Form, Strength, Category)
         VALUES (303, 'Cetirizine', 'Allergy relief', 'Wellness Ltd.', 'Tablet', '10mg', 'Antihistamine');

- inventory-record

          INSERT INTO Inventory_Record (Inventory_Record_ID, Pharmacy_ID, Medication_ID, Stock_Level, Last_Updated)
          VALUES (401, 201, 301, 100, SYSTIMESTAMP);
          
          INSERT INTO Inventory_Record (Inventory_Record_ID, Pharmacy_ID, Medication_ID, Stock_Level, Last_Updated)
          VALUES (402, 202, 302, 200, SYSTIMESTAMP);
          
          INSERT INTO Inventory_Record (Inventory_Record_ID, Pharmacy_ID, Medication_ID, Stock_Level, Last_Updated)
          VALUES (403, 203, 303, 150, SYSTIMESTAMP);

- pricing

       INSERT INTO Pricing (Pricing_ID, Insurance_ID, Medication_ID, Price, Coverage_Percentage)
       VALUES (501, 1, 301, 10.00, 80);
       
       INSERT INTO Pricing (Pricing_ID, Insurance_ID, Medication_ID, Price, Coverage_Percentage)
       VALUES (502, 2, 302, 20.00, 50);
       
       INSERT INTO Pricing (Pricing_ID, Insurance_ID, Medication_ID, Price, Coverage_Percentage)
       VALUES (503, 3, 303, 15.00, 30);


- notification

          INSERT INTO Notification (Notification_ID, Patient_ID, Medication_ID, Notification_Date, Status)
          VALUES (601, 101, 301, SYSTIMESTAMP, 'Sent');
          
          INSERT INTO Notification (Notification_ID, Patient_ID, Medication_ID, Notification_Date, Status)
          VALUES (602, 102, 302, SYSTIMESTAMP, 'Pending');
          
          INSERT INTO Notification (Notification_ID, Patient_ID, Medication_ID, Notification_Date, Status)
          VALUES (603, 103, 303, SYSTIMESTAMP, 'Delivered');


- patient-medication

         INSERT INTO Patient_Medication (Patient_ID, Medication_ID)
         VALUES (101, 301);
         
         INSERT INTO Patient_Medication (Patient_ID, Medication_ID)
         VALUES (102, 302);
         
         INSERT INTO Patient_Medication (Patient_ID, Medication_ID)
         VALUES (103, 303);


- pharmacy-medication

         INSERT INTO Pharmacy_Medication (Pharmacy_ID, Medication_ID)
         VALUES (201, 301);
         
         INSERT INTO Pharmacy_Medication (Pharmacy_ID, Medication_ID)
         VALUES (202, 302);
         
         INSERT INTO Pharmacy_Medication (Pharmacy_ID, Medication_ID)
         VALUES (203, 303);


- medication-insurance

        INSERT INTO Medication_Insurance (Medication_ID, Insurance_ID)
        VALUES (301, 1);
        
        INSERT INTO Medication_Insurance (Medication_ID, Insurance_ID)
        VALUES (302, 2);
        
        INSERT INTO Medication_Insurance (Medication_ID, Insurance_ID)
        VALUES (303, 3);

### Updating
- Update the email of the pharmacy with Pharmacy_ID = 201
  
        UPDATE Pharmacy
        SET Email = 'newemail@citypharmacy.com'
        WHERE Pharmacy_ID = 201;

- Update the strength of the medication with Medication_ID = 301
  
        UPDATE Medication
        SET Strength = '650mg'
        WHERE Medication_ID = 301;
### Deleting
- Delete the record where Medication_ID = 301 and Insurance_ID = 1
  
       DELETE FROM Medication_Insurance
       WHERE Medication_ID = 301 AND Insurance_ID = 1;

### Data Integrity Verification
- check for integrity

         SELECT p.Patient_ID, p.First_Name, p.Insurance_ID
         FROM Patient p
         LEFT JOIN Insurance_Provider i ON p.Insurance_ID = i.Insurance_ID
         WHERE i.Insurance_ID IS NULL;


- To include all patients and distinguish between those with and without insurance

          SELECT p.Patient_ID, p.First_Name, p.Insurance_ID, 
                 CASE 
                     WHEN i.Insurance_ID IS NULL THEN 'No Insurance'
                     ELSE 'Has Insurance'
                 END AS Insurance_Status
          FROM Patient p
          LEFT JOIN Insurance_Provider i ON p.Insurance_ID = i.Insurance_ID;

- Here's another query that retrieves a list of all medications and the pharmacies where they are available, along with the stock levels

         SELECT m.Medication_ID, m.Name AS Medication_Name, p.Pharmacy_ID, p.Pharmacy_Name, ir.Stock_Level
         FROM Medication m
         LEFT JOIN Pharmacy_Medication pm ON m.Medication_ID = pm.Medication_ID
         LEFT JOIN Pharmacy p ON pm.Pharmacy_ID = p.Pharmacy_ID
         LEFT JOIN Inventory_Record ir ON p.Pharmacy_ID = ir.Pharmacy_ID AND m.Medication_ID = ir.Medication_ID
         ORDER BY m.Medication_ID, p.Pharmacy_ID;

## ------------------Phase 6: Advanced SQL Joins and Transactions-----------------
- SQL Joins: Various types of joins are demonstrated to showcase data retrieval from multiple tables, such as cross joins, inner joins, left joins, right joins, and full outer joins. This allows us to answer questions like which medications are available in which pharmacies or which patients have certain insurance plans.

- Transaction Handling: A transaction example is included to demonstrate the rollback mechanism in case of errors, ensuring data consistency and reliability.
### Joins


- Example: Cross join between Pharmacy and Medication tables

        SELECT p.Pharmacy_Name, m.Name AS Medication_Name
        FROM Pharmacy p
        CROSS JOIN Medication m;


- Example: Inner join between Pharmacy and Pharmacy_Medication to find medications available in pharmacies

        SELECT p.Pharmacy_Name, m.Name AS Medication_Name
        FROM Pharmacy p
        INNER JOIN Pharmacy_Medication pm ON p.Pharmacy_ID = pm.Pharmacy_ID
        INNER JOIN Medication m ON pm.Medication_ID = m.Medication_ID;


- Example: Left join between Patient and Insurance_Provider to find patients and their insurance status

         SELECT p.First_Name, p.Last_Name, i.Insurance_Company_Name
         FROM Patient p
         LEFT JOIN Insurance_Provider i ON p.Insurance_ID = i.Insurance_ID;

-  Example: Right join between Medication and Pharmacy_Medication to find all medications and pharmacies

         SELECT m.Name AS Medication_Name, p.Pharmacy_Name
         FROM Medication m
         RIGHT JOIN Pharmacy_Medication pm ON m.Medication_ID = pm.Medication_ID
         RIGHT JOIN Pharmacy p ON pm.Pharmacy_ID = p.Pharmacy_ID;

- Example: Full join between Medication and Inventory_Record to see all medications and their stock levels

         SELECT m.Name AS Medication_Name, ir.Stock_Level
         FROM Medication m
         FULL OUTER JOIN Inventory_Record ir ON m.Medication_ID = ir.Medication_ID;


### Transation

             DECLARE
                 
             BEGIN
                 
                 INSERT INTO Patient (Patient_ID, First_Name, Last_Name, Email, Phone, Address, Insurance_ID)
                 VALUES (104, 'Sam', 'Green', 'sam.green@example.com', '444-555-6666', '123 Maple St, Forestville', 2);
             
                
                 INSERT INTO Medication (Medication_ID, Name, Description, Manufacturer, Dosage_Form, Strength, Category)
                 VALUES (304, 'Ibuprofen', 'Pain relief', 'PharmaX', 'Tablet', '400mg', 'Analgesic');
             
               
                 INSERT INTO Inventory_Record (Inventory_Record_ID, Pharmacy_ID, Medication_ID, Stock_Level, Last_Updated)
                 VALUES (404, 999, 304, 100, SYSTIMESTAMP);  -- Assuming Pharmacy_ID 999 doesn't exist
             
                
                 COMMIT;
             
             EXCEPTION
                 WHEN OTHERS THEN
                    
                     ROLLBACK;
                    
                     DBMS_OUTPUT.PUT_LINE('Error occurred: ' || SQLERRM);
             END;



This README provides an overview of the SQL operations and the logical flow between different phases, which helps in building a robust and scalable Pharmacy(PharmaConnect) Management System. Detailed SQL commands can be found within each phase section to aid in recreating the database and ensuring proper data relationships.
                            
