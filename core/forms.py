from django import forms

class LoginForm(forms.Form):
	def __init__(self, *args, **kwargs):
		super(LoginForm, self).__init__(*args, **kwargs)

	email = forms.EmailField(required=True,  widget=forms.EmailInput(
         attrs={'class': 'form-control form-control-lg', 'placeholder': 'Email', 'autofocus': True}))
	password = forms.CharField(widget=forms.PasswordInput(
		attrs={'class': 'form-control form-control-lg', 'placeholder': 'Contraseña', 'id': 'signin-password'}))