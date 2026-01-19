import os
import django
from django.conf import settings

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

print("DEBUG: MIDDLEWARE setting:")
for mw in settings.MIDDLEWARE:
    print(f"- {mw}")

from django.contrib.auth.middleware import AuthenticationMiddleware
print(f"\nAuthenticationMiddleware class: {AuthenticationMiddleware}")
