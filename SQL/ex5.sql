-- Query 1: Retrieve the names and emails of all patients born in or before 1990.
SELECT
    First_Name,
    Last_Name,
    Email
FROM
    Patient
WHERE
    Birthdate <= '1990-12-31';

-- Query 2: Find the names of all patients and their associated severe allergies.
SELECT
    P.First_Name,
    P.Last_Name,
    A.Allergy_Name
FROM
    Patient AS P
INNER JOIN
    Allergy AS A ON P.Patient_ID = A.Patient_ID
WHERE
    A.Severity = 'severe';

-- Query 3: Count the number of dispenses per prescription, but only list prescriptions that have been dispensed more than three times.
SELECT
    Prescription_ID,
    COUNT(Dispense_ID) AS Times_Dispensed
FROM
    Dispense
GROUP BY
    Prescription_ID
HAVING
    COUNT(Dispense_ID) > 3;

-- Query 4: Find the full name and specialty of all Doctors who have written at least one prescription.
SELECT
    First_Name,
    Last_Name,
    Specialty
FROM
    Doctor
WHERE
    Doctor_ID IN (
        SELECT DISTINCT Prescriber_ID
        FROM Prescription
    );

-- Query 5: List the names of patients who have at least one Abnormal Lab Result (Flag 'Y').
SELECT
    P.First_Name,
    P.Last_Name
FROM
    Patient AS P
WHERE
    EXISTS (
        SELECT 1
        FROM Lab_Result AS LR
        WHERE
            LR.Patient_ID = P.Patient_ID
            AND LR.Abnormal_Flag = 'Y'
    );

-- Query 6: List the patient, the medication, and the pharmacy where the medication was dispensed.
SELECT
    P.First_Name AS Patient_Name,
    PR.Medication_Name,
    PH.Name AS Pharmacy_Name
FROM
    Dispense AS D
INNER JOIN
    Prescription AS PR ON D.Prescription_ID = PR.Prescription_ID
INNER JOIN
    Patient AS P ON PR.Patient_ID = P.Patient_ID
LEFT JOIN
    Pharmacy AS PH ON D.Pharmacy_ID = PH.Pharmacy_ID;

-- Query 7: Find the names of pharmacies that have never been used to dispense a prescription.
SELECT
    Name
FROM
    Pharmacy
WHERE
    Pharmacy_ID NOT IN (
        SELECT DISTINCT Pharmacy_ID
        FROM Dispense
        WHERE Pharmacy_ID IS NOT NULL
    );
