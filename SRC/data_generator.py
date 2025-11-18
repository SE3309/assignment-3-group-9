import random
import datetime

# ------------- CONFIG: HOW MUCH DATA TO GENERATE -------------
NUM_PATIENTS = 3000
NUM_DOCTORS = 80
NUM_APPOINTMENTS = 4000
NUM_VISITS = 4000
NUM_LAB_RESULTS = 2000
NUM_PRESCRIPTIONS = 1000
NUM_PHARMACIES = 30
NUM_PHARMACISTS = 60
NUM_DISPENSES = 2000
NUM_DOCUMENTS = 1500
NUM_BILLING = 2000

OUTPUT_FILE = "ex4_data.sql"

# ------------- HELPER DATA -------------
first_names = [
    "Alice", "Bob", "Carol", "David", "Emma", "Frank", "Grace", "Henry",
    "Isabella", "Jack", "Liam", "Mia", "Noah", "Olivia", "Peter", "Quinn",
    "Ryan", "Sophia", "Thomas", "Uma", "Victor", "Willow", "Xavier",
    "Yasmin", "Zoe"
]

last_names = [
    "Smith", "Johnson", "Brown", "Taylor", "Anderson", "Martin", "Lee",
    "Clark", "Walker", "Hall", "Young", "King", "Wright", "Scott", "Green",
    "Adams", "Baker", "Campbell", "Evans", "Hill"
]

specialties = [
    "Internal Medicine", "Cardiology", "Neurology", "Pediatrics",
    "Emergency Medicine", "Oncology", "Orthopedics", "Family Medicine"
]

clinics = [
    "Cardiology Clinic", "General Internal Medicine",
    "Neurology Clinic", "Family Practice", "Urgent Care"
]

departments = ["ER", "Medicine", "Surgery", "Oncology", "Pediatrics"]
visit_types = ["ER", "inpatient", "outpatient"]

test_types = ["CBC", "BMP", "Lipid Panel", "Troponin", "Liver Panel"]
medications = ["Atorvastatin", "Metformin", "Lisinopril",
               "Amoxicillin", "Omeprazole", "Aspirin"]
routes = ["oral", "IV", "IM"]
frequencies = ["once daily", "twice daily", "every 8 hours", "as needed"]

doc_types = ["discharge summary", "consult note",
             "imaging report", "operative note"]
consent_types = ["general", "surgery", "research", None]

payer_types = ["insurance", "self-pay"]
aging_buckets = ["0-30", "31-60", "61-90", "90+"]

pharmacy_names = [
    "City Pharmacy", "HealthFirst Pharmacy", "Main Street Drugs",
    "Hospital Outpatient Pharmacy", "CareWell Pharmacy"
]
addresses = [
    "123 Main St", "45 King Rd", "789 Elm St", "12 Oak Ave", "900 College St"
]


# ------------- RANDOM HELPERS -------------
def rand_date(start_year=1940, end_year=2020):
    """Random date between Jan 1 start_year and Dec 31 end_year."""
    start = datetime.date(start_year, 1, 1)
    end = datetime.date(end_year, 12, 31)
    delta_days = (end - start).days
    d = start + datetime.timedelta(days=random.randint(0, delta_days))
    return d.strftime("%Y-%m-%d")


def rand_datetime(start_year=2020, end_year=2025):
    """Random datetime in a given range."""
    start = datetime.datetime(start_year, 1, 1)
    end = datetime.datetime(end_year, 12, 31, 23, 59, 59)
    delta_seconds = int((end - start).total_seconds())
    dt = start + datetime.timedelta(seconds=random.randint(0, delta_seconds))
    return dt.strftime("%Y-%m-%d %H:%M:%S")


def rand_phone():
    return f"555-{random.randint(100, 999)}-{random.randint(1000, 9999)}"


