import json

print('Loading function')

def lambda_handler(event, context):
    payload = json.dumps(event, indent=2)
    print("Received event: " + payload)
    return {
        'statusCode' : 200,
        'body': 'hello world'
    }
