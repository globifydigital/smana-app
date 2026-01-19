import os
import django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from django.contrib.auth import get_user_model
User = get_user_model()

if not User.objects.filter(email='admin@smana.com').exists():
    User.objects.create_superuser('admin@smana.com', 'admin')
    print("Superuser created: admin@smana.com / admin")
else:
    print("Superuser already exists")
