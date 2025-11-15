import json
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from api.model.inference import Model

model = Model.from_path('api/model/garden/rupiah_classification_final_2_10.h5')

@csrf_exempt
def predict(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body.decode('utf-8'))
            user_data = data.get('data')

            if user_data is None:
                return JsonResponse({'error': 'No data provided'}, status=400)
            
            prediction = model.predict_from_data(user_data)

            return JsonResponse({'message': 'Data received', 'prediction': prediction}, status=200)
        except json.JSONDecodeError:
            return JsonResponse({'error': 'Invalid JSON format'}, status=400)
    else:
        return JsonResponse({'error': 'This endpoint only supports POST requests.'}, status=405)
    
@csrf_exempt
def predict_image(request):
    # Handle CORS preflight request
    if request.method == 'OPTIONS':
        response = JsonResponse({'status': 'ok'})
        response['Access-Control-Allow-Origin'] = '*'
        response['Access-Control-Allow-Methods'] = 'POST, OPTIONS'
        response['Access-Control-Allow-Headers'] = 'Content-Type, ngrok-skip-browser-warning, User-Agent'
        return response
    
    if request.method == 'POST':
        try:
            image = request.FILES.get('image')

            if image is None:
                return JsonResponse({'error': 'No image provided'}, status=400)
            
            result = model.predict_from_image(image)

            response = JsonResponse({
                'message': 'Image received', 
                'prediction': result['prediction'],
                'confidence': result['confidence']
            }, status=200)
            response['Access-Control-Allow-Origin'] = '*'
            return response
        except Exception as e:
            response = JsonResponse({'error': str(e)}, status=500)
            response['Access-Control-Allow-Origin'] = '*'
            return response
    else:
        return JsonResponse({'error': 'This endpoint only supports POST requests.'}, status=405)
