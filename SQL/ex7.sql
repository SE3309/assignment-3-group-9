USE hospital_dashboard;

-- View 1: PatientVisitSummary
CREATE VIEW PatientVisitSummary AS
SELECT 
    p.Patient_ID,
    CONCAT(p.First_Name, ' ', p.Last_Name) AS Patient_Name,
    p.Birthdate,
    v.Visit_ID,
    v.Visit_Date,
    v.Department,
    v.Visit_Type,
    v.Attending_Doctor_ID
FROM Patient p
JOIN Visit v ON p.Patient_ID = v.Patient_ID;

-- Query View 1
SELECT * FROM PatientVisitSummary LIMIT 10;

-- Attempt Modification (Should Fail)
INSERT INTO PatientVisitSummary (
    Patient_ID, Patient_Name, Birthdate, Visit_ID, Visit_Date, Department, Visit_Type
) VALUES (
    99, 'Test Person', '1990-01-01', 500, '2025-01-01', 'Cardiology', 'outpatient'
);


-- View 2: ActivePrescriptionOverview
CREATE VIEW ActivePrescriptionOverview AS
SELECT
    pr.Prescription_ID,
    pr.Patient_ID,
    CONCAT(p.First_Name, ' ', p.Last_Name) AS Patient_Name,
    pr.Medication_Name,
    pr.Dose,
    pr.Route,
    pr.Frequency,
    pr.Start_Date,
    pr.Stop_Date,
    CONCAT(d.First_Name, ' ', d.Last_Name) AS Prescriber_Name
FROM Prescription pr
JOIN Patient p ON pr.Patient_ID = p.Patient_ID
JOIN Doctor d ON pr.Prescriber_ID = d.Doctor_ID
WHERE pr.Stop_Date IS NULL
   OR pr.Stop_Date >= CURDATE();

-- Query View 2
SELECT * FROM ActivePrescriptionOverview LIMIT 10;

-- Attempt Modification (Should Fail)
UPDATE ActivePrescriptionOverview
SET Medication_Name = 'TestDrug'
WHERE Prescription_ID = 1;
