import uuid

from django.contrib.auth.models import AbstractUser, Permission
from django.contrib.contenttypes.fields import (
    GenericForeignKey,
    GenericRelation,
)
from django.contrib.contenttypes.models import ContentType
from django.db import models
from django.db.models import (
    Case,
    CheckConstraint,
    Exists,
    F,
    OuterRef,
    Q,
    Sum,
    Value,
    When,
)


class Category(models.Model):
    title = models.CharField(max_length=25)
    color = models.CharField(max_length=50, blank=True)
    icon = models.CharField(max_length=50, blank=True)
    content_type = models.ForeignKey(
        ContentType, on_delete=models.CASCADE, null=True, blank=True
    )
    object_id = models.CharField(max_length=50, blank=True)
    content_object = GenericForeignKey("content_type", "object_id")

    def save(self, **kwargs):
        # We are testing that both are not None
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
    account_categories = models.ManyToManyField(
        Category, through="AccountCategory"
    )

    class Meta:
        permissions = [
            ("link_user_item", "Can link a user to an item"),
            ("add_item_without_user", "Can create an item with no user"),
            ("transfert_item", "Can transfert item into account"),
        ]

    @property
    def total(self):
        transfert_item = Transfert.objects.filter(
            to_account_id=self.pk, item=OuterRef("pk")
        )

        total = Item.objects.annotate(
            calc_valuation=Case(
                When(Exists(transfert_item), then=F("valuation") * Value(-1)),
                default=F("valuation"),
            )
        ).filter(
            Q(account_id=self.pk) | Exists(transfert_item),
        )

        return total.aggregate(total_sum=(Sum("calc_valuation", default=0)))


class AccountCategory(models.Model):
    category = models.ForeignKey(Category, on_delete=models.CASCADE)
    account = models.ForeignKey(Account, on_delete=models.CASCADE)


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
        Category, on_delete=models.CASCADE, null=True, blank=True
    )

    def save(self, **kwargs):
        if self.category:
            account_category = AccountCategory.objects.filter(
                account=self.account, category=self.category
            )

            assert account_category.exists()

        return super().save(**kwargs)


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


class Transfert(models.Model):
    to_account = models.ForeignKey(Account, on_delete=models.CASCADE)
    item = models.OneToOneField(Item, on_delete=models.CASCADE)


class LogCode(models.TextChoices):
    INVALID_SIGNATURE = "INVALID_SIGNATURE"


class Log(models.Model):
    code = models.CharField(max_length=50, choices=LogCode)
    details = models.JSONField(null=True)
    created_at = models.DateTimeField(auto_now_add=True)
