from django.contrib.auth.models import AbstractUser
from django.db import models
from django.db.models import Sum
import uuid

class User(AbstractUser):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    username = models.CharField(max_length=15, unique=True)
    email = models.EmailField(max_length=50, unique=True)

    first_name = None
    last_name = None

class Profile(models.Model):
    id = models.BigAutoField(primary_key=True)
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name="profile")
    first_name = models.CharField(max_length=15)
    last_name = models.CharField(max_length=15)
    salary = models.DecimalField(max_digits=15, decimal_places=2)

class Account(models.Model):
    id = models.BigAutoField(primary_key=True)

    name = models.CharField(max_length=50)

    user = models.ForeignKey(User, on_delete=models.CASCADE)

    def items(self):
        return Item.objects.filter(account=self.pk)

    def total(self):
        return Item.objects.filter(account=self.pk).aggregate(total_sum=Sum('valuation'))
    
class Item(models.Model):
    id = models.BigAutoField(primary_key=True)

    title = models.CharField(max_length=15)

    description = models.CharField(max_length=50)

    valuation = models.DecimalField(max_digits=15, decimal_places=2)

    account = models.ForeignKey(Account, on_delete=models.CASCADE)
