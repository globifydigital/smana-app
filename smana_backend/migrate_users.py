import os
import django
import pymongo
from datetime import datetime

# Setup Django Environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from django.conf import settings
from accounts.models import User
from django.contrib.auth.hashers import make_password

def migrate_users():
    # Connect to MongoDB directly
    # Assuming connection string is simple enough to parse or hardcode for local
    client = pymongo.MongoClient('mongodb://localhost:27017/')
    db = client['smana_hotel']

    print("Migrating GUESTS...")
    guests = db['guests'].find({})
    guest_count = 0
    for guest in guests:
        email = guest.get('email')
        if not email:
            continue
        
        if User.objects.filter(email=email).exists():
            print(f"Skipping existing user: {email}")
            continue

        try:
            # Map fields
            new_user = User(
                email=email,
                name=guest.get('name', ''),
                phone=guest.get('phone', ''),
                room_number=guest.get('roomNumber'),
                is_checked_in=guest.get('isCheckedIn', False),
                check_in_date=guest.get('checkInDate'),
                check_out_date=guest.get('checkOutDate'),
                role='Guest',
                password=guest.get('password', ''), # Raw hash
                is_active=True,
                date_joined=guest.get('createdAt', datetime.now())
            )
            # We don't use set_password/make_password because we want to preserve the existing hash
            # Django's BCryptPasswordHasher can verify $2b$ hashes usually.
            # If the hash is not standard, they might need reset.
            new_user.save()
            guest_count += 1
        except Exception as e:
            print(f"Error migrating guest {email}: {e}")

    print(f"Migrated {guest_count} guests.")

    print("Migrating STAFF...")
    staffs = db['staffs'].find({}) # Mongoose default collection name
    # Fallback if staffs doesn't exist (check 'staff')
    if db['staffs'].count_documents({}) == 0 and db['staff'].count_documents({}) > 0:
        staffs = db['staff'].find({})

    staff_count = 0
    for staff in staffs:
        email = staff.get('email')
        if not email:
            continue

        if User.objects.filter(email=email).exists():
            print(f"Skipping existing user: {email}")
            continue

        try:
            role_map = {
                'Admin': 'Admin',
                'Receptionist': 'Receptionist',
                'Housekeeping': 'Housekeeping',
                'Chef': 'Chef'
            }
            role = role_map.get(staff.get('role'), 'Staff')

            new_user = User(
                email=email,
                name=staff.get('name', ''),
                role=role,
                is_staff=True if role == 'Admin' else False,
                is_superuser=True if role == 'Admin' else False,
                password=staff.get('password', ''),
                is_active=True,
                is_online=staff.get('isOnline', False),
                date_joined=staff.get('createdAt', datetime.now())
            )
            new_user.save()
            staff_count += 1
        except Exception as e:
            print(f"Error migrating staff {email}: {e}")

    print(f"Migrated {staff_count} staff members.")

if __name__ == '__main__':
    migrate_users()
