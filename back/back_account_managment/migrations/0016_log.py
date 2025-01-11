# Generated by Django 5.1.2 on 2025-01-11 09:06

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('back_account_managment', '0015_alter_item_description'),
    ]

    operations = [
        migrations.CreateModel(
            name='Log',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('code', models.CharField(choices=[('INVALID_SIGNATURE', 'Invalid Signature')], max_length=50)),
                ('details', models.JSONField(null=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
            ],
        ),
    ]
