from django.contrib.auth.models import User
from django.db import models
from django.db.models import Sum

# Create your models here.

class Account(models.Model):
    id = models.BigAutoField(primary_key=True)

    name = models.CharField(max_length=50)

    user = models.ForeignKey(User, on_delete=models.CASCADE)

    def total(self):
        return Item.objects.filter(account=self.pk).aggregate(total_sum=Sum('valuation'))

class Item(models.Model):
    id = models.BigAutoField(primary_key=True)

    title = models.CharField(max_length=100)

    description = models.CharField(max_length=250)

    valuation = models.DecimalField(max_digits=5, decimal_places=2)

    account = models.ForeignKey(Account, on_delete=models.CASCADE)

