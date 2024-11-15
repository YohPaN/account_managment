from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.viewsets import ModelViewSet
from back_account_managment.serializers import UserSerializer, ItemSerializer, AccountSerializer
from back_account_managment import models
from rest_framework import status, permissions
from django.contrib.auth import get_user_model
from back_account_managment.serializers import ManageAccountSerializer
from rest_framework.decorators import action
from back_account_managment.models import Account
from django.contrib.auth.hashers import check_password, make_password
User = get_user_model()

class UserView(ModelViewSet):
    queryset = User.objects.all()
    serializer_class  = UserSerializer
    permission_classes = [permissions.IsAuthenticated]

    @action(detail=False, methods=['get'], url_path='me')
    def get_current_user(self, request):
        user = request.user
        serializer = self.serializer_class(user)
        return Response(serializer.data)

    @action(detail=False, methods=['patch'], url_path='me/update')
    def update_current_user(self, request):
        user = request.user
        profile = user.profile

        user.username = request.data["username"]
        user.password = request.data["password"]
        user.email = request.data["email"]
        user.save()

        profile.first_name = request.data["first_name"]
        profile.last_name = request.data["last_name"]
        profile.salary = request.data["salary"]
        profile.save()

        serializer = self.serializer_class(user)

        return Response(status=status.HTTP_200_OK, data=serializer.data)

    @action(detail=False, methods=['patch'], url_path='password')
    def update_password(self, request):
        user = request.user
        old_password = request.data["old_password"]
        new_password = request.data["new_password"]

        if(check_password(old_password, user.password)):
            user.password = make_password(new_password)
            user.save()

            return Response(status=status.HTTP_200_OK)
        
        else:
            return Response(status=status.HTTP_401_UNAUTHORIZED)

class ProfileView(ModelViewSet):
    queryset = models.Profile.objects.all()
    permission_classes = [permissions.IsAuthenticated]

    def list(self, request):
        user = request.user
        serializer = UserSerializer(user)  # Serialize the user with profile data

        return Response(serializer.data, status=status.HTTP_200_OK)
    
    def patch(self, request):
        data = request.data
        user = request.user

        try:
            user.username = data.get("username", user.username)
            user.email = data.get("email", user.email)
            user.save()

            # Update profile fields
            profile = models.Profile.objects.get(user=user)
            profile.first_name = data.get("first_name", profile.first_name)
            profile.last_name = data.get("last_name", profile.last_name)
            profile.salary = data.get("salary", profile.salary)
            profile.save()
            
            return Response(status=status.HTTP_200_OK)
        except Exception:
            return Response(status=status.HTTP_400_BAD_REQUEST)



class RegisterView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        data = request.data

        try:
            user = User.objects.create_user(
                username=data["username"],
                email=data["email"],
            )
            user.set_password(data["password"]),

            profile = models.Profile.objects.create(
                first_name=data["first_name"],
                last_name=data["last_name"],
                salary=data["salary"],
                user=user
            )

            account = models.Account.objects.create(
                name="my account",
                user=user
            )

            user.save()
            profile.save()
            account.save()

            return Response(status=status.HTTP_201_CREATED)
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)
    
class ItemView(ModelViewSet):
    queryset = models.Item.objects.all()
    serializer_class = ItemSerializer


class AccountView(ModelViewSet):
    queryset = models.Account.objects.all()
    serializer_class = AccountSerializer

    @action(detail=False, methods=['get'], url_path="me")
    def get_current_user_account(self, request, pk=None):
        user = request.user

        try:
            account = Account.objects.get(user=user)
        except models.Account.DoesNotExist:
            return Response({"detail": "Account not found."}, status=status.HTTP_404_NOT_FOUND)

        serializer = self.serializer_class(account)

        return Response(data=serializer.data, status=status.HTTP_200_OK)

    @action(detail=True, methods=['get'], url_path="items")
    def get_items(self, request, pk=None):
        try:
            account = Account.objects.get(pk=pk)
        except models.Account.DoesNotExist:
            return Response({"detail": "Account not found."}, status=status.HTTP_404_NOT_FOUND)

        items = account.items()
        
        serializer = ItemSerializer(items, many=True)
        
        return Response(serializer.data, status=status.HTTP_200_OK)

    def create(self, request, *args, **kwargs):
        data = {"name": request.data["name"], "user": request.user.id}
        serializer = ManageAccountSerializer(data=data)
        
        if serializer.is_valid():
            serializer.save()
            
            return Response(status=status.HTTP_201_CREATED)
        
        # Return errors if validation fails
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)