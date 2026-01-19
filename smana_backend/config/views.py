from django.http import JsonResponse
from django.db import connections
from django.db.utils import OperationalError

def health_check(request):
    db_status = "ok"
    try:
        connections['default'].cursor()
    except OperationalError:
        db_status = "error"

    return JsonResponse({
        "status": "ok",
        "database": db_status
    })
