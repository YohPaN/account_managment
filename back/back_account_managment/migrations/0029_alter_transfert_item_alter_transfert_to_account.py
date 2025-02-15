# Generated by Django 5.1.2 on 2025-02-15 08:03

import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('back_account_managment', '0028_accountuser_permissions'),
    ]

    operations = [
        migrations.AlterField(
            model_name='transfert',
            name='item',
            field=models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, related_name='to_account', to='back_account_managment.item'),
        ),
        migrations.AlterField(
            model_name='transfert',
            name='to_account',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='transfer_items', to='back_account_managment.account'),
        ),
    ]
