# Generated by Django 5.1.2 on 2024-11-03 15:20

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('back_account_managment', '0001_initial'),
    ]

    operations = [
        migrations.RenameField(
            model_name='account',
            old_name='user_id',
            new_name='user',
        ),
        migrations.RenameField(
            model_name='item',
            old_name='account_id',
            new_name='account',
        ),
    ]
