"""
Django settings for cloudtalents project.

Generated by 'django-admin startproject' using Django 5.1.2.

For more information on this file, see
https://docs.djangoproject.com/en/5.1/topics/settings/

For the full list of settings and their values, see
https://docs.djangoproject.com/en/5.1/ref/settings/
"""

from pathlib import Path

import boto3

ssm = boto3.client("ssm")
SSM_PARAMETER_NAMESPACE = "/cloudtalents/startup"

# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent.parent


# Quick-start development settings - unsuitable for production
# See https://docs.djangoproject.com/en/5.1/howto/deployment/checklist/

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = ssm.get_parameter(Name=f"{SSM_PARAMETER_NAMESPACE}/secret_key", WithDecryption=True)["Parameter"]["Value"]

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = False

ALLOWED_HOSTS = ["*"]


# Application definition

INSTALLED_APPS = [
    'startup',
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'cloudtalents.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'cloudtalents.wsgi.application'


# Database
# https://docs.djangoproject.com/en/5.1/ref/settings/#databases

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'mvp',
        # SECURITY WARNING: this value should be kept secret! Don't push it to GitHub
        'USER': ssm.get_parameter(Name=f"{SSM_PARAMETER_NAMESPACE}/db_user", WithDecryption=True)["Parameter"]["Value"],
        # SECURITY WARNING: this value should be kept secret! Don't push it to GitHub
        'PASSWORD': ssm.get_parameter(Name=f"{SSM_PARAMETER_NAMESPACE}/db_password", WithDecryption=True)["Parameter"]["Value"],
        'HOST': ssm.get_parameter(Name=f"{SSM_PARAMETER_NAMESPACE}/database_endpoint", WithDecryption=True)["Parameter"]["Value"],
        'PORT': '5432',
    }
}


# Password validation
# https://docs.djangoproject.com/en/5.1/ref/settings/#auth-password-validators

AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]


# Internationalization
# https://docs.djangoproject.com/en/5.1/topics/i18n/

LANGUAGE_CODE = 'en-us'

TIME_ZONE = 'UTC'

USE_I18N = True

USE_TZ = True


# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/5.1/howto/static-files/

STATIC_URL = 'static/'

# Default primary key field type
# https://docs.djangoproject.com/en/5.1/ref/settings/#default-auto-field

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

MEDIA_S3_BUCKET_NAME = ssm.get_parameter(Name=f"{SSM_PARAMETER_NAMESPACE}/image_storage_bucket_name", WithDecryption=True)["Parameter"]["Value"]
MEDIA_HOST = ssm.get_parameter(Name=f"{SSM_PARAMETER_NAMESPACE}/image_storage_cloudfront_domain", WithDecryption=True)["Parameter"]["Value"]
MEDIA_URL=f'https://{MEDIA_HOST}/'
MEDIA_ROOT = '/'

LOGIN_REDIRECT_URL = '/images/'


STORAGES = {"default": {"BACKEND": "startup.storages.PublicMediaStorage"}}
