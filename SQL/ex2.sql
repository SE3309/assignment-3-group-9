-- Create database and use it
CREATE DATABASE IF NOT EXISTS hospital_dashboard;
USE hospital_dashboard;


CREATE TABLE Patient (
    Patient_ID           INT AUTO_INCREMENT PRIMARY KEY,
    Health_Card_Number   VARCHAR(32) NOT NULL UNIQUE,
    First_Name           VARCHAR(50) NOT NULL,
    Last_Name            VARCHAR(50) NOT NULL,
    Birthdate            DATE        NOT NULL,
    Email                VARCHAR(100) NOT NULL,
    Phone                VARCHAR(20)  NOT NULL
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
    Doctor_ID    INT AUTO_INCREMENT PRIMARY KEY,
    First_Name   VARCHAR(50) NOT NULL,
    Last_Name    VARCHAR(50) NOT NULL,
    Phone        VARCHAR(20) NULL,
    Specialty    VARCHAR(100) NULL
);

CREATE TABLE Appointment (
    Appointment_ID   INT AUTO_INCREMENT PRIMARY KEY,
    Patient_ID       INT NOT NULL,
    Clinic           VARCHAR(100) NOT NULL,
    Date_Time        DATETIME NOT NULL,
    Status           ENUM('booked','rescheduled','canceled','checked-in')
                     NOT NULL DEFAULT 'booked',
    CONSTRAINT fk_appointment_patient
        FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID)
        ON DELETE CASCADE
);

CREATE TABLE Visit (
    Visit_ID            INT AUTO_INCREMENT PRIMARY KEY,
    Patient_ID          INT NOT NULL,
    Appointment_ID      INT NULL,   -- optional link back to an Appointment
    Visit_Date          DATE NOT NULL,
    Department          VARCHAR(100) NOT NULL,
    Visit_Type          ENUM('ER','inpatient','outpatient') NOT NULL,
    Attending_Doctor_ID INT NULL,   -- Attending physician (Doctor_ID)
    Diagnoses           TEXT NULL,  -- multi-valued in conceptual model
    Procedures          TEXT NULL,  -- multi-valued in conceptual model
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
    Result_ID        INT AUTO_INCREMENT PRIMARY KEY,
    Patient_ID       INT NOT NULL,
    Visit_ID         INT NULL, 
    Test_Type        VARCHAR(100) NOT NULL,
    Status           ENUM('ordered','in-progress','complete') NOT NULL,
    Collection_Time  DATETIME NULL,
    Turnaround_Time  INT NULL,        -- minutes or hours
    Normal_Min       DECIMAL(10,3) NULL,
    Normal_Max       DECIMAL(10,3) NULL,
    Result_Value     DECIMAL(10,3) NULL,
    Abnormal_Flag    ENUM('Y','N') NULL,
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
    Route             VARCHAR(50) NOT NULL,    -- e.g., oral, IV
    Frequency         VARCHAR(50) NOT NULL,
    Start_Date        DATE NOT NULL,
    Stop_Date         DATE NULL,
    Prescriber_ID     INT NOT NULL,           -- Doctor_ID
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
    Pharmacist_ID  INT AUTO_INCREMENT PRIMARY KEY,
    First_Name     VARCHAR(50) NOT NULL,
    Last_Name      VARCHAR(50) NOT NULL,
    License_No     VARCHAR(50) NOT NULL UNIQUE,
    Phone          VARCHAR(20) NULL,
    Pharmacy_ID    INT NULL,
    CONSTRAINT fk_pharmacist_pharmacy
        FOREIGN KEY (Pharmacy_ID) REFERENCES Pharmacy(Pharmacy_ID)
        ON DELETE SET NULL
);

CREATE TABLE Dispense (
    Dispense_ID     INT AUTO_INCREMENT PRIMARY KEY,
    Prescription_ID INT NOT NULL,
    Pharmacy_ID     INT NULL,
    Pharmacist_ID   INT NULL,
    Dispense_Date   DATE NOT NULL,
    Quantity        INT  NOT NULL,
    Days_Remaining  INT  NULL,  -- derived logically, stored here for convenience
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
    Document_ID          INT AUTO_INCREMENT PRIMARY KEY,
    Patient_ID           INT NOT NULL,
    Document_Type        VARCHAR(100) NOT NULL,   -- discharge summary, imaging report, etc.
    Consent_Type         VARCHAR(100) NULL,       -- if applicable
    Version              VARCHAR(20) NOT NULL,
    Signature_Timestamp  DATETIME NOT NULL,
    Effective_Start      DATE NULL,
    Effective_End        DATE NULL,
    Revocation_Status    ENUM('active','inactive') NOT NULL DEFAULT 'active',
    CONSTRAINT fk_document_patient
        FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID)
        ON DELETE CASCADE
);

CREATE TABLE Billing (
    Billing_ID         INT AUTO_INCREMENT PRIMARY KEY,
    Patient_ID         INT NOT NULL,
    Encounter_ID       INT NOT NULL,  
    Billing_Date       DATE NOT NULL,
    Charge_Amount      DECIMAL(10,2) NOT NULL,
    Payment_Amount     DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    Outstanding_Balance DECIMAL(10,2) AS (Charge_Amount - Payment_Amount) STORED,
    Payer_Type         ENUM('insurance','self-pay') NOT NULL,
    Aging_Bucket       ENUM('0-30','31-60','61-90','90+') NULL,
    Billing_Status     ENUM('open','posted','paid') NOT NULL DEFAULT 'open',
    CONSTRAINT fk_billing_patient
        FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID)
        ON DELETE CASCADE,
    CONSTRAINT fk_billing_visit
        FOREIGN KEY (Encounter_ID) REFERENCES Visit(Visit_ID)
        ON DELETE CASCADE
);

Describe Allergy;
Describe Appointment;
Describe Billing;
Describe Dispense;
Describe Doctor;
Describe Document;
Describe Doctor;
Describe Document;
Describe Lab_Result;
Describe Patient;
Describe Pharmacist;
Describe Pharmacy;
Describe Prescription;
Describe Visit; 

