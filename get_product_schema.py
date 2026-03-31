import json

with open('/Users/avinash/marketmind./openapi.json', 'r') as f:
    data = json.load(f)

schemas = data.get('components', {}).get('schemas', {})
for k in schemas.keys():
    if 'Product' in k:
        print(f"--- Schema: {k} ---")
        print(json.dumps(schemas[k], indent=2))
        break
