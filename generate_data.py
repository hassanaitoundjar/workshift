import json
import random
from datetime import datetime, timedelta

# Data Setup
employees = [
    {"id": "emp_1", "name": "Ahmed Ben Ali", "phone": "+212600112233", "pricePerDay": 200.0, "isActive": True, "createdAt": "2025-01-01T09:00:00.000000"},
    {"id": "emp_2", "name": "Karim Mansouri", "phone": "+212611223344", "pricePerDay": 180.0, "isActive": True, "createdAt": "2025-01-01T10:00:00.000000"},
    {"id": "emp_3", "name": "Fatima Zahra", "phone": "+212622334455", "pricePerDay": 250.0, "isActive": True, "createdAt": "2025-01-01T11:00:00.000000"},
    {"id": "emp_4", "name": "Youssef El Amrani", "phone": "+212633445566", "pricePerDay": 220.0, "isActive": True, "createdAt": "2025-01-01T12:00:00.000000"},
    {"id": "emp_5", "name": "Sara Idrissi", "phone": "+212644556677", "pricePerDay": 190.0, "isActive": True, "createdAt": "2025-01-01T13:00:00.000000"}
]

clients = [
    {"id": "cli_1", "name": "Marjane Market", "location": "Casablanca", "contactPerson": "Mr. Rachid", "contactPhone": "+212522112233", "contactEmail": "rachid@marjane.ma", "isActive": True, "projectName": "Summer Promo", "createdAt": "2025-01-01T09:00:00.000000"},
    {"id": "cli_2", "name": "Acima Supermarket", "location": "Rabat", "contactPerson": "Ms. Laila", "contactPhone": "+212537112233", "contactEmail": "laila@acima.ma", "isActive": True, "projectName": "New Branch Opening", "createdAt": "2025-01-01T10:00:00.000000"},
    {"id": "cli_3", "name": "BIM Stores", "location": "Tangier", "contactPerson": "Mr. Omar", "contactPhone": "+212539112233", "contactEmail": "omar@bim.ma", "isActive": True, "projectName": "Inventory Check", "createdAt": "2025-01-01T11:00:00.000000"},
    {"id": "cli_4", "name": "Carrefour", "location": "Marrakech", "contactPerson": "Mr. Hassan", "contactPhone": "+212524112233", "contactEmail": "hassan@carrefour.ma", "isActive": True, "projectName": "Renovation", "createdAt": "2025-01-01T12:00:00.000000"},
    {"id": "cli_5", "name": "Asswak Assalam", "location": "Agadir", "contactPerson": "Ms. Nadia", "contactPhone": "+212528112233", "contactEmail": "nadia@asswak.ma", "isActive": True, "projectName": "Security Upgrade", "createdAt": "2025-01-01T13:00:00.000000"}
]

shifts = []
start_date = datetime(2025, 12, 1)
# Loop through 31 days of December 2025
for day in range(31):
    current_date = start_date + timedelta(days=day)
    date_str = current_date.isoformat() + ".000000"
    
    # For each employee
    for i, emp in enumerate(employees):
        # Client assignment pattern:
        # Randomly assign a different client to each employee for each day
        client_id = f"cli_{random.randint(1, 5)}"

        # Advance money logic: 20% chance of advance
        advance = 0.0
        if random.random() < 0.2:
            advance = random.choice([50.0, 100.0, 150.0, 200.0])

        shift = {
            "id": f"sh_dec25_{day+1}_{emp['id']}",
            "employeeId": emp['id'],
            "clientId": client_id,
            "date": date_str,
            "shiftType": 1, # All Day
            "advanceMoney": advance,
            "notes": "Generated",
            "isConfirmed": True,
            "createdAt": "2025-11-30T10:00:00.000000"
        }
        shifts.append(shift)

data = {
    "version": 1,
    "timestamp": datetime.now().isoformat(),
    "employees": employees,
    "clients": clients,
    "shifts": shifts
}

print(json.dumps(data, indent=2))
