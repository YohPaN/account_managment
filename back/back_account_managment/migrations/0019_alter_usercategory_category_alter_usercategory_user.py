# Generated by Django 5.1.2 on 2025-01-17 16:13

import django.db.models.deletion
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('back_account_managment', '0018_usercategory'),
    ]

    operations = [
        migrations.AlterField(
            model_name='usercategory',
            name='category',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='user_categories', to='back_account_managment.category'),
        ),
        migrations.AlterField(
            model_name='usercategory',
            name='user',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='user_categories', to=settings.AUTH_USER_MODEL),
        ),
    ]
