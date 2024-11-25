from django.conf import settings
from storages.backends.s3boto3 import S3Boto3Storage


class PublicMediaStorage(S3Boto3Storage):
    location = 'media'
    file_overwrite = False
    bucket_name = settings.MEDIA_S3_BUCKET_NAME
    custom_domain = settings.MEDIA_HOST
    querystring_auth = False
