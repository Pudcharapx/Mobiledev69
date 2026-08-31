from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated

class BookingListView(APIView):
    #permission_classes = (IsAuthenticated, )
    
    def get(self, request):
        content = {
            'bookings': [{'id': 1, 'destination_name': 'Tokyo', 'price': 35000.0},
                         {'id': 2, 'destination_name': 'Kyoto', 'price': 25000.0},
            ]
        }
        return Response(content)