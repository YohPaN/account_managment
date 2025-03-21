from decimal import Decimal

from back_account_managment.models import (
    Account,
    AccountUser,
    Item,
    Profile,
    Transfert,
)
from back_account_managment.serializers.account_serializer import (
    AccountSerializer,
)
from back_account_managment.serializers.item_serializer import _ItemSerializer
from django.contrib.auth import get_user_model
from django.contrib.auth.models import Permission
from django.test import TestCase
from rest_framework.test import APIRequestFactory

User = get_user_model()


class AccountSerializerTest(TestCase):
    def setUp(self):
        self.factory = APIRequestFactory()
        self.user = User.objects.create(
            username="test",
            email="test@test.test",
        )
        self.user2 = User.objects.create(
            username="test2",
            email="test2@test.test",
        )
        self.user3 = User.objects.create(
            username="test3",
            email="test3@test.test",
        )

        self.profile = Profile.objects.create(
            first_name="test",
            last_name="test",
            user=self.user,
            salary=485.52,
        )
        self.profile2 = Profile.objects.create(
            first_name="test",
            last_name="test",
            user=self.user2,
            salary=1542.23,
        )

        self.request = self.factory.get("/")

        self.account = Account.objects.create(name="test", user=self.user)
        self.account2 = Account.objects.create(name="test", user=self.user)
        self.account3 = Account.objects.create(name="test", user=self.user)

        self.account_user = AccountUser.objects.create(
            account=self.account,
            user=self.user2,
            state="APPROVED",
        )

        self.account_user3 = AccountUser.objects.create(
            account=self.account,
            user=self.user3,
        )

        self.permission = Permission.objects.get(codename="view_account")

        self.account_user.permissions.add(self.permission)

        # Plus / user / account / 57.46
        Item.objects.create(
            title="test",
            valuation=57.46,
            user=self.user,
            account=self.account,
        )
        # Plus / user2 / account / 51.53
        Item.objects.create(
            title="test",
            valuation=51.53,
            user=self.user2,
            account=self.account,
        )
        # Plus / user / account2 / 21.45
        Item.objects.create(
            title="test",
            valuation=21.45,
            user=self.user,
            account=self.account2,
        )
        # Minus / user / account / 45.46
        Item.objects.create(
            title="test",
            valuation=-45.46,
            user=self.user,
            account=self.account,
        )
        # Minus / user2 / account / 51.89
        Item.objects.create(
            title="test",
            valuation=-51.89,
            user=self.user2,
            account=self.account,
        )
        # Minus / no user / account / 71.29
        Item.objects.create(
            title="test",
            valuation=-71.29,
            account=self.account,
        )

    def test_get_permissions(self):
        self.request.user = self.user2
        serializer = AccountSerializer(context={"request": self.request})

        permissions = serializer.get_permissions(self.account)

        self.assertEqual(
            permissions,
            [
                "view_account",
            ],
        )

    def test_get_permissions_for_account_owner(self):
        self.request.user = self.user
        serializer = AccountSerializer(context={"request": self.request})

        permissions = serializer.get_permissions(self.account)

        self.assertEqual(
            permissions,
            [],
        )

    def test_no_context(self):
        serializer = AccountSerializer()

        with self.assertRaises(KeyError):
            serializer.get_permissions(self.account)

    def test_get_own_contribution(self):
        self.request.user = self.user

        serializer = AccountSerializer(context={"request": self.request})

        own_contribution = serializer.get_own_contribution(self.account)

        self.assertEqual(own_contribution["total"], Decimal("57.46"))

    def test_get_own_contribution_with_transfert(self):
        transfert_item = Item.objects.create(
            title="test",
            valuation=-18.27,
            user=self.user,
            account=self.account2,
        )

        Transfert.objects.create(to_account=self.account, item=transfert_item)

        self.request.user = self.user

        serializer = AccountSerializer(context={"request": self.request})

        own_contribution = serializer.get_own_contribution(self.account)

        self.assertEqual(own_contribution["total"], Decimal("75.73"))

    def test_get_own_contribution_with_no_items(self):
        self.request.user = self.user
        serializer = AccountSerializer(context={"request": self.request})

        own_contribution = serializer.get_own_contribution(self.account3)

        # Decimal without arg return 0
        self.assertEqual(own_contribution["total"], Decimal())

    def test_get_need_to_add_without_salary_spliting(self):
        self.request.user = self.user
        serializer = AccountSerializer(context={"request": self.request})

        need_to_add = serializer.get_need_to_add(self.account)

        # calcul: all item less than 0 = 168.64
        # 2 part because the account owner and the user2 with approved state
        # user_part = 84.32
        # user has already put 57.46
        self.assertEqual(need_to_add["total"], Decimal("-26.86"))

    def test_get_need_to_add_with_trasnfert(self):
        item = Item.objects.create(
            title="test",
            valuation=58.46,
            user=self.user,
            account=self.account2,
        )
        Transfert.objects.create(to_account=self.account, item=item)

        self.request.user = self.user
        serializer = AccountSerializer(context={"request": self.request})

        need_to_add = serializer.get_need_to_add(self.account)

        # calcul: all item less than 0 = 168.64
        # Plus transfert = 227.1
        # 2 part because the account owner and the user2 with approved state
        # user_part = 113.55
        # user has already put 57.46
        self.assertEqual(need_to_add["total"], Decimal("-56.09"))

    def test_get_need_to_add_without_salary_spliting_and_without_other_user(
        self,
    ):
        self.account_user.delete()

        self.request.user = self.user
        serializer = AccountSerializer(context={"request": self.request})

        need_to_add = serializer.get_need_to_add(self.account)

        # calcul: all item less than 0 = 168.64
        # user_part = 168.64
        # user has already put 57.46
        self.assertEqual(need_to_add["total"], Decimal("-111.18"))

    def test_get_need_to_add_with_no_items_and_without_salary_spliting(self):
        self.request.user = self.user
        serializer = AccountSerializer(context={"request": self.request})

        need_to_add = serializer.get_need_to_add(self.account3)

        # Decimal without arg return 0
        self.assertEqual(need_to_add["total"], Decimal())

    def test_get_need_to_add_with_spliting(self):
        self.request.user = self.user
        self.account.salary_based_split = True
        self.account.save()

        serializer = AccountSerializer(context={"request": self.request})

        need_to_add = serializer.get_need_to_add(self.account)

        # calcul: all item less than 0 = 168.64
        # total salary = 2027.75
        # proportion of user = 0.24
        # user_part = 40.37
        # user has already put 57.46
        self.assertEqual(need_to_add["total"], Decimal("17.08"))

    def test_get_need_to_add_with_spliting_from_none_admin_user(self):
        self.request.user = self.user2
        self.account.salary_based_split = True
        self.account.save()

        serializer = AccountSerializer(context={"request": self.request})

        need_to_add = serializer.get_need_to_add(self.account)

        # calcul: all item less than 0 = 168.64
        # total salary = 2027.75
        # proportion of user = 0.76
        # user_part = 128.26
        # user has already put 51.53
        self.assertEqual(need_to_add["total"], Decimal("-76.73"))

    def test_get_need_to_add_with_spliting_but_no_other_user(self):
        self.request.user = self.user
        self.account.salary_based_split = True
        self.account.save()
        self.account_user.delete()

        serializer = AccountSerializer(context={"request": self.request})

        need_to_add = serializer.get_need_to_add(self.account)

        # calcul: all item less than 0 = 168.64
        # proportion of user = 1
        # user_part = 168.64
        # user has already put 57.46
        self.assertEqual(need_to_add["total"], Decimal("-111.18"))


class ItemSerializerTest(TestCase):
    def setUp(self):
        self.user = User.objects.create(
            username="test", email="test@test.test"
        )
        self.account = Account.objects.create(name="test", user=self.user)
        self.account2 = Account.objects.create(name="test", user=self.user)
        self.item = Item.objects.create(
            title="title",
            valuation=12,
            account=self.account2,
        )

        self.transfert = Transfert.objects.create(
            to_account=self.account, item=self.item
        )

    def test_get_to_account(self):
        expected = {"id": self.account.pk, "name": self.account.name}

        serializer = _ItemSerializer()

        self.assertEqual(expected, serializer.get_to_account(self.item))
