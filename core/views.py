from django.shortcuts import render, redirect
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.decorators import login_required
from core.forms import LoginForm
from core.models import User
from core.models import *
from .forms import *
from django.db.models import Count
from django_celery_beat.models import PeriodicTask
from datetime import datetime

# Create your views here.

def Login(request):

    if request.user.is_authenticated:
        return redirect('dashboard')

    error_login = ''

    if request.method == 'POST':
        form = LoginForm(request.POST)
        if form.is_valid():
            email = form.cleaned_data['email']
            password = form.cleaned_data['password']
            try:
                test_user = User.objects.get(email=email)
                user = authenticate(request, username=test_user.username, password=password)
                if user is not None:
                    login(request, user)
                    return redirect('dashboard')
                else:
                    error_login = 'Usuario o la contraseña incorrectos'
            except User.DoesNotExist:
                error_login = 'Usuario o contraseña incorrectos'
            
    else:
        form = LoginForm()

    return render(request, 'login.html', {'form': form, 'error_login': error_login})

def Logout(request):
    logout(request)
    return redirect('login')

import pandas as pd

@login_required
def dashboard(request):
    # Obtén los datos del modelo InfoScrap
    info_scraps = InfoScrap.objects.all().order_by('-fecha_guardado')

    try:
        periodic_task = PeriodicTask.objects.get(name='DataScrapToExcel')
        last_run_at = periodic_task.last_run_at if periodic_task.last_run_at else "No disponible"
    except PeriodicTask.DoesNotExist:
        last_run_at = "No disponible"

    return render(request, 'inicio.html', {
        'last_run_at': last_run_at,
        'info_scraps': info_scraps,
    })