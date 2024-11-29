import uuid

from django.contrib.auth.models import AbstractUser, Permission
from django.db import models
from django.db.models import Sum


class User(AbstractUser):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    username = models.CharField(max_length=15, unique=True)
    email = models.EmailField(max_length=50, unique=True)

    first_name = None
    last_name = None


class Profile(models.Model):
    id = models.BigAutoField(primary_key=True)
    user = models.OneToOneField(
        User, on_delete=models.CASCADE, related_name="profile"
    )
    first_name = models.CharField(max_length=15)
    last_name = models.CharField(max_length=15)
    salary = models.DecimalField(
        max_digits=15, decimal_places=2, blank=True, null=True
    )


class Account(models.Model):
    id = models.BigAutoField(primary_key=True)

    name = models.CharField(max_length=50)

    user = models.ForeignKey(User, on_delete=models.CASCADE)
    is_main = models.BooleanField(default=False)

    def items(self):
        return Item.objects.filter(account=self.pk)

    def contributors(self):
        return AccountUser.objects.filter(account=self.pk)

    def total(self):
        return Item.objects.filter(account=self.pk).aggregate(
            total_sum=Sum("valuation")
        )


class Item(models.Model):
    id = models.BigAutoField(primary_key=True)

    title = models.CharField(max_length=15)

    description = models.CharField(max_length=50)

    valuation = models.DecimalField(max_digits=15, decimal_places=2)

    account = models.ForeignKey(Account, on_delete=models.CASCADE)


class AccountUser(models.Model):
    class AccountUserState(models.TextChoices):
        PENDING = "PENDING"
        APPROVED = "APPROVED"
        DISAPPROVED = "DISAPPROVED"

    id = models.BigAutoField(primary_key=True)
    state = models.CharField(
        choices=AccountUserState,
        default=AccountUserState.PENDING,
        max_length=15,
    )
    account = models.ForeignKey(Account, on_delete=models.CASCADE)
    user = models.ForeignKey(User, on_delete=models.CASCADE)


class AccountUserPermission(models.Model):
    account_user = models.ForeignKey(AccountUser, on_delete=models.CASCADE)
    permissions = models.ForeignKey(Permission, on_delete=models.CASCADE)
