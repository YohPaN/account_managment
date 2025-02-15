import uuid

from django.contrib.auth.models import AbstractUser, Permission
from django.contrib.contenttypes.fields import (
    GenericForeignKey,
    GenericRelation,
)
from django.contrib.contenttypes.models import ContentType
from django.db import models
from django.db.models import CheckConstraint, Q


class Category(models.Model):
    title = models.CharField(max_length=25)
    color = models.CharField(max_length=50, blank=True)
    icon = models.JSONField()
    content_type = models.ForeignKey(
        ContentType, on_delete=models.CASCADE, null=True, blank=True
    )
    object_id = models.CharField(max_length=50, blank=True)
    content_object = GenericForeignKey("content_type", "object_id")

    def save(self, **kwargs):
        # verify that both are not None
        assert self.content_type != self.object_id
        return super().save(**kwargs)

    class Meta:
        indexes = [
            models.Index(fields=["content_type", "object_id"]),
        ]


class User(AbstractUser):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    username = models.CharField(max_length=15, unique=True)
    email = models.EmailField(max_length=50, unique=True)
    categories = GenericRelation(Category)

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
    salary_based_split = models.BooleanField(default=False)
    categories = models.ManyToManyField(Category, related_name="accounts")

    class Meta:
        permissions = [
            ("link_user_item", "Can link a user to an item"),
            ("add_item_without_user", "Can create an item with no user"),
            ("transfert_item", "Can transfert item into account"),
        ]

    def manage_category(self, category_id, link=True):
        try:
            category = Category.objects.get(pk=category_id)
            category_accounts = category.accounts.all()

            if link:
                if category_accounts.filter(~Q(pk=self.pk)).exists():
                    return {"error": "The category is link to another account"}

                elif category_accounts.filter(pk=self.pk).exists():
                    return True

                self.categories.add(category)
            else:
                self.categories.remove(category)

            return True

        except Category.DoesNotExist as e:
            return {"error": str(e)}


class Item(models.Model):
    id = models.BigAutoField(primary_key=True)
    title = models.CharField(max_length=15)
    description = models.CharField(max_length=50, null=True, blank=True)
    valuation = models.DecimalField(max_digits=15, decimal_places=2)
    account = models.ForeignKey(
        Account, on_delete=models.CASCADE, related_name="items"
    )
    user = models.ForeignKey(
        User, on_delete=models.CASCADE, null=True, blank=True
    )
    category = models.ForeignKey(
        Category, on_delete=models.SET_NULL, null=True, blank=True
    )

    def save(self, **kwargs):
        if self.category:
            assert self.category.accounts.filter(pk=self.account.pk).exists()

        return super().save(**kwargs)

    def manage_transfert(self, to_account):
        if to_account:
            Transfert.objects.update_or_create(
                item=self, defaults={"to_account_id": to_account}
            )

        else:
            trasfert = getattr(self, "to_account", None)
            if trasfert:
                trasfert.delete()


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
    permissions = models.ManyToManyField(Permission, blank=True)

    class Meta:
        constraints = [
            CheckConstraint(
                check=Q(
                    state__in=[choice.value for choice in AccountUserState]
                ),
                name="valid_state_constraint",
            )
        ]


class Transfert(models.Model):
    to_account = models.ForeignKey(
        Account, on_delete=models.CASCADE, related_name="transfer_items"
    )
    item = models.OneToOneField(
        Item, on_delete=models.CASCADE, related_name="to_account"
    )


class LogCode(models.TextChoices):
    INVALID_SIGNATURE = "INVALID_SIGNATURE"


class Log(models.Model):
    code = models.CharField(max_length=50, choices=LogCode)
    details = models.JSONField(null=True)
    created_at = models.DateTimeField(auto_now_add=True)
