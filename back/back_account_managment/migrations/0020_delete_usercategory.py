# Generated by Django 5.1.2 on 2025-01-24 07:16

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        (
            "back_account_managment",
            "0019_alter_usercategory_category_alter_usercategory_user",
        ),
    ]

    operations = [
        migrations.DeleteModel(
            name="UserCategory",
        ),
    ]
