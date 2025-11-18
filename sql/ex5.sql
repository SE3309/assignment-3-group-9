-- FILE: hospital_dashboard_complete.sql
-- DDL (Schema) + DML (Test Data) + All 7 Queries

-- 1. DATABASE SETUP
CREATE DATABASE IF NOT EXISTS hospital_dashboard;
USE hospital_dashboard;

-- Drop tables in reverse order for clean setup
DROP TABLE IF EXISTS Dispense;
DROP TABLE IF EXISTS Pharmacist;
DROP TABLE IF EXISTS Pharmacy;
DROP TABLE IF EXISTS Prescription;
DROP TABLE IF EXISTS Lab_Result;
DROP TABLE IF EXISTS Billing;
DROP TABLE IF EXISTS Visit;
DROP TABLE IF EXISTS Appointment;
DROP TABLE IF EXISTS Allergy;
DROP TABLE IF EXISTS Document;
DROP TABLE IF EXISTS Doctor;
DROP TABLE IF EXISTS Patient;


-- 2. DDL: CREATE TABLE Statements (Your Schema)
--------------------------------------------------------------------------------

CREATE TABLE Patient (
    Patient_ID             INT AUTO_INCREMENT PRIMARY KEY,
    Health_Card_Number     VARCHAR(32) NOT NULL UNIQUE,
    First_Name             VARCHAR(50) NOT NULL,
    Last_Name              VARCHAR(50) NOT NULL,
    Birthdate              DATE          NOT NULL,
    Email                  VARCHAR(100) NOT NULL,
    Phone                  VARCHAR(20)  NOT NULL
);

CREATE TABLE Allergy (
    Allergy_ID     INT AUTO_INCREMENT PRIMARY KEY,
    Patient_ID     INT NOT NULL,
    Allergy_Name   VARCHAR(100) NOT NULL,
    Severity       ENUM('mild', 'moderate', 'severe') NOT NULL,
    Notes          TEXT NULL,
    CONSTRAINT fk_allergy_patient
        FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID)
        ON DELETE CASCADE
);

CREATE TABLE Doctor (
    Doctor_ID      INT AUTO_INCREMENT PRIMARY KEY,
    First_Name     VARCHAR(50) NOT NULL,
    Last_Name      VARCHAR(50) NOT NULL,
    Phone          VARCHAR(20) NULL,
    Specialty      VARCHAR(100) NULL
);

CREATE TABLE Appointment (
    Appointment_ID INT AUTO_INCREMENT PRIMARY KEY,
    Patient_ID     INT NOT NULL,
    Clinic         VARCHAR(100) NOT NULL,
    Date_Time      DATETIME NOT NULL,
    Status         ENUM('booked','rescheduled','canceled','checked-in')
                     NOT NULL DEFAULT 'booked',
    CONSTRAINT fk_appointment_patient
        FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID)
        ON DELETE CASCADE
);

CREATE TABLE Visit (
    Visit_ID              INT AUTO_INCREMENT PRIMARY KEY,
    Patient_ID            INT NOT NULL,
    Appointment_ID        INT NULL,
    Visit_Date            DATE NOT NULL,
    Department            VARCHAR(100) NOT NULL,
    Visit_Type            ENUM('ER','inpatient','outpatient') NOT NULL,
    Attending_Doctor_ID INT NULL,
    Diagnoses             TEXT NULL,
    Procedures            TEXT NULL,
    CONSTRAINT fk_visit_patient
        FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID)
        ON DELETE CASCADE,
    CONSTRAINT fk_visit_appt
        FOREIGN KEY (Appointment_ID) REFERENCES Appointment(Appointment_ID)
        ON DELETE SET NULL,
    CONSTRAINT fk_visit_doctor
        FOREIGN KEY (Attending_Doctor_ID) REFERENCES Doctor(Doctor_ID)
        ON DELETE SET NULL,
    CONSTRAINT uq_visit_appt UNIQUE (Appointment_ID)
);

