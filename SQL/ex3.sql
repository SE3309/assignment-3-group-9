-- Q3: INSERT #1 – Simple single-row INSERT
INSERT INTO Patient (
    Health_Card_Number, First_Name, Last_Name, Birthdate, Email, Phone
) VALUES (
    'ON-1111-2222', 'Alice', 'Nguyen', '1990-05-12', 'alice@example.com', '555-1111'
);

-- Show current contents after first insert
SELECT * FROM Patient;

-- Q3: INSERT #2 – Multi-row INSERT with VALUES
INSERT INTO Patient (
    Health_Card_Number, First_Name, Last_Name, Birthdate, Email, Phone
)
VALUES
('ON-3333-4444', 'Ben', 'Jones', '1984-03-21', 'ben@example.com', '555-2222'),
('ON-5555-6666', 'Chloe', 'Smith', '2001-07-18', 'chloe@example.com', '555-3333');

SELECT * FROM Patient;

-- Q3: INSERT #3 – INSERT ... SELECT (copies a row, but changes the unique key + email)
INSERT INTO Patient (
    Health_Card_Number, First_Name, Last_Name, Birthdate, Email, Phone
)
SELECT
    CONCAT(Health_Card_Number, '-COPY'),
    First_Name,
    Last_Name,
    Birthdate,
    CONCAT('copy_', Email),
    Phone
FROM Patient
WHERE Patient_ID = 1;

SELECT * FROM Patient;