def sql_str(val):
    """Escape single quotes and wrap in quotes; handle None."""
    if val is None:
        return "NULL"
    return "'" + str(val).replace("'", "''") + "'"


# ------------- MAIN GENERATION -------------
def main():
    random.seed(3309)  # reproducible

    lines = []

    # Use the correct DB
    lines.append("USE hospital_dashboard;\n")

    # ---- PATIENTS ----
    lines.append("-- PATIENT DATA")
    for pid in range(1, NUM_PATIENTS + 1):
        fn = random.choice(first_names)
        ln = random.choice(last_names)
        hc = f"HC{pid:010d}"
        birth = rand_date(1940, 2018)
        email = f"{fn.lower()}.{ln.lower()}{pid}@example.com"
        phone = rand_phone()
        lines.append(
            "INSERT INTO Patient "
            "(Health_Card_Number, First_Name, Last_Name, Birthdate, Email, Phone) "
            f"VALUES ({sql_str(hc)}, {sql_str(fn)}, {sql_str(ln)}, "
            f"{sql_str(birth)}, {sql_str(email)}, {sql_str(phone)});"
        )

    # ---- DOCTORS ----
    lines.append("\n-- DOCTOR DATA")
    for did in range(1, NUM_DOCTORS + 1):
        fn = random.choice(first_names)
        ln = random.choice(last_names)
        phone = rand_phone()
        spec = random.choice(specialties)
        lines.append(
            "INSERT INTO Doctor (First_Name, Last_Name, Phone, Specialty) "
            f"VALUES ({sql_str(fn)}, {sql_str(ln)}, {sql_str(phone)}, {sql_str(spec)});"
        )

    # ---- PHARMACIES ----
    lines.append("\n-- PHARMACY DATA")
    for phid in range(1, NUM_PHARMACIES + 1):
        name = random.choice(pharmacy_names) + f" #{phid}"
        addr = random.choice(addresses)
        phone = rand_phone()
        lines.append(
            "INSERT INTO Pharmacy (Name, Address, Phone) "
            f"VALUES ({sql_str(name)}, {sql_str(addr)}, {sql_str(phone)});"
        )

    # ---- PHARMACISTS ----
    lines.append("\n-- PHARMACIST DATA")
    for pharid in range(1, NUM_PHARMACISTS + 1):
        fn = random.choice(first_names)
        ln = random.choice(last_names)
        license_no = f"LIC-{pharid:05d}"
        phone = rand_phone()
        pharmacy_id = random.randint(1, NUM_PHARMACIES)
        lines.append(
            "INSERT INTO Pharmacist "
            "(First_Name, Last_Name, License_No, Phone, Pharmacy_ID) VALUES "
            f"({sql_str(fn)}, {sql_str(ln)}, {sql_str(license_no)}, "
            f"{sql_str(phone)}, {pharmacy_id});"
        )

    # ---- APPOINTMENTS ----
    lines.append("\n-- APPOINTMENT DATA")
    status_options = ['booked', 'rescheduled', 'canceled', 'checked-in']
    for aid in range(1, NUM_APPOINTMENTS + 1):
        patient_id = random.randint(1, NUM_PATIENTS)
        clinic = random.choice(clinics)
        dt = rand_datetime(2020, 2025)
        status = random.choices(
            status_options, weights=[60, 10, 10, 20], k=1
        )[0]
        lines.append(
            "INSERT INTO Appointment (Patient_ID, Clinic, Date_Time, Status) "
            f"VALUES ({patient_id}, {sql_str(clinic)}, {sql_str(dt)}, {sql_str(status)});"
        )

    # ---- VISITS ----
    lines.append("\n-- VISIT DATA")
    for vid in range(1, NUM_VISITS + 1):
        patient_id = random.randint(1, NUM_PATIENTS)
        # Some visits tied to appointments (but not all)
        appointment_id = vid if vid <= NUM_APPOINTMENTS and random.random() < 0.7 else None
        visit_date = rand_date(2020, 2025)
        dept = random.choice(departments)
        vtype = random.choice(visit_types)
        doctor_id = random.randint(1, NUM_DOCTORS)
        diagnoses = random.choice(["Hypertension", "Diabetes", "Chest pain",
                                   "Routine checkup", "Headache", "Abdominal pain"])
        procedures = random.choice(["Blood test", "ECG", "X-ray", "CT scan",
                                    "MRI", "IV fluids", "None"])

        lines.append(
            "INSERT INTO Visit "
            "(Patient_ID, Appointment_ID, Visit_Date, Department, Visit_Type, "
            "Attending_Doctor_ID, Diagnoses, Procedures) VALUES ("
            f"{patient_id}, "
            f"{'NULL' if appointment_id is None else appointment_id}, "
            f"{sql_str(visit_date)}, {sql_str(dept)}, {sql_str(vtype)}, "
            f"{doctor_id}, {sql_str(diagnoses)}, {sql_str(procedures)});"
        )

    # ---- LAB RESULTS ----
    lines.append("\n-- LAB RESULT DATA")
    status_lab = ['ordered', 'in-progress', 'complete']
    for rid in range(1, NUM_LAB_RESULTS + 1):
        patient_id = random.randint(1, NUM_PATIENTS)
        visit_id = random.randint(1, NUM_VISITS)
        test_type = random.choice(test_types)
        status = random.choices(status_lab, weights=[20, 20, 60], k=1)[0]
        collection_time = rand_datetime(2020, 2025)
        # Use a simple numeric range for normal range
        normal_min = 1.0
        normal_max = 10.0
        result_val = round(random.uniform(0.5, 12.0), 3)
        abnormal_flag = 'Y' if result_val < normal_min or result_val > normal_max else 'N'
        turnaround = random.randint(30, 240)  # minutes

        lines.append(
            "INSERT INTO Lab_Result "
            "(Patient_ID, Visit_ID, Test_Type, Status, Collection_Time, "
            "Turnaround_Time, Normal_Min, Normal_Max, Result_Value, Abnormal_Flag) "
            "VALUES ("
            f"{patient_id}, {visit_id}, {sql_str(test_type)}, {sql_str(status)}, "
            f"{sql_str(collection_time)}, {turnaround}, "
            f"{normal_min:.3f}, {normal_max:.3f}, {result_val:.3f}, {sql_str(abnormal_flag)});"
        )

    # ---- PRESCRIPTIONS ----
    lines.append("\n-- PRESCRIPTION DATA")
    for pid in range(1, NUM_PRESCRIPTIONS + 1):
        patient_id = random.randint(1, NUM_PATIENTS)
        med = random.choice(medications)
        dose = random.choice(["5 mg", "10 mg", "20 mg", "500 mg"])
        route = random.choice(routes)
        freq = random.choice(frequencies)
        start_date = rand_date(2020, 2025)
        # ~50% have stop date
        if random.random() < 0.5:
            stop_date = rand_date(2021, 2025)
        else:
            stop_date = None
        prescriber_id = random.randint(1, NUM_DOCTORS)

        lines.append(
            "INSERT INTO Prescription "
            "(Patient_ID, Medication_Name, Dose, Route, Frequency, "
            "Start_Date, Stop_Date, Prescriber_ID) VALUES ("
            f"{patient_id}, {sql_str(med)}, {sql_str(dose)}, {sql_str(route)}, "
            f"{sql_str(freq)}, {sql_str(start_date)}, "
            f"{sql_str(stop_date) if stop_date is not None else 'NULL'}, "
            f"{prescriber_id});"
        )

    # ---- DISPENSE ----
    lines.append("\n-- DISPENSE DATA")
    for did in range(1, NUM_DISPENSES + 1):
        prescription_id = random.randint(1, NUM_PRESCRIPTIONS)
        pharmacy_id = random.randint(1, NUM_PHARMACIES)
        pharmacist_id = random.randint(1, NUM_PHARMACISTS)
        dispense_date = rand_date(2020, 2025)
        qty = random.randint(10, 90)
        days_remaining = random.randint(0, 30)
        lines.append(
            "INSERT INTO Dispense "
            "(Prescription_ID, Pharmacy_ID, Pharmacist_ID, Dispense_Date, "
            "Quantity, Days_Remaining) VALUES ("
            f"{prescription_id}, {pharmacy_id}, {pharmacist_id}, "
            f"{sql_str(dispense_date)}, {qty}, {days_remaining});"
        )

    # ---- DOCUMENTS ----
    lines.append("\n-- DOCUMENT DATA")
    for did in range(1, NUM_DOCUMENTS + 1):
        patient_id = random.randint(1, NUM_PATIENTS)
        dtype = random.choice(doc_types)
        ctype = random.choice(consent_types)
        version = f"v{random.randint(1, 5)}.0"
        sig_ts = rand_datetime(2020, 2025)
        eff_start = rand_date(2020, 2025)
        eff_end = rand_date(2021, 2025) if random.random() < 0.4 else None
        rev_status = random.choice(['active', 'inactive'])
        lines.append(
            "INSERT INTO Document "
            "(Patient_ID, Document_Type, Consent_Type, Version, "
            "Signature_Timestamp, Effective_Start, Effective_End, Revocation_Status) "
            "VALUES ("
            f"{patient_id}, {sql_str(dtype)}, {sql_str(ctype)}, {sql_str(version)}, "
            f"{sql_str(sig_ts)}, {sql_str(eff_start)}, "
            f"{sql_str(eff_end) if eff_end is not None else 'NULL'}, "
            f"{sql_str(rev_status)});"
        )

    # ---- BILLING ----
    lines.append("\n-- BILLING DATA")
    for bid in range(1, NUM_BILLING + 1):
        patient_id = random.randint(1, NUM_PATIENTS)
        visit_id = random.randint(1, NUM_VISITS)
        bill_date = rand_date(2020, 2025)
        charge = round(random.uniform(50.0, 5000.0), 2)
        # Payment may be partial
        payment = round(charge * random.uniform(0.0, 1.0), 2)
        payer = random.choice(payer_types)
        aging = random.choice(aging_buckets)
        status = random.choice(['open', 'posted', 'paid'])
        lines.append(
            "INSERT INTO Billing "
            "(Patient_ID, Encounter_ID, Billing_Date, Charge_Amount, "
            "Payment_Amount, Payer_Type, Aging_Bucket, Billing_Status) "
            "VALUES ("
            f"{patient_id}, {visit_id}, {sql_str(bill_date)}, "
            f"{charge:.2f}, {payment:.2f}, {sql_str(payer)}, "
            f"{sql_str(aging)}, {sql_str(status)});"
        )

    # ---- ALLERGIES (a handful per patient on average) ----
    lines.append("\n-- ALLERGY DATA")
    allergy_names = ["Penicillin", "Peanuts", "Latex", "Shellfish", "Pollen"]
    severities = ['mild', 'moderate', 'severe']
    for patient_id in range(1, NUM_PATIENTS + 1):
        # 0–3 allergies per patient
        for _ in range(random.randint(0, 3)):
            aname = random.choice(allergy_names)
            sev = random.choice(severities)
            notes = random.choice(["Rash", "Shortness of breath", "Anaphylaxis",
                                   "Seasonal", "Mild hives"])
            lines.append(
                "INSERT INTO Allergy (Patient_ID, Allergy_Name, Severity, Notes) "
                f"VALUES ({patient_id}, {sql_str(aname)}, {sql_str(sev)}, {sql_str(notes)});"
            )

    # Write to file
    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))

    print(f"Wrote SQL data to {OUTPUT_FILE}")


if __name__ == "__main__":
    main()