CREATE TABLE Lab_Result (
    Result_ID         INT AUTO_INCREMENT PRIMARY KEY,
    Patient_ID        INT NOT NULL,
    Visit_ID          INT NULL,
    Test_Type         VARCHAR(100) NOT NULL,
    Status            ENUM('ordered','in-progress','complete') NOT NULL,
    Collection_Time   DATETIME NULL,
    Turnaround_Time   INT NULL,
    Normal_Min        DECIMAL(10,3) NULL,
    Normal_Max        DECIMAL(10,3) NULL,
    Result_Value      DECIMAL(10,3) NULL,
    Abnormal_Flag     ENUM('Y','N') NULL,
    CONSTRAINT fk_labresult_patient
        FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID)
        ON DELETE CASCADE,
    CONSTRAINT fk_labresult_visit
        FOREIGN KEY (Visit_ID) REFERENCES Visit(Visit_ID)
        ON DELETE SET NULL
);

CREATE TABLE Prescription (
    Prescription_ID   INT AUTO_INCREMENT PRIMARY KEY,
    Patient_ID        INT NOT NULL,
    Medication_Name   VARCHAR(100) NOT NULL,
    Dose              VARCHAR(50) NOT NULL,
    Route             VARCHAR(50) NOT NULL,
    Frequency         VARCHAR(50) NOT NULL,
    Start_Date        DATE NOT NULL,
    Stop_Date         DATE NULL,
    Prescriber_ID     INT NOT NULL,
    CONSTRAINT fk_prescription_patient
        FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID)
        ON DELETE CASCADE,
    CONSTRAINT fk_prescription_doctor
        FOREIGN KEY (Prescriber_ID) REFERENCES Doctor(Doctor_ID)
        ON DELETE RESTRICT
);

CREATE TABLE Pharmacy (
    Pharmacy_ID   INT AUTO_INCREMENT PRIMARY KEY,
    Name          VARCHAR(100) NOT NULL,
    Address       VARCHAR(200) NULL,
    Phone         VARCHAR(20) NULL
);

CREATE TABLE Pharmacist (
    Pharmacist_ID INT AUTO_INCREMENT PRIMARY KEY,
    First_Name    VARCHAR(50) NOT NULL,
    Last_Name     VARCHAR(50) NOT NULL,
    License_No    VARCHAR(50) NOT NULL UNIQUE,
    Phone         VARCHAR(20) NULL,
    Pharmacy_ID   INT NULL,
    CONSTRAINT fk_pharmacist_pharmacy
        FOREIGN KEY (Pharmacy_ID) REFERENCES Pharmacy(Pharmacy_ID)
        ON DELETE SET NULL
);

CREATE TABLE Dispense (
    Dispense_ID       INT AUTO_INCREMENT PRIMARY KEY,
    Prescription_ID   INT NOT NULL,
    Pharmacy_ID       INT NULL,
    Pharmacist_ID     INT NULL,
    Dispense_Date     DATE NOT NULL,
    Quantity          INT  NOT NULL,
    Days_Remaining    INT  NULL,
    CONSTRAINT fk_dispense_prescription
        FOREIGN KEY (Prescription_ID) REFERENCES Prescription(Prescription_ID)
        ON DELETE CASCADE,
    CONSTRAINT fk_dispense_pharmacy
        FOREIGN KEY (Pharmacy_ID) REFERENCES Pharmacy(Pharmacy_ID)
        ON DELETE SET NULL,
    CONSTRAINT fk_dispense_pharmacist
        FOREIGN KEY (Pharmacist_ID) REFERENCES Pharmacist(Pharmacist_ID)
        ON DELETE SET NULL
);

CREATE TABLE Document (
    Document_ID           INT AUTO_INCREMENT PRIMARY KEY,
    Patient_ID            INT NOT NULL,
    Document_Type         VARCHAR(100) NOT NULL,
    Consent_Type          VARCHAR(100) NULL,
    Version               VARCHAR(20) NOT NULL,
    Signature_Timestamp   DATETIME NOT NULL,
    Effective_Start       DATE NULL,
    Effective_End         DATE NULL,
    Revocation_Status     ENUM('active','inactive') NOT NULL DEFAULT 'active',
    CONSTRAINT fk_document_patient
        FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID)
        ON DELETE CASCADE
);

