# Generated by Django 5.1.2 on 2024-11-15 14:47

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('back_account_managment', '0001_initial'),
    ]

    operations = [
        migrations.AlterField(
            model_name='item',
            name='description',
            field=models.CharField(max_length=50),
        ),
        migrations.AlterField(
            model_name='item',
            name='title',
            field=models.CharField(max_length=15),
        ),
        migrations.AlterField(
            model_name='item',
            name='valuation',
            field=models.DecimalField(decimal_places=2, max_digits=15),
        ),
        migrations.AlterField(
            model_name='profile',
            name='first_name',
            field=models.CharField(max_length=15),
        ),
        migrations.AlterField(
            model_name='profile',
            name='last_name',
            field=models.CharField(max_length=15),
        ),
        migrations.AlterField(
            model_name='profile',
            name='salary',
            field=models.DecimalField(decimal_places=2, max_digits=15),
        ),
        migrations.AlterField(
            model_name='user',
            name='email',
            field=models.EmailField(max_length=50, unique=True),
        ),
        migrations.AlterField(
            model_name='user',
            name='username',
            field=models.CharField(max_length=15, unique=True),
        ),
    ]
