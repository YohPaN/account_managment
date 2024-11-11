from django.contrib.auth import authenticate, login
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.viewsets import ModelViewSet
from back_account_managment.serializers import UserSerializer, ItemSerializer, AccountSerializer
from back_account_managment import models
from rest_framework import permissions, status
from django.contrib.auth.hashers import make_password
from django.contrib.auth import get_user_model
from back_account_managment.serializers import ManageAccountSerializer

User = get_user_model()

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

class UserView(ModelViewSet):
    queryset = User.objects.all()
    serializer_class  = UserSerializer
    permission_classes = [permissions.IsAuthenticated]

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
    
class IsLoggedView(APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request):
        data = {"is_logged": False}

        if request.user.is_authenticated:
            data["is_logged"] = True

        return Response(status=status.HTTP_200_OK, data=data)
    
class ItemView(ModelViewSet):
    queryset = models.Item.objects.all()
    serializer_class = ItemSerializer


class AccountView(ModelViewSet):
    queryset = models.Account.objects.all()
    serializer_class = AccountSerializer

    def create(self, request, *args, **kwargs):
        data = {"name": request.data["name"], "user": request.user.id}
        serializer = ManageAccountSerializer(data=data)
        
        if serializer.is_valid():
            serializer.save()
            
            return Response(status=status.HTTP_201_CREATED)
        
        # Return errors if validation fails
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)