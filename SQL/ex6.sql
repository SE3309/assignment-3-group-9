INSERT INTO Allergy (Patient_ID, Allergy_Name, Severity, Notes)
SELECT Patient_ID, 'Penicillin', 'severe',
       'Auto-flag based on birthdate < 1980'
FROM Patient
WHERE Birthdate < '1980-01-01';

SELECT * FROM Allergy LIMIT 10;

UPDATE Prescription
SET Frequency = CONCAT(Frequency, ' (monitoring)')
WHERE Stop_Date IS NULL
  AND Patient_ID IN (
      SELECT Patient_ID FROM Patient
      WHERE Birthdate < '1970-01-01'
  );

SELECT * FROM Prescription LIMIT 10;

DELETE FROM Appointment
WHERE Status = 'canceled'
  AND Date_Time < (NOW() - INTERVAL 1 YEAR);

SELECT * FROM Appointment WHERE Status='canceled';
