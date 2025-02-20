# Generated by Django 5.1.2 on 2024-11-16 14:08

import django.db.models.deletion
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        (
            "back_account_managment",
            "0002_alter_item_description_alter_item_title_and_more",
        ),
    ]

    operations = [
        migrations.CreateModel(
            name="AccountUser",
            fields=[
                ("id", models.BigAutoField(primary_key=True, serialize=False)),
                (
                    "state",
                    models.CharField(
                        choices=[
                            ("PENDING", "Pending"),
                            ("APPROVED", "Approved"),
                            ("DISAPPROVED", "Disapproved"),
                        ],
                        default="PENDING",
                        max_length=15,
                    ),
                ),
                (
                    "account",
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.CASCADE,
                        to="back_account_managment.account",
                    ),
                ),
                (
                    "user",
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.CASCADE,
                        to=settings.AUTH_USER_MODEL,
                    ),
                ),
            ],
        ),
    ]
