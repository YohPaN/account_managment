# Generated by Django 5.1.2 on 2024-11-17 17:40

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('back_account_managment', '0003_accountuser'),
    ]

    operations = [
        migrations.AddField(
            model_name='account',
            name='is_main',
            field=models.BooleanField(default=False),
        ),
    ]
