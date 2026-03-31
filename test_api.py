import urllib.request
import json
url = 'https://adstudiobackend.onrender.com'
req1 = urllib.request.Request(url+'/api/auth/dev-login', data=json.dumps({'email':'avinash@stallar.tech','name':'Avinash Shrivastava'}).encode(), headers={'Content-Type': 'application/json'})
token = json.loads(urllib.request.urlopen(req1).read())['access_token']
req2 = urllib.request.Request(url+'/api/brands/', headers={'Authorization': 'Bearer '+token})
b = json.loads(urllib.request.urlopen(req2).read())[0]['_id']
req3 = urllib.request.Request(url+'/api/products/brand/'+b, headers={'Authorization': 'Bearer '+token})
products = json.loads(urllib.request.urlopen(req3).read())
with open('api_response.json', 'w') as f:
    json.dump(products, f, indent=2)
req1 = urllib.request.Request(url+'/api/auth/dev-login', data=json.dumps({'email':'avinash@stallar.tech','name':'Avinash Shrivastava'}).encode(), headers={'Content-Type': 'application/json'})
token = json.loads(urllib.request.urlopen(req1).read())['access_token']
req2 = urllib.request.Request(url+'/api/brands/', headers={'Authorization': 'Bearer '+token})
b = json.loads(urllib.request.urlopen(req2).read())[0]['_id']
req3 = urllib.request.Request(url+'/api/products/brand/'+b, headers={'Authorization': 'Bearer '+token})
products = json.loads(urllib.request.urlopen(req3).read())
with open('api_res.json', 'w') as f:
    json.dump(products, f, indent=2)
