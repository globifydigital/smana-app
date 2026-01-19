from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from .views import RegisterView, LoginView, UserProfileView

urlpatterns = [
    path('auth/register/', RegisterView.as_view(), name='register'),
    path('auth/login/', LoginView.as_view(), name='login'), # Custom login with user data
    path('auth/profile/', UserProfileView.as_view(), name='profile'),
    path('auth/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    
    # Aliases for mobile compatibility if needed
    path('guests/register/', RegisterView.as_view(), name='guest_register'),
    path('guests/login/', LoginView.as_view(), name='guest_login'),
]