CREATE TABLE Billing (
    Billing_ID            INT AUTO_INCREMENT PRIMARY KEY,
    Patient_ID            INT NOT NULL,
    Encounter_ID          INT NOT NULL,
    Billing_Date          DATE NOT NULL,
    Charge_Amount         DECIMAL(10,2) NOT NULL,
    Payment_Amount        DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    Outstanding_Balance   DECIMAL(10,2) AS (Charge_Amount - Payment_Amount) STORED,
    Payer_Type            ENUM('insurance','self-pay') NOT NULL,
    Aging_Bucket          ENUM('0-30','31-60','61-90','90+') NULL,
    Billing_Status        ENUM('open','posted','paid') NOT NULL DEFAULT 'open',
    CONSTRAINT fk_billing_patient
        FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID)
        ON DELETE CASCADE,
    CONSTRAINT fk_billing_visit
        FOREIGN KEY (Encounter_ID) REFERENCES Visit(Visit_ID)
        ON DELETE CASCADE
);

-- 3. DML: INSERT Statements (Sample Data for Testing Queries)
--------------------------------------------------------------------------------

INSERT INTO Patient (Health_Card_Number, First_Name, Last_Name, Birthdate, Email, Phone) VALUES
( 'HC1990001', 'Alice', 'Smith', '1985-05-10', 'alice.s@example.com', '555-0101'), 
( 'HC1990002', 'Bob', 'Johnson', '1998-11-20', 'bob.j@example.com', '555-0102'), 
( 'HC1990003', 'Carol', 'Williams', '1970-02-28', 'carol.w@example.com', '555-0103'), 
( 'HC1990004', 'David', 'Brown', '2005-08-15', 'david.b@example.com', '555-0104'),
( 'HC1990005', 'Eva', 'Davis', '1993-01-01', 'eva.d@example.com', '555-0105'); 

INSERT INTO Doctor (Doctor_ID, First_Name, Last_Name, Specialty, Phone) VALUES
( 1, 'John', 'Doe', 'Cardiology', '555-0201'),   
( 2, 'Jane', 'Ryan', 'Neurology', '555-0202'),   
( 3, 'Alan', 'Chen', 'Emergency Medicine', '555-0203'); 

INSERT INTO Allergy (Patient_ID, Allergy_Name, Severity, Notes) VALUES
(1, 'Penicillin', 'severe', 'Anaphylactic reaction.'), 
(2, 'Pollen', 'mild', NULL),
(3, 'Peanuts', 'moderate', 'Mild rash and itching.');

INSERT INTO Appointment (Patient_ID, Clinic, Date_Time, Status) VALUES
(1, 'General Practice', '2025-10-01 10:00:00', 'checked-in'),
(2, 'Pediatrics', '2025-10-02 11:30:00', 'booked');

INSERT INTO Visit (Patient_ID, Appointment_ID, Visit_Date, Department, Visit_Type, Attending_Doctor_ID, Diagnoses, Procedures) VALUES
(1, 1, '2025-10-01', 'Internal Medicine', 'outpatient', 1, 'Hypertension', 'ECG'), 
(2, NULL, '2025-10-05', 'Emergency', 'ER', 3, 'Fractured Wrist', 'Splinting'), 
(3, NULL, '2025-10-06', 'Orthopedics', 'inpatient', 3, 'Knee Replacement', 'Surgery'); 

INSERT INTO Lab_Result (Patient_ID, Visit_ID, Test_Type, Status, Normal_Min, Normal_Max, Result_Value, Abnormal_Flag) VALUES
(1, 1, 'CBC', 'complete', 4.5, 6.0, 5.2, 'N'),
(2, 2, 'CRP', 'complete', 0.0, 5.0, 15.3, 'Y'), 
(3, 3, 'Electrolytes', 'complete', 135.0, 145.0, 140.0, 'N'),
(5, NULL, 'Blood Sugar', 'complete', 70.0, 100.0, 65.0, 'Y'); 

INSERT INTO Pharmacy (Pharmacy_ID, Name, Address, Phone) VALUES
(100, 'Community Drug Mart', '101 Main St', '555-0301'), 
(200, 'City Wellness Pharmacy', '202 Oak Ave', '555-0302'); 

