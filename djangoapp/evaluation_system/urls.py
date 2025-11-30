from django.urls import path
from evaluation_system.views import index

app_name = 'evaluation_system'
urlpatterns = [
    path('', index, name='index'),
]

