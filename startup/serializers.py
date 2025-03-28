from rest_framework import serializers

from startup.models import Image


class ImageSerializer(serializers.ModelSerializer):
    user = serializers.HiddenField(default=serializers.CurrentUserDefault())

    class Meta:
        model = Image
        fields = ("user", "name", "description", "image")
        read_only_fields = ("user", "name", "description", "image")