import uuid

from django.contrib.auth.models import AbstractUser, Permission
from django.db import models
from django.db.models import CheckConstraint, Q, Sum


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

    class Meta:
        permissions = [
            ("link_user_item", "Can link a user to an item"),
            ("add_item_without_user", "Can create an item with no user"),
        ]

    @property
    def total(self):
        return Item.objects.filter(account=self.pk).aggregate(
            total_sum=Sum("valuation")
        )


class Item(models.Model):
    id = models.BigAutoField(primary_key=True)
    title = models.CharField(max_length=15)
    description = models.CharField(max_length=50)
    valuation = models.DecimalField(max_digits=15, decimal_places=2)
    account = models.ForeignKey(
        Account, on_delete=models.CASCADE, related_name="items"
    )
    user = models.ForeignKey(User, on_delete=models.CASCADE)


class AccountUserState(models.TextChoices):
    PENDING = "PENDING"
    APPROVED = "APPROVED"
    DISAPPROVED = "DISAPPROVED"


class AccountUser(models.Model):

    id = models.BigAutoField(primary_key=True)
    state = models.CharField(
        choices=AccountUserState,
        default=AccountUserState.PENDING,
        max_length=15,
    )
    account = models.ForeignKey(
        Account, on_delete=models.CASCADE, related_name="contributors"
    )
    user = models.ForeignKey(User, on_delete=models.CASCADE)

    class Meta:
        constraints = [
            CheckConstraint(
                check=Q(
                    state__in=[choice.value for choice in AccountUserState]
                ),
                name="valid_state_constraint",
            )
        ]


class AccountUserPermission(models.Model):
    account_user = models.ForeignKey(AccountUser, on_delete=models.CASCADE)
    permissions = models.ForeignKey(Permission, on_delete=models.CASCADE)