INSERT INTO Pharmacist (Pharmacist_ID, First_Name, Last_Name, License_No, Phone, Pharmacy_ID) VALUES
(10, 'Sarah', 'Kim', 'LIC12345', '555-0401', 100); 

INSERT INTO Prescription (Prescription_ID, Patient_ID, Medication_Name, Dose, Route, Frequency, Start_Date, Stop_Date, Prescriber_ID) VALUES
(10, 1, 'Lisinopril', '10mg', 'oral', 'daily', '2025-10-01', NULL, 1), 
(20, 3, 'Atorvastatin', '20mg', 'oral', 'daily', '2025-10-07', NULL, 2); 

INSERT INTO Dispense (Prescription_ID, Pharmacy_ID, Pharmacist_ID, Dispense_Date, Quantity, Days_Remaining) VALUES
(10, 100, 10, '2025-10-05', 30, 25),
(10, 100, 10, '2025-11-04', 30, 25),
(10, 100, 10, '2025-12-04', 30, 25),
(10, 100, 10, '2026-01-04', 30, 25), 
(20, 100, 10, '2025-10-10', 30, 20); 

INSERT INTO Billing (Patient_ID, Encounter_ID, Billing_Date, Charge_Amount, Payment_Amount, Payer_Type, Aging_Bucket, Billing_Status) VALUES
(1, 1, '2025-10-02', 500.00, 200.00, 'insurance', '0-30', 'open'),
(2, 2, '2025-10-06', 1500.00, 1500.00, 'insurance', '0-30', 'paid'),
(3, 3, '2025-10-07', 25000.00, 10000.00, 'self-pay', '31-60', 'open');

INSERT INTO Document (Patient_ID, Document_Type, Version, Signature_Timestamp, Revocation_Status) VALUES
(1, 'Consent for Treatment', '1.0', NOW(), 'active');


-- Query 1: Simple Selection
SELECT First_Name, Last_Name, Birthdate
FROM Patient
WHERE Birthdate < '1995-01-01'
ORDER BY Birthdate ASC;

-- Query 2: Two-Table Join
SELECT P.First_Name, P.Last_Name, A.Allergy_Name
FROM Patient AS P
INNER JOIN Allergy AS A ON P.Patient_ID = A.Patient_ID
WHERE A.Severity = 'severe';

-- Query 3: Aggregate Function with GROUP BY and HAVING
SELECT Prescription_ID, COUNT(Dispense_ID) AS Total_Dispenses
FROM Dispense
GROUP BY Prescription_ID
HAVING COUNT(Dispense_ID) > 3
ORDER BY Total_Dispenses DESC;

-- Query 4: Subquery with IN
SELECT First_Name, Last_Name, Specialty
FROM Doctor
WHERE Doctor_ID IN (
    SELECT DISTINCT Prescriber_ID
    FROM Prescription
);

-- Query 5: Correlated Subquery with EXISTS
SELECT P.Health_Card_Number, P.First_Name, P.Last_Name
FROM Patient AS P
WHERE EXISTS (
    SELECT 1
    FROM Lab_Result AS LR
    WHERE
        LR.Patient_ID = P.Patient_ID
        AND LR.Abnormal_Flag = 'Y'
);

-- Query 6: Multi-Table Join (Four Tables)
SELECT P.First_Name AS Patient_First, P.Last_Name AS Patient_Last, PR.Medication_Name, PH.Name AS Pharmacy_Name
FROM Dispense AS D
INNER JOIN Prescription AS PR ON D.Prescription_ID = PR.Prescription_ID
INNER JOIN Patient AS P ON PR.Patient_ID = P.Patient_ID
LEFT JOIN Pharmacy AS PH ON D.Pharmacy_ID = PH.Pharmacy_ID;

-- Query 7: Subquery with NOT IN
SELECT Name
FROM Pharmacy
WHERE Pharmacy_ID NOT IN (
    SELECT DISTINCT Pharmacy_ID
    FROM Dispense
    WHERE Pharmacy_ID IS NOT NULL
);