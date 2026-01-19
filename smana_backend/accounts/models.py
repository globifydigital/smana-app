from django.db import models
from django.contrib.auth.models import AbstractUser, BaseUserManager

class UserManager(BaseUserManager):
    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError('The Email field must be set')
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('role', 'Admin')

        return self.create_user(email, password, **extra_fields)

class User(AbstractUser):
    username = None
    email = models.EmailField(unique=True)
    name = models.CharField(max_length=255)
    
    class Role(models.TextChoices):
        ADMIN = 'Admin', 'Admin'
        STAFF = 'Staff', 'Staff' # Generic staff
        RECEPTIONIST = 'Receptionist', 'Receptionist'
        HOUSEKEEPING = 'Housekeeping', 'Housekeeping'
        CHEF = 'Chef', 'Chef'
        GUEST = 'Guest', 'Guest'

    role = models.CharField(max_length=20, choices=Role.choices, default=Role.GUEST)
    
    # Guest specific fields
    phone = models.CharField(max_length=20, blank=True, null=True)
    room_number = models.CharField(max_length=10, blank=True, null=True)
    is_checked_in = models.BooleanField(default=False)
    check_in_date = models.DateTimeField(blank=True, null=True)
    check_out_date = models.DateTimeField(blank=True, null=True)

    # Staff specific fields
    is_online = models.BooleanField(default=False)

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['name']

    objects = UserManager()

    def __str__(self):
        return self.email
