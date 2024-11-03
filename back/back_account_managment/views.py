from django.contrib.auth import authenticate, login
from django.contrib.auth.models import User
from rest_framework.views import APIView
from rest_framework.response import Response
from  rest_framework import status
from back_account_managment.serializers import UserSerializer
from back_account_managment.models import Item
from back_account_managment.models import Account
from back_account_managment.serializers import AccountSerializer, ItemSerializer

# Create your views here.
class LoginView(APIView):
    def post(self, request):
        data = request.data
        username = data["username"]
        password = data["password"]

        user = authenticate(request, username=username, password=password)

        if user is not None:
            login(request, user)
            return Response(status=status.HTTP_200_OK)

        else:
            return Response(status=status.HTTP_401_UNAUTHORIZED)

class UserView(APIView):
    queryset = User.objects.all()
    serializer_class  = UserSerializer

    def get(self, request):
        user = request.user
        serializer = self.serializer_class(user)
        
        return Response(data=serializer.data)

    def post(self, request):
        data = request.data
        new_user = User.objects.create_user(
            first_name=data["first_name"],
            last_name=data["last_name"],
            username=data["username"],
            email=data["email"],
            password=data["password"],
        )

        new_user.save()

        return Response()
    
    def patch(self, request):
        data = request.data
        user: User = request.user

        if user is not None:
            user.first_name = data["first_name"]
            user.last_name = data["last_name"]
            user.username = data["username"]
            user.email = data["email"]
            user.password = data["password"]

            user.save()

            return Response(status=status.HTTP_200_OK)
        
        else:
            return Response(status=status.HTTP_401_UNAUTHORIZED)
    
class IsLoggedView(APIView):
    def get(self, request):
        data = {"is_logged": False}

        if request.user.is_authenticated:
            data["is_logged"] = True

        return Response(status=status.HTTP_200_OK, data=data)
    
class ItemView(APIView):
    queryset = Item.objects.all()

    def get(self, request):
        user = request.user

        if user is not None:
            account = Account.objects.get(user=user)
            account_serializer = AccountSerializer(account)

            items = Item.objects.filter(account=account)
            item_serializer = ItemSerializer(items, many=True)

            return Response(data={"account": account_serializer.data, "items": item_serializer.data})
        
    def post(self, request):
        data = request.data

        new_item = Item.objects.create(
            title=data["title"],
            description=data["description"],
            valuation=data["valuation"],
            account=Account.objects.get(pk=data["account_id"]),
        )

        new_item.save()

        return Response()